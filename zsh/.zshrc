# =============================================================================
# Dotfiles - Main zsh configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------

export DOTFILES_DIR="$HOME/git/dotfiles"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Add local bin to path
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# Load modular configuration
# -----------------------------------------------------------------------------

# Source all .zsh files
for config_file in "$HOME"/.zsh/*.zsh; do
    [[ -f "$config_file" ]] && source "$config_file"
done

# -----------------------------------------------------------------------------
# Local overrides (machine-specific, not tracked in git)
# -----------------------------------------------------------------------------

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
