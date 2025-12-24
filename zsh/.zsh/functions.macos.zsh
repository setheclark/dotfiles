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

# Flush DNS cache
flushdns() {
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo "DNS cache flushed"
}
