# ============================================
# Zsh Configuration for Debian 13 + GNOME
# Optimized for Asus Zenbook S 13 OLED
# ============================================

# ============================================
# History Configuration
# ============================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicates
setopt HIST_FIND_NO_DUPS      # Don't display duplicates in search
setopt HIST_REDUCE_BLANKS     # Remove blanks from history
setopt HIST_VERIFY            # Show command before executing from history
setopt SHARE_HISTORY          # Share history between sessions
setopt APPEND_HISTORY         # Append to history file
setopt INC_APPEND_HISTORY     # Add commands immediately
setopt EXTENDED_HISTORY       # Add timestamps to history

# ============================================
# Environment Variables
# ============================================
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox-esr"
export PAGER="less"
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Path additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# AI Assistant API Key (get from https://platform.openai.com/api-keys)
# export OPENAI_API_KEY="your-api-key-here"

# Wayland-specific (for GNOME Wayland)
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland;xcb"

# ============================================
# Prompt Configuration (ArchCraft Theme)
# ============================================
autoload -U colors && colors
setopt PROMPT_SUBST

# Helper variables for the theme (Tokyo Night Minimal)
# Green -> #9ece6a, Yellow -> #e0af68, Red -> #f7768e, Cyan -> #7dcfff, Blue -> #7aa2f7, Gray -> #565f89
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{#565f89}(%F{#9ece6a}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{#565f89})%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{#e0af68}•%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Git Status Functions
parse_git_dirty() {
  if [[ -n $(git status --porcelain 2> /dev/null) ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${ref#refs/heads/}$(parse_git_dirty)${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}

# The ArchCraft Prompt (Tokyo Night Minimal)
# ❯❯  directory (branch •)
PROMPT='%F{#bb9af7}❯❯ %F{#7dcfff} %c%f$(git_prompt_info) '
RPROMPT=''

# ============================================
# Completion System
# ============================================
autoload -Uz compinit
compinit

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# ============================================
# Key Bindings
# ============================================
bindkey -e  # Emacs keybindings (prefer for shell navigation)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ============================================
# Options
# ============================================
setopt AUTO_CD              # cd without typing cd
setopt AUTO_PUSHD           # Push directory to stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack
setopt CORRECT              # Command correction
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt NO_BEEP              # Disable beep

# ============================================
# Aliases
# ============================================

# ============================================
# Aliases (ArchCraft Style)
# ============================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias /='cd /'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nano='micro'

# List files (Preferred: eza > exa > ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -al --icons --group-directories-first'
    alias lt='eza -aT --icons --group-directories-first'
elif command -v exa &>/dev/null; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -al --icons --group-directories-first'
    alias lt='exa -aT --icons --group-directories-first'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias l='ls -CF'
fi

alias l.='ls -d .*'

# Colorize grep output
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Safety
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# System
alias df='df -h'
alias free='free -h'
alias top='btop'


# Package management
alias update='sudo apt update && sudo apt upgrade -y'
alias install='sudo apt install'
alias remove='sudo apt remove'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias search='apt search'

# System info
alias myip='curl -s https://ipinfo.io/ip'
alias ports='ss -tulanp'
alias mem='free -h && echo && cat /proc/meminfo | head -5'
alias cpu='lscpu | head -20'

# Git (ArchCraft Style)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline -10'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git status'

# ============================================
# Load Plugins (if available)
# ============================================

# Zsh autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# Zsh syntax highlighting (must be last)
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ============================================
# Welcome Message
# ============================================
# Welcome Message
# ============================================
if [[ -o interactive ]]; then
    print -P ""
    print -P "  %F{#7aa2f7}Welcome to %F{#bb9af7}Debian%f"
    print -P "  %F{#f7768e}  Kernel:%f $(uname -r)"
    print -P "  %F{#7dcfff}  Uptime:%f $(uptime -p | sed 's/up //')"
    print -P "  %F{#7dcfff}  Shell: %f Zsh $ZSH_VERSION"
    print -P ""
fi

