# =============================================================================
# PATH configuration
# =============================================================================

# This file sets up the PATH variable with commonly needed directories.
# Machine-specific paths should go in ~/.zshrc.local

# -----------------------------------------------------------------------------
# Core paths
# -----------------------------------------------------------------------------

# Local binaries take priority
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# Development tools
# -----------------------------------------------------------------------------

# Go
if [[ -d "$HOME/go" ]]; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

# Rust
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Node.js (via nvm or fnm)
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi

if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# Python (pyenv)
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Ruby (rbenv)
if [[ -d "$HOME/.rbenv" ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# Java (SDKMAN)
if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Android SDK (macOS location)
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"
fi

# -----------------------------------------------------------------------------
# Deduplicate PATH
# -----------------------------------------------------------------------------

typeset -U PATH  # Remove duplicates (zsh built-in)
