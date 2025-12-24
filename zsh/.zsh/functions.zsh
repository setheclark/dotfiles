# =============================================================================
# Shell functions
# =============================================================================

# -----------------------------------------------------------------------------
# Directory operations
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find directory and cd into it using fzf
fcd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# -----------------------------------------------------------------------------
# File operations
# -----------------------------------------------------------------------------

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *.rar)     unrar x "$1" ;;
            *)         echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -----------------------------------------------------------------------------
# Git helpers
# -----------------------------------------------------------------------------

# Git commit browser using fzf
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

# Checkout git branch using fzf
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Git add with fzf
fadd() {
    local files
    files=$(git status -s | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}')
    [[ -n "$files" ]] && echo "$files" | xargs git add && git status -s
}

# -----------------------------------------------------------------------------
# Development helpers
# -----------------------------------------------------------------------------

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# JSON pretty print
json() {
    if [[ -p /dev/stdin ]]; then
        python3 -m json.tool
    else
        python3 -m json.tool "$1"
    fi
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill process by name (with confirmation)
pskill() {
    local pid
    pid=$(ps aux | grep -v grep | grep -i "$1" | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "Killing process: $1 (PID: $pid)"
        echo "$pid" | xargs kill -9
    else
        echo "No process found matching: $1"
    fi
}

# -----------------------------------------------------------------------------
# 1Password helpers
# -----------------------------------------------------------------------------

if command -v op &>/dev/null; then
    # Get a secret from 1Password
    # Usage: opsecret "vault/item/field"
    opsecret() {
        op read "op://$1"
    }

    # Export a secret as an environment variable
    # Usage: openv MY_VAR "vault/item/field"
    openv() {
        export "$1"=$(op read "op://$2")
    }
fi

# -----------------------------------------------------------------------------
# Utility
# -----------------------------------------------------------------------------

# Weather
weather() {
    curl "wttr.in/${1:-}"
}

# Cheatsheet
cheat() {
    curl "cheat.sh/$1"
}

# Quick note
note() {
    local notes_file="$HOME/.notes"
    if [[ -z "$1" ]]; then
        cat "$notes_file" 2>/dev/null
    else
        echo "$(date '+%Y-%m-%d %H:%M'): $*" >> "$notes_file"
    fi
}
