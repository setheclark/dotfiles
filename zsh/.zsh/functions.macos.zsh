# =============================================================================
# Shell functions (macOS)
# =============================================================================

# Show hidden files in Finder
showfiles() {
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder
}

# Hide hidden files in Finder
hidefiles() {
    defaults write com.apple.finder AppleShowAllFiles -bool false
    killall Finder
}

# Quick Look a file
ql() {
    qlmanage -p "$@" &>/dev/null
}

# Open current directory in Finder
finder() {
    open "${1:-.}"
}

# Aerospace - list windows and focus
ff() {
  aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
}
