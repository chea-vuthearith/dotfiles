{
  pkgs,
  config,
  ...
}: {
  programs = {
    bat.enable = true;
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        dotbar
        vim-tmux-navigator
        sensible
        yank
      ];
      extraConfig = with config.lib.stylix.colors; ''
        # styling
        set pane-border-indicators off
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # colors
        set -g status-style bg=#${base01},fg=#${base05}
        set -g pane-border-style fg=#${base03}
        set -g pane-active-border-style fg=#${base0D}
        set -g window-status-style bg=#${base01},fg=#${base04}
        set -g window-status-current-style bg=#${base0D},fg=#${base00}
        set -g message-style bg=#${base0A},fg=#${base00}
        set -g message-command-style bg=#${base0A},fg=#${base00}

        # bindings
        unbind C-b
        set -g prefix M-w
        bind M-w send-prefix

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

        # unbinds
        unbind [          # default copy mode
        unbind c          # default new window
        unbind %          # default split vertical
        unbind '"'        # default split horizontal
        unbind x          # default kill pane
        unbind &          # default kill window

        # tabs
        bind Tab switch-client -T tab-prefix
        bind -T tab-prefix Tab new-window -c "#{pane_current_path}"
        bind -T tab-prefix d kill-window
        bind -n M-h previous-window
        bind -n M-l next-window

        # panes
        set -g @vim_navigator_mapping_left "C-h"
        set -g @vim_navigator_mapping_right "C-l"
        set -g @vim_navigator_mapping_up "C-k"
        set -g @vim_navigator_mapping_down "C-j"
        set -g @vim_navigator_mapping_prev ""  # removes the C-\ binding
        bind w switch-client -T w-prefix
        bind '-' split-window -v -c "#{pane_current_path}"
        bind '|' split-window -h -c "#{pane_current_path}"
        bind -T w-prefix w split-window -h -c "#{pane_current_path}"
        bind -T w-prefix d kill-pane
      '';
    };
  };
}
