# =============================================================================
# Shell options, history, completion, and key bindings
# =============================================================================

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

setopt DOT_GLOB

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
