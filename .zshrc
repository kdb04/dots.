PROMPT='%n@%m:%~$ '

#P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

#env variables
export TERMINAL="kitty"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

export BUN_INSTALL="$HOME/.bun"

#path configs
typeset -U path PATH

path=(
  /opt/homebrew/bin 
  /opt/homebrew/opt/openjdk/bin/ 
  $HOME/.local/bin/ 
  $HOME/.cargo/bin/ 
  $BUN_INSTALL/bin/ 
  $HOME/.local/share/nvim/mason/bin/ 
  $GOBIN
  $path
)

#Oh My Zsh 
ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

#p10k config 

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#zsh plugins
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

#bun completions
[ -s "/Users/kdb/.bun/_bun" ] && source "/Users/kdb/.bun/_bun"

#utility functions 
copy_path() {
  pwd | pbcopy
  echo "📋 Path copied: $(pwd)"
}

#aliases
alias copypath='copy_path'

alias nvim='nvim -c "hi Normal guibg=NONE ctermbg=NONE | hi NormalNC guibg=NONE ctermbg=NONE | hi NormalFloat guibg=NONE ctermbg=NONE"'
alias susnow='pmset sleepnow'

alias icat='kitty +kitten icat'

alias tsc="tsc --noEmitOnError"

#zoxide
eval "$(zoxide init zsh)"
alias jump='z'

#bat
alias view='bat'

#eza
alias ls='eza --icons --group-directories-first --oneline'
alias tree='eza --tree --icons'

#yazi
alias files='yazi'

#fzf
export FZF_DEFAULT_OPTS="\
--height 80% \
--layout=reverse \
--border \
--preview 'bat --style=numbers --color=always --line-range :500 {}' \
--preview-window=right:60%:wrap"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz compinit
compinit

source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

zstyle ':fzf-tab:*' fzf-flags \
  --height=80% \
  --layout=reverse \
  --border \
  --preview-window=right:75%:wrap

zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -d $realpath ]] && eza --tree --level=2 $realpath || bat --style=numbers --color=always --line-range :500 $realpath'

#colorscheme
export LS_COLORS="$(vivid generate molokai)"

