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

# Java default: JDK 21 (override SDKMAN/system default if available).
# Use `jdk` to switch interactively in a shell.
if [[ -x "/usr/libexec/java_home" ]]; then
    _java_default="$(/usr/libexec/java_home -v 21 2>/dev/null)"
    if [[ -n "$_java_default" ]]; then
        export JAVA_HOME="$_java_default"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
    unset _java_default
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
