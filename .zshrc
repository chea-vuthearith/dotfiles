### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
    print -P "%F{33} %F{34}Installation successful.%f%b" || \
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk

### Plugins

# vi-mode
zi ice depth"1"; zi light chea-vuthearith/zsh-vi-mode
zi ice depth"1"; zi snippet OMZL::clipboard.zsh

function zvm_get_cutbuffer() {
  clippaste
}

function zvm_set_cutbuffer() {
  echo -n $1 | clipcopy
}

# starship
export STARSHIP_CONFIG="$HOME/dotfiles/starship/starship.toml"
eval "$(starship init zsh)"
zle-line-init() {

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='$(STARSHIP_CONFIG=~/dotfiles/starship/config-transient.toml starship prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="$STARSHIP_CMD_STATUS" --pipestatus="${STARSHIP_PIPE_STATUS[*]}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
  PROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}

# fzf
zi ice depth"1" wait"2" lucid; zi snippet OMZP::fzf
zi ice depth"1"; zi light Aloxaf/fzf-tab

export FZF_DEFAULT_OPTS="--bind=tab:accept -i -s"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

export CARAPACE_BRIDGES='zsh'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^@' fzf-tab-complete

zi ice depth"1" wait"2" lucid; zi light zsh-users/zsh-syntax-highlighting

zi ice depth"1" wait"2" lucid; zi light z-shell/zsh-lsd

zi ice depth"1" wait"2" lucid; zi light zsh-users/zsh-autosuggestions

zi ice depth"1"; zi snippet OMZP::git

 ### End of plugins
 # # pyenv
 # export PYENV_ROOT="$HOME/.pyenv"
 # export PATH="$PYENV_ROOT/bin:$PATH"
 # zsh-defer eval "$(pyenv init -)" 

 # aliases
 alias py="python3"
 # alias nixsw="nixos-rebuild switch"
 # alias homesw="home-manager switch"

 # biome
 export BIOME_CONFIG_PATH="$HOME/dotfiles/nvim"

 # #fnm 
 # zsh-defer eval "$(fnm env --use-on-cd --shell zsh)"

 # pager
 export PAGER="less -X -F"

 # editor
 export EDITOR="nvim"

 # launch hyprland on login
 source ~/dotfiles/zshrc.d/auto-Hypr.sh

 #pnpm
 export PNPM_HOME="/root/.local/share/pnpm"
 case ":$PATH:" in
   *":$PNPM_HOME:"*) ;;
   *) export PATH="$PNPM_HOME:$PATH" ;;
 esac

 timezsh() {
   shell=${1-$SHELL}
   for i in $(seq 1 10); do time $shell -i -c exit; done
 }

pfwd() {
  if [ $# -ne 2 ]; then
    echo "Usage: pfwd <port> <host>"
    return 1
  fi
  ssh -fNL "$1":localhost:"$1" "$2"
}

serveo() {
  if [ $# -ne 1 ]; then
    echo "Usage: serveo <port>"
    return 1
  fi
  ssh -R chea:80:localhost:"$1" serveo.net
}

keychain --eval $(find ~/.ssh/deployment-keys/ -type f ! -name "*.pub") > /dev/null 2>&1
