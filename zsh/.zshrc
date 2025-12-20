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

# -----------------------------------------------------------------------------
# Path configuration
# -----------------------------------------------------------------------------

# Add local bin to path
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Load path configuration
[[ -f "$HOME/.zsh/path.zsh" ]] && source "$HOME/.zsh/path.zsh"

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # Write format: :start:elapsed;command
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Do not record duplicates
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_VERIFY            # Show command before executing from history

# -----------------------------------------------------------------------------
# Options
# -----------------------------------------------------------------------------

setopt AUTO_CD              # cd into directory without cd command
setopt AUTO_PUSHD           # Push directory onto stack on cd
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

setopt CORRECT              # Command correction
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------

autoload -Uz compinit
compinit -C

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection
zstyle ':completion:*' menu select

# Colorize completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# -----------------------------------------------------------------------------
# Key bindings
# -----------------------------------------------------------------------------

# Use emacs keybindings
bindkey -e

# Better history search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Word navigation
bindkey '^[[1;5C' forward-word    # Ctrl+Right
bindkey '^[[1;5D' backward-word   # Ctrl+Left

# -----------------------------------------------------------------------------
# Load modular configuration
# -----------------------------------------------------------------------------

# Core configuration files
for config_file in "$HOME"/.zsh/*.zsh; do
    [[ -f "$config_file" ]] && source "$config_file"
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
# Tool integrations
# -----------------------------------------------------------------------------

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# fzf
if command -v fzf &>/dev/null; then
    # fzf keybindings and completion
    if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
        source /opt/homebrew/opt/fzf/shell/completion.zsh
    elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
        source /usr/share/fzf/completion.zsh
    fi

    # fzf configuration with Catppuccin Frappe colors
    export FZF_DEFAULT_OPTS=" \
        --height 40% --layout=reverse --border \
        --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
        --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

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

# zsh-autosuggestions (fish-like suggestions)
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737994"  # Catppuccin Frappe overlay0
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
elif [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737994"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# zsh-syntax-highlighting (must be loaded last)
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -----------------------------------------------------------------------------
# Local overrides (machine-specific, not tracked in git)
# -----------------------------------------------------------------------------

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
