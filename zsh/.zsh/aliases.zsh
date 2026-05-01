# =============================================================================
# Shell aliases
# =============================================================================

# -----------------------------------------------------------------------------
# Navigation
# -----------------------------------------------------------------------------

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias dt="cd ~/Desktop"
alias dl="cd ~/Downloads"
alias dev="cd ~/dev"

# -----------------------------------------------------------------------------
# List files (use eza if available, otherwise ls)
# -----------------------------------------------------------------------------

alias l=ll

if command -v eza &>/dev/null; then
    alias ls="eza"
    alias ll="eza -la --git"
    alias la="eza -a"
    alias lt="eza -la --sort=modified"
    alias tree="eza --tree"
else
    alias ls="ls --color=auto"
    alias ll="ls -lah"
    alias la="ls -a"
    alias lt="ls -laht"
fi

# -----------------------------------------------------------------------------
# Common tools with better defaults
# -----------------------------------------------------------------------------

# Use bat instead of cat if available
if command -v bat &>/dev/null; then
    alias cat="bat --paging=never"
    alias catp="bat"  # bat with paging
fi

# Grep with color
alias grep="grep --color=auto"

# Make with parallel jobs
alias make="make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)"

# Disk usage
alias df="df -h"
alias du="du -h"

# -----------------------------------------------------------------------------
# Git (see also git config for more aliases)
# -----------------------------------------------------------------------------

alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate"
alias grb="git rebase"

# Lazygit if available
if command -v lazygit &>/dev/null; then
    alias lg="lazygit"
fi

# -----------------------------------------------------------------------------
# Rust / Cargo
# -----------------------------------------------------------------------------

alias cb="cargo build"
alias cbr="cargo build --release"
alias ct="cargo test"
alias cr="cargo run"
alias crr="cargo run --release"
alias cc="cargo check"
alias ccl="cargo clippy"
alias cfmt="cargo fmt"

# -----------------------------------------------------------------------------
# Editor
# -----------------------------------------------------------------------------

alias v="nvim"
alias vim="nvim"

# -----------------------------------------------------------------------------
# Dotfiles management
# -----------------------------------------------------------------------------

alias dots="cd $DOTFILES_DIR"
alias dotsrc="source ~/.zshrc"
alias dotsedit="nvim $DOTFILES_DIR"

# -----------------------------------------------------------------------------
# Safety nets
# -----------------------------------------------------------------------------

# alias rm="rm -i"
# alias mv="mv -i"
# alias cp="cp -i"

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print \$1}'"

# -----------------------------------------------------------------------------
# Misc
# -----------------------------------------------------------------------------

# Clear screen and scrollback
alias cls="clear && printf '\e[3J'"

# Quick edit common files
alias zshrc="$EDITOR ~/.zshrc"
alias gitconfig="$EDITOR ~/.gitconfig"

# Reload shell
alias reload="exec $SHELL -l"

# Show path entries on separate lines
alias path='echo $PATH | tr ":" "\n"'

alias h=history
alias p=pwd
