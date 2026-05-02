# =============================================================================
# Homebrew plugins (macOS)
# =============================================================================

# Ensure brew is on PATH before checking for plugins. Kept here (rather than in
# path.zsh) so this file is self-contained regardless of module load order.
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)

    # zsh-autosuggestions
    if [[ -f "$BREW_PREFIX"/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source "$BREW_PREFIX"/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737994"  # Catppuccin Frappe overlay0
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    fi

    # zsh-syntax-highlighting (must be sourced last)
    if [[ -f "$BREW_PREFIX"/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source "$BREW_PREFIX"/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi
