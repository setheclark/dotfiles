# =============================================================================
# Homebrew plugins (macOS)
# =============================================================================

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
