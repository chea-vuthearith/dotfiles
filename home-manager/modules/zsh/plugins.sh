zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

KEYTIMEOUT=1
zi ice lucid wait depth"1"
zi light zsh-users/zsh-completions

# Plugins
zi ice lucid wait depth"1"
zi light "kutsan/zsh-system-clipboard"

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zi ice lucid wait depth"1"
zi light "Aloxaf/fzf-tab"

zi ice lucid wait depth"1"
zi light zsh-users/zsh-autosuggestions

zi ice lucid wait depth"1"
zi light zsh-users/zsh-syntax-highlighting

zi ice lucid wait depth"1"
zi snippet OMZP::git

AUTO_NOTIFY_IGNORE=("vi" "tmux" "ssh" "sst" "btm" "sesh" "fzf")
zi ice lucid wait depth"1"
zi light MichaelAquilina/zsh-auto-notify
