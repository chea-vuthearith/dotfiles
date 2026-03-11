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
in {
  # TODO: tmux on remote sessions
  # fzf session switcher
  # ssh auth agent refresh
  programs = {
    bat.enable = true;
    tmux = {
      enable = true;
      newSession = true;

      plugins = with pkgs.tmuxPlugins; [
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
            set -g @catppuccin_window_number "#[bold]Tab ###I "
            set -g @catppuccin_window_current_text ""
            set -g @catppuccin_window_current_number "#[bold]Tab ###I "

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
      extraConfig = ''
        # styling
        set pane-border-indicators off
        set -g status-position top
        set -g window-status-separator ""
        set -g status-left-length 0
        set -g status-left "#[fg=#{@thm_fg} bold]TMUX (#S) "
        set -ga status-left "#{?client_prefix,#[fg=#{@thm_red} bold]PREFIX ,#{?#{==:#{pane_mode},copy-mode},#[fg=#{@thm_yellow} bold]COPY ,#[fg=#{@thm_mauve} bold]NORMAL }}"
        set -g status-right ""

        # etc
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # bindings
        unbind C-b
        set -g prefix M-w
        bind M-w send-prefix

        # unbinds
        unbind [          # default copy mode
        unbind c          # default new window
        unbind %          # default split vertical
        unbind '"'        # default split horizontal
        unbind x          # default kill pane
        unbind &          # default kill window

        # copy mode
        set-window-option -g mode-keys vi
        bind v copy-mode
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi / command-prompt -p "(search down)" "send -X search-forward \"%%%\""
        bind-key -T copy-mode-vi ? command-prompt -p "(search up)" "send -X search-backward \"%%%\""
        bind-key -T copy-mode-vi n send-keys -X search-again
        bind-key -T copy-mode-vi N send-keys -X search-reverse
        bind-key -T copy-mode-vi Escape send-keys -X cancel

        # tabs
        bind Tab switch-client -T tab-prefix
        bind -T tab-prefix Tab new-window -c "#{pane_current_path}"
        bind -T tab-prefix d kill-window
        bind -n M-h previous-window
        bind -n M-l next-window

        # panes
        bind w switch-client -T w-prefix
        bind '-' split-window -v -c "#{pane_current_path}"
        bind '|' split-window -h -c "#{pane_current_path}"
        bind -T w-prefix w split-window -h -c "#{pane_current_path}"
        bind -T w-prefix d kill-pane
      '';
    };
  };
}
