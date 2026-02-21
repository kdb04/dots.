PROMPT='%n@%m:%~$ '

#P10K Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export TERMINAL="kitty"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#plugins
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

copy_path() {
  pwd | pbcopy
  echo "📋 Path copied: $(pwd)"
}
alias copypath='copy_path'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

#aliases
alias nvim='nvim -c "hi Normal guibg=NONE ctermbg=NONE | hi NormalNC guibg=NONE ctermbg=NONE | hi NormalFloat guibg=NONE ctermbg=NONE"'
alias susnow='pmset sleepnow'
***REMOVED***
***REMOVED***

# bun completions
[ -s "/Users/kdb/.bun/_bun" ] && source "/Users/kdb/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias tsc="tsc --noEmitOnError"

#zoxide
eval "$(zoxide init zsh)"
alias jump='z'

#bat
alias view='bat'

#fzf
export FZF_DEFAULT_OPTS="\
--height 40% \
--layout=reverse \
--border \
--preview 'bat --style=numbers --color=always --line-range :500 {}' \
--preview-window=right:60%:wrap"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz compinit
compinit

source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

zstyle ':fzf-tab:*' fzf-flags --preview-window=right:60%:wrap
zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -d $realpath ]] && eza --tree --level=2 $realpath || bat --style=numbers --color=always --line-range :500 $realpath'

#colorscheme
export LS_COLORS="$(vivid generate molokai)"

#eza
alias ls='eza --icons --group-directories-first --oneline'
alias tree='eza --tree --icons'
