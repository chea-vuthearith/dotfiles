{
  lib,
  pkgs,
  ...
}: let
  sesh-fzf = pkgs.writeShellScript "sesh-fzf" ''
    sesh list --icons | fzf-tmux -p 80%,70% \
      --no-sort \
      --ansi \
      --header "  ^a all ^t tmux ^x zoxide ^d kill" \
      --bind "tab:down,btab:up" \
      --bind "ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)" \
      --bind "ctrl-t:change-prompt(  )+reload(sesh list -t --icons)" \
      --bind "ctrl-x:change-prompt(󰈞  )+reload(sesh list -z --icons)" \
      --bind "ctrl-d:execute(
        name={2..};
        if sesh list -T | grep -qxF \"$name\"; then
          (
            if output=$(tmuxinator stop \"$name\" 2>&1); then
              notify-send \"tmuxinator\" \"Stopped $name\"
            else
              notify-send -u critical \"tmuxinator\" \"Failed to stop $name\n\n$output\"
            fi
          ) &
        else
          (
            if output=$(tmux kill-session -t \"$name\" 2>&1); then
              notify-send \"tmux\" \"Killed $name\"
            else
              notify-send -u critical \"tmux\" \"Failed to kill $name\n\n$output\"
            fi
          ) &
        fi
      )+reload(sesh list --icons)" \
      --preview-window "right:55%" \
      --preview "sesh preview {}" \
      -- --ansi
  '';
  smart-splits = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "smart-splits";
    version = "1.0.0";
    rtpFilePath = "smart-splits.tmux";
    src = pkgs.fetchFromGitHub {
      owner = "mrjones2014";
      repo = "smart-splits.nvim";
      rev = "25bf40abf79720ebfa98e09259b7c42942055f4c";
      sha256 = "sha256-HOzy+DX1+1ZrWnqWivpV2spoTeMncdokUruXUm8lBcE=";
    };
  };
  tmux-suspend = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "suspend";
    version = "1.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "MunifTanjim";
      repo = "tmux-suspend";
      rev = "1a2f806666e0bfed37535372279fa00d27d50d14";
      sha256 = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
    };
  };
  # to keep the remote conf small, fast to transfer
  minify = s: let
    lines = lib.splitString "\n" s;
    keep = l: let t = lib.trim l; in t != "" && !(lib.hasPrefix "#" t);
  in
    builtins.concatStringsSep "\n" (builtins.filter keep lines);
  remote-conf = pkgs.writeText "remote-tmux.conf" (minify (builtins.concatStringsSep "\n" [
    (builtins.readFile ./conf/tmux-base.conf)
    (builtins.readFile ./conf/tmux-keys.conf)
    (builtins.readFile ./conf/tmux-styling.conf)
    (builtins.readFile ./conf/tmux-remote-extras.conf)
  ]));
in {
  xdg.configFile."tmuxinator" = {
    source = ./tmuxinator;
    recursive = true;
  };

  programs = {
    sesh = {
      enable = true;
      enableTmuxIntegration = false; # custom command defined in ./tmux-local-extras.conf
    };
    zsh = {
      shellAliases = {
        sc = "sesh connect";
      };
      initContent = lib.mkOrder 1500 ''
        __sesh_fzf() {
          ${sesh-fzf}
        }

        __sesh_prefix() {
          local key selected

          read -k key

          case "$key" in
            s)
              selected="$(__sesh_fzf)" || return 0
              [[ -n "$selected" ]] || return 0

              BUFFER="sesh connect \"$selected\""
              zle accept-line
              ;;

            .)
              BUFFER='sesh connect .'
              zle accept-line
              ;;

            *)
              zle -U "w$key"
              ;;
          esac
        }
        zle -N __sesh_prefix
        bindkey -M viins '\ew' __sesh_prefix
        bindkey -M vicmd '\ew' __sesh_prefix

        sst() {
            local session="main"
            local tmp="/tmp/remote-tmux-$$"

            ssh -t "$1" "
                export PATH=\$PATH:~/bin
                cat > $tmp << 'TMUXCONF'
        $(cat ${remote-conf})
        TMUXCONF
                [ -S \"\$SSH_AUTH_SOCK\" ] && [ ! -h \"\$SSH_AUTH_SOCK\" ] && ln -sf \"\$SSH_AUTH_SOCK\" ~/.ssh/ssh_auth_sock
                tmux has-session -t $session 2>/dev/null || tmux -f $tmp new-session -d -s $session
                tmux send-keys -t $session 'export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock' C-m 2>/dev/null
                rm -f $tmp
                exec tmux attach -t $session
            "
        }
        compdef sst=ssh
      '';
    };
    tmux = {
      tmuxinator.enable = true;
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = tmux-suspend;
          extraConfig = ''
            set -g @suspend_key 'M-Escape'
            set -g @suspend_suspended_options " \
              status::off
            "
          '';
        }
        {
          plugin = smart-splits;
          extraConfig = ''
            set -g @smart-splits_no_wrap "" # to disable wrapping. (any value disables wrapping)

            set -g @smart-splits_move_left_key  "C-h"
            set -g @smart-splits_move_down_key  "C-j"
            set -g @smart-splits_move_up_key    "C-k"
            set -g @smart-splits_move_right_key "C-l"

            set -g @smart-splits_resize_left_key  "C-left"
            set -g @smart-splits_resize_down_key  "C-down"
            set -g @smart-splits_resize_up_key    "C-up"
            set -g @smart-splits_resize_right_key "C-right"

            set -g @smart-splits_resize_step_size "3"
          '';
        }
        sensible
        yank
      ];
      extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile ./conf/tmux-base.conf)
        (builtins.readFile ./conf/tmux-styling.conf)
        (builtins.readFile ./conf/tmux-keys.conf)
        (builtins.replaceStrings ["@sesh_fzf@"] ["${sesh-fzf}"] (builtins.readFile ./conf/tmux-local-extras.conf))
      ];
    };
  };
}
