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
  remote-conf = pkgs.writeText "remote-tmux.conf" (builtins.concatStringsSep "\n" [
    (builtins.readFile ./tmux-base.conf)
    (builtins.readFile ./tmux-keys.conf)
    (builtins.readFile ./tmux-remote-extras.conf)
  ]);
in {
  programs = {
    zsh.initContent = lib.mkOrder 1500 ''
      sst() {
          local config=${remote-conf}
          local remote_tmp="/tmp/remote-tmux-conf-$$"
          local session_name="main"

          scp "$config" "$1:$remote_tmp" || return 1

          ssh -t "$1" '
              # symlink auth sock so tmux can resolve on re-attach
              if [ -S "$SSH_AUTH_SOCK" ] && [ ! -h "$SSH_AUTH_SOCK" ]; then
                  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
              fi

              # create session if it doesnt exist
              tmux has-session -t '"$session_name"' 2>/dev/null || tmux -f '"$remote_tmp"' new-session -d -s '"$session_name"'

              rm -f '"$remote_tmp"'
              tmux send-keys -t '"$session_name"' "export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock" C-m

              tmux attach -t '"$session_name"'
          '
      }

      compdef sst=ssh
    '';
    bat.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = tmux-suspend;
          extraConfig = ''
            set -g @suspend_key 'M-Escape'
            set -g @suspend_suspended_options " \
              status-left::#[fg=#{@thm_fg} bold]TMUX (#S) #[fg=#{@thm_rosewater} bold]SUSPEND , \
            "
          '';
        }
        {
          plugin = tmux-sessionx;
          extraConfig = ''
            set -g @sessionx-bind 's'
            set -g @sessionx-filter-current 'false'
            set -g @sessionx-ls-command 'lsd --tree --color=always --icon=always'
            set -g @sessionx-bind-select-up 'ctrl-p'
            set -g @sessionx-bind-select-down 'ctrl-n'
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
