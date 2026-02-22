# disable j k for history, its annoying
bindkey -M vicmd -r 'j'
bindkey -M vicmd -r 'k'

bindkey -M viins '^n' fzf-history-widget
bindkey -M viins '^p' fzf-history-widget
