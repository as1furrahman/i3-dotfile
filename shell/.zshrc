# Zsh Configuration

# ============================================================================
# HISTORY
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# ============================================================================
# ENVIRONMENT
# ============================================================================

export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox-esr"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Path
export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# OPTIONS
# ============================================================================

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ============================================================================
# PROMPT
# ============================================================================

autoload -Uz colors && colors
PROMPT='%F{blue}[%f%F{cyan}%n%f%F{blue}@%f%F{cyan}%m%f%F{blue}:%f%F{yellow}%~%f%F{blue}]%f %F{magenta}$%f '

# ============================================================================
# COMPLETIONS
# ============================================================================

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ============================================================================
# KEY BINDINGS
# ============================================================================

bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ============================================================================
# ALIASES
# ============================================================================

[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

# ============================================================================
# PLUGINS
# ============================================================================

# Autosuggestions
[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (must be last)
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
