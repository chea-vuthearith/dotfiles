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
  remote-conf = pkgs.writeText "remote-tmux.conf" (builtins.concatStringsSep "\n" [
    (builtins.readFile ./tmux.conf)
    (builtins.readFile ./remote-overrides.conf)
  ]);
in {
  # TODO: tmux on remote sessions
  # ssh auth agent refresh
  programs = {
    zsh.initContent = lib.mkOrder 1500 ''
      sst() {
          local config=${remote-conf}
          local remote_tmp="/tmp/remote-tmux-conf-$$"
          scp "$config" "$1:$remote_tmp" || return 1
          ssh -t "$1" "tmux -f $remote_tmp new-session -A -s main; rm -f $remote_tmp"
      }

      compdef sst=ssh
    '';
    bat.enable = true;
    tmux = {
      enable = true;
      newSession = true;
      plugins = with pkgs.tmuxPlugins; [
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
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
