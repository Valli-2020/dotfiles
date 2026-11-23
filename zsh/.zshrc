# eigene Skripte und Spicetify (~/.local/bin)
typeset -U path
path=($HOME/.local/bin $path)

# Arch has no /etc/zsh/zshrc: keypad mode + Home/End/Delete must be set here
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  zle-line-init()   { echoti smkx }
  zle-line-finish() { echoti rmkx }
  zle -N zle-line-init; zle -N zle-line-finish
fi
bindkey -e
[[ -n ${terminfo[khome]} ]] && bindkey ${terminfo[khome]} beginning-of-line
[[ -n ${terminfo[kend]}  ]] && bindkey ${terminfo[kend]}  end-of-line
[[ -n ${terminfo[kdch1]} ]] && bindkey ${terminfo[kdch1]} delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

typeset -U path

autoload -Uz compinit && compinit
zstyle ":completion:*" menu select
alias ls="ls --color=auto"
alias grep="grep --color=auto"

source ~/.zsh/plugins/zsh-z/zsh-z.plugin.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Prompt: starship (preset pastel-powerline, ~/.config/starship.toml)
eval "$(starship init zsh)"
# must be sourced last
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
