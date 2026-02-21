zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Plugins
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_INIT_MODE=sourcing
KEYTIMEOUT=1
zi ice lucid wait depth"1" atload"init_after_zvm"
zi light jeffreytse/zsh-vi-mode
init_after_zvm() {
  bindkey -M viins '^n' history-or-complete
  bindkey -M viins '^p' history-or-complete

}

zi ice lucid wait depth"1"
zi light zsh-users/zsh-completions

init_autocomplete() {
  bindkey -M vicmd '^P' fzf-history-widget
  bindkey -M vicmd '^N' fzf-history-widget
  bindkey -M menuselect '^N' menu-complete
  bindkey -M menuselect '^P' reverse-menu-complete
  bindkey -M menuselect '^I' complete-word
  bindkey -M viins '^I' complete-word

  # remove j and k for history, its annoying
  bindkey -M vicmd -r 'j'
  bindkey -M vicmd -r 'k'
}
zi ice lucid wait depth"1" atload"init_autocomplete"
zi light marlonrichert/zsh-autocomplete

# Autocomplete styling
zstyle ':autocomplete:*' list-lines 8
zstyle ':autocomplete:*' list-position below
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' delay 0.2

zi ice lucid wait depth"1"
zi light zsh-users/zsh-autosuggestions

zi ice lucid wait depth"1"
zi snippet OMZP::fzf

zi ice lucid depth"1" wait
zi light zsh-users/zsh-syntax-highlighting

zi ice lucid depth"1" wait
zi light z-shell/zsh-lsd

zi ice lucid depth"1" wait
zi snippet OMZP::git

zi ice lucid wait
zi light romkatv/zsh-defer

zi ice lucid wait depth"1"
zi light chisui/zsh-nix-shell
