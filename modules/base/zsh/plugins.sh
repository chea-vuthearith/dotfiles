zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

KEYTIMEOUT=1
zi ice lucid wait depth"1"
zi light zsh-users/zsh-completions

# Plugins
# Needs a clipboard tool; skipped on headless hosts (server).
if (( $+commands[wl-copy] || $+commands[xclip] || $+commands[xsel] )); then
  zi ice lucid wait depth"1"
  zi light "kutsan/zsh-system-clipboard"
fi

# Completion for every command (cd included): case-insensitive, then partial-word (f.b → foo.bar), then substring.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zi ice lucid wait depth"1"
zi light "Aloxaf/fzf-tab"

zi ice lucid wait depth"1"
zi light zsh-users/zsh-autosuggestions

zi ice lucid wait depth"1"
zi light zsh-users/zsh-syntax-highlighting

zi ice lucid wait depth"1"
zi snippet OMZP::git

# Needs notify-send; skipped on headless hosts (server).
if (( $+commands[notify-send] )); then
  AUTO_NOTIFY_IGNORE=("vi" "ssh" "btm" "fzf")
  zi ice lucid wait depth"1"
  zi light MichaelAquilina/zsh-auto-notify
fi
