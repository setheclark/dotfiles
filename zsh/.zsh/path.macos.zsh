# =============================================================================
# PATH configuration (macOS)
# =============================================================================

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------

if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# macOS SDK paths
# -----------------------------------------------------------------------------

# Android SDK (macOS location)
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"
fi
