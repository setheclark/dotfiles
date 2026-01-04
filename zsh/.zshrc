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

# Load machine profile if saved
if [[ -f "$HOME/.dotfiles-machine" ]]; then
    export DOTFILES_MACHINE=$(cat "$HOME/.dotfiles-machine")
fi

# Add local bin to path
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------------------------------------------------------
# Load modular configuration
# -----------------------------------------------------------------------------

# Source all .zsh files, handling OS-specific variants
for config_file in "$HOME"/.zsh/*.zsh; do
    [[ -f "$config_file" ]] || continue

    case "$config_file" in
        *.macos.zsh)
            [[ "$OSTYPE" == darwin* ]] && source "$config_file"
            ;;
        *.linux.zsh)
            [[ "$OSTYPE" == linux* ]] && source "$config_file"
            ;;
        *)
            source "$config_file"
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Machine-specific configuration
# -----------------------------------------------------------------------------

case "$DOTFILES_MACHINE" in
    macos-work)
        [[ -f "$HOME/.zsh/work.zsh" ]] && source "$HOME/.zsh/work.zsh"
        ;;
    macos-personal)
        [[ -f "$HOME/.zsh/personal.zsh" ]] && source "$HOME/.zsh/personal.zsh"
        ;;
    linux)
        [[ -f "$HOME/.zsh/linux.zsh" ]] && source "$HOME/.zsh/linux.zsh"
        ;;
esac

# -----------------------------------------------------------------------------
# Local overrides (machine-specific, not tracked in git)
# -----------------------------------------------------------------------------

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# bun completions
[ -s "/Users/sethclark/.bun/_bun" ] && source "/Users/sethclark/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
