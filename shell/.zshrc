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
# Prompt Configuration
# ============================================
# Simple, clean prompt: [user@host:pwd]$
autoload -U colors && colors
setopt PROMPT_SUBST

# Tokyo Night inspired prompt colors
PROMPT='%F{cyan}[%f%F{green}%n%f%F{cyan}@%f%F{magenta}%m%f%F{cyan}:%f%F{blue}%~%f%F{cyan}]%f%F{yellow}$%f '

# Right prompt shows git branch if in repo
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f'
RPROMPT='${vcs_info_msg_0_}'

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

# Editor shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias m='micro'
alias f='lf'

# File listing
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltrh'           # Sort by time
alias lz='ls -lSrh'           # Sort by size

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias projects='cd ~/projects'
alias docs='cd ~/Documents'
alias dl='cd ~/Downloads'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline -10'
alias glog='git log --graph --oneline --decorate'
alias gb='git branch'
alias gco='git checkout'

# System
alias top='btop'
alias htop='htop'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Better defaults
alias cat='bat --theme=TwoDark 2>/dev/null || cat'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias mkdir='mkdir -pv'
alias rm='rm -Iv'
alias cp='cp -iv'
alias mv='mv -iv'

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

# Quick edit configs
alias zshrc='$EDITOR ~/.zshrc'
alias nvimrc='$EDITOR ~/.config/nvim/init.lua'
alias alacrittyrc='$EDITOR ~/.config/alacritty/alacritty.toml'

# Distrobox shortcuts
alias db='distrobox'
alias dbe='distrobox enter'
alias dbl='distrobox list'

# Misc
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# ============================================
# Functions
# ============================================

# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup of a file
backup() {
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# Find file by name
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directory by name
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Get weather
weather() {
    curl -s "wttr.in/${1:-}?format=3"
}

# Quick note taking
note() {
    if [ -z "$1" ]; then
        cat ~/Documents/notes.txt 2>/dev/null || echo "No notes found"
    else
        echo "$(date +"%Y-%m-%d %H:%M"): $*" >> ~/Documents/notes.txt
        echo "Note added."
    fi
}

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
if [[ -o interactive ]]; then
    echo ""
    echo "  Welcome to $(hostname) | $(date +'%A, %B %d %Y')"
    echo "  Kernel: $(uname -r) | Uptime: $(uptime -p | sed 's/up //')"
    echo ""
fi
