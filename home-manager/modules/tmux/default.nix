{
  lib,
  pkgs,
  ...
}: let
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
    (builtins.readFile ./tmux-base.conf)
    (builtins.readFile ./tmux-keys.conf)
    (builtins.readFile ./tmux-styling.conf)
    (builtins.readFile ./tmux-remote-extras.conf)
  ]));
in {
  programs = {
    zsh.initContent = lib.mkOrder 1500 ''
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
    sesh.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = tmux-suspend;
          extraConfig = ''
            set -g @suspend_key 'M-Escape'
            set -g @suspend_suspended_options " \
              status-left::#[fg=#{@thm_fg} bold]TMUX (#S) #[fg=#{@thm_subtext_1} bold]SUSPEND , \
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
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour "mocha"
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_current_number_color "#{@thm_mauve}"
            set -g @catppuccin_window_text ""
            set -g @catppuccin_window_number "#[bold]#W#{?window_zoomed_flag, ,} "
            set -g @catppuccin_window_current_text ""
            set -g @catppuccin_window_current_number "#[bold]#W#{?window_zoomed_flag, ,} "

            set -g @catppuccin_window_status_style "custom"
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_middle_separator "#[bg=#{@catppuccin_window_number_color},fg=#{@_ctp_status_bg}]"
            set -g @catppuccin_window_current_middle_separator "#[bg=#{@catppuccin_window_current_number_color},fg=#{@_ctp_status_bg}]"
            set -g @catppuccin_window_right_separator "#[fg=#{@_ctp_status_bg},reverse]#[none]"
          '';
        }
        sensible
        yank
      ];
      extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile ./tmux-base.conf)
        (builtins.readFile ./tmux-styling.conf)
        (builtins.readFile ./tmux-keys.conf)
      ];
    };
  };
}
