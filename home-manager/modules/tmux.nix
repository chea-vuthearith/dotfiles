{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
      vim-tmux-navigator
      sensible
      yank
    ];
    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

      unbind C-b
      set -g prefix M-w
      bind M-w send-prefix

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set -g @catppuccin_flavour 'mocha'

      set -g @vim_navigator_mapping_left "C-h"
      set -g @vim_navigator_mapping_right "C-l"
      set -g @vim_navigator_mapping_up "C-k"
      set -g @vim_navigator_mapping_down "C-j"
      set -g @vim_navigator_mapping_prev ""  # removes the C-\ binding

      # set vi-mode
      set-window-option -g mode-keys vi
      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind '-' split-window -v -c "#{pane_current_path}"
      bind '|' split-window -h -c "#{pane_current_path}"
    '';
  };
}
