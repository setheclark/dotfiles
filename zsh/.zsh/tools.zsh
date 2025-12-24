# =============================================================================
# Tool integrations
# =============================================================================

# zoxide (smart cd)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# 1Password CLI completion
if command -v op &>/dev/null; then
    eval "$(op completion zsh)"; compdef _op op
fi

# GitHub CLI completion
if command -v gh &>/dev/null; then
    eval "$(gh completion -s zsh)"
fi
