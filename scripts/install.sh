#!/usr/bin/env bash
#
# Unified macOS dotfiles installation script
# Idempotent - safe to run multiple times
#
# Usage:
#   Fresh install: curl -fsSL <url> | bash
#   Update: ./scripts/install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/initial"
INSTALL_MARKER="$HOME/.dotfiles-installed"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# -----------------------------------------------------------------------------
# Install Xcode Command Line Tools (prerequisite for macOS development)
# -----------------------------------------------------------------------------
install_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    success "Xcode Command Line Tools already installed"
    return 0
  fi

  info "Installing Xcode Command Line Tools..."
  xcode-select --install

  # Wait for installation to complete
  until xcode-select -p &>/dev/null; do
    sleep 5
  done

  success "Xcode Command Line Tools installed"
}

# -----------------------------------------------------------------------------
# Install Homebrew (macOS package manager)
# -----------------------------------------------------------------------------
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    return 0
  fi

  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for current session
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  success "Homebrew installed"
}

# -----------------------------------------------------------------------------
# Install GitHub CLI
# -----------------------------------------------------------------------------
install_gh() {
  if command -v gh &>/dev/null; then
    success "GitHub CLI already installed"
    return 0
  fi

  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping GitHub CLI install"
    return 0
  fi

  info "Installing GitHub CLI..."
  brew install gh
  success "GitHub CLI installed"
}

# -----------------------------------------------------------------------------
# Authenticate with GitHub
# -----------------------------------------------------------------------------
auth_github() {
  if ! command -v gh &>/dev/null; then
    warn "GitHub CLI not found, skipping GitHub auth"
    return 0
  fi

  if gh auth status &>/dev/null; then
    success "Already authenticated with GitHub"
    return 0
  fi

  info "Authenticating with GitHub..."
  gh auth login
  success "GitHub authentication complete"
}

# -----------------------------------------------------------------------------
# Install Homebrew packages
# -----------------------------------------------------------------------------
install_brew_packages() {
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping brew packages"
    return 0
  fi

  info "Installing Homebrew packages..."

  if [[ -f "$DOTFILES_DIR/homebrew/Brewfile" ]]; then
    brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile" --no-lock || warn "Some packages failed to install"
    success "Homebrew packages installed"
  else
    warn "Brewfile not found at $DOTFILES_DIR/homebrew/Brewfile"
  fi
}

# -----------------------------------------------------------------------------
# Backup existing files that would conflict with stow
# -----------------------------------------------------------------------------
backup_conflicts() {
  # Skip if backup already exists (idempotency)
  if [[ -d "$BACKUP_DIR" ]]; then
    return 0
  fi

  local package="$1"
  local dominated=false

  cd "$DOTFILES_DIR"

  # Find all files in the package
  while IFS= read -r -d '' file; do
    # Get the relative path from the package directory
    local rel_path="${file#$DOTFILES_DIR/$package/}"
    local target="$HOME/$rel_path"

    # Check if target exists and is NOT already a symlink to our dotfiles
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
      # Create backup directory if this is the first conflict
      if [[ "$dominated" == false ]]; then
        mkdir -p "$BACKUP_DIR"
        dominated=true
      fi

      # Create parent directory in backup location
      mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"

      # Move existing file to backup
      mv "$target" "$BACKUP_DIR/$rel_path"
      warn "Backed up: ~/$rel_path -> $BACKUP_DIR/$rel_path"

    elif [[ -L "$target" ]]; then
      # It's a symlink - check if it points to our dotfiles
      local link_target=$(readlink "$target")
      if [[ "$link_target" != *"$DOTFILES_DIR"* ]]; then
        # Symlink points elsewhere - back it up too
        if [[ "$dominated" == false ]]; then
          mkdir -p "$BACKUP_DIR"
          dominated=true
        fi
        mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
        mv "$target" "$BACKUP_DIR/$rel_path"
        warn "Backed up symlink: ~/$rel_path -> $BACKUP_DIR/$rel_path"
      fi
    fi
  done < <(find "$DOTFILES_DIR/$package" -type f -print0)
}

# -----------------------------------------------------------------------------
# Stow packages
# -----------------------------------------------------------------------------
stow_packages() {
  info "Stowing dotfiles packages..."

  cd "$DOTFILES_DIR"

  # List of packages to stow
  local packages=(
    "zsh"
    "git"
    "nvim"
    "starship"
    "ssh"
    "bat"
    "lazygit"
    "ghostty"
    "tmux"
    "zellij"
    "claude"
    "claude-code-notifier"
    # window management packages
    "aerospace"
    "sketchybar"
    "borders"
    "karabiner"

  )

  for package in "${packages[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
      info "Stowing $package..."

      # Backup any existing files that would conflict
      backup_conflicts "$package"

      # Now stow the package
      stow -v --restow --target="$HOME" "$package" 2>&1 | grep -v "^LINK:" || true
      success "Stowed $package"
    else
      warn "Package $package not found, skipping"
    fi
  done

  # Notify user if backups were made
  if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    warn "Existing config files were backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
  fi
}

# -----------------------------------------------------------------------------
# Setup tmux plugin manager (TPM)
# -----------------------------------------------------------------------------
setup_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [ -d "$tpm_dir" ]; then
    success "TPM (tmux plugin manager) already installed"
    return 0
  fi

  info "Installing TPM (tmux plugin manager)..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  success "TPM installed — open tmux and press prefix + I to install plugins"
}

# -----------------------------------------------------------------------------
# Setup Rust toolchain via rustup
# -----------------------------------------------------------------------------
setup_rust() {
  info "Setting up Rust toolchain..."

  if command -v rustc &>/dev/null || [[ -f "$HOME/.cargo/bin/rustc" ]]; then
    success "Rust toolchain already installed, skipping"
    return 0
  fi

  if ! command -v rustup-init &>/dev/null; then
    warn "rustup-init not found (install via Brewfile), skipping Rust setup"
    return 0
  fi

  rustup-init -y --no-modify-path
  source "$HOME/.cargo/env"
  rustup component add rustfmt clippy
  success "Rust toolchain installed"
}

# -----------------------------------------------------------------------------
# Setup macOS window management tools
# -----------------------------------------------------------------------------
setup_macos_wm() {
  info "Setting up macOS window management tools..."

  # Sketchybar setup
  curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.51/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
  # SbarLua
  rm -rf /tmp/SbarLua
  (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

  # Remind about accessibility permissions
  echo ""
  warn "Accessibility permissions required:"
  echo "  System Settings → Privacy & Security → Accessibility"
  echo "  Grant access to:"
  echo "    - AeroSpace (window management)"
  echo "    - Karabiner-Elements (keyboard remapping)"
  echo "    - Karabiner-EventViewer (optional, for debugging)"
  echo ""

  success "macOS window management setup complete"
}

# -----------------------------------------------------------------------------
# Setup git configuration interactively
# -----------------------------------------------------------------------------
setup_git_config() {
  info "Setting up git configuration..."

  # Check if gitconfig.local already exists
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    info "~/.gitconfig.local already exists"
    read -p "Reconfigure git settings? [y/N] " -n 1 -r </dev/tty
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi
  fi

  echo ""
  info "Let's configure your git identity"
  echo ""

  # Prompt for name
  local git_name=""
  while [[ -z "$git_name" ]]; do
    read -p "Your full name: " git_name </dev/tty
  done

  # Prompt for email
  local git_email=""
  while [[ -z "$git_email" ]]; do
    read -p "Your email address: " git_email </dev/tty
  done

  # Create gitconfig.local
  cat >"$HOME/.gitconfig.local" <<EOF
# =============================================================================
# Local git configuration - Machine-specific settings
# =============================================================================
# This file is NOT tracked by git.

[user]
    name = $git_name
    email = $git_email
EOF
  success "Created ~/.gitconfig.local with your identity"

  # Ask about work machine setup
  echo ""
  read -p "Is this a work machine? [y/N] " -n 1 -r </dev/tty
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    setup_git_work_config
  fi
}

# -----------------------------------------------------------------------------
# Setup work-specific git configuration
# -----------------------------------------------------------------------------
setup_git_work_config() {
  echo ""
  info "Setting up work git configuration"
  echo ""

  # Prompt for work email
  local work_email=""
  while [[ -z "$work_email" ]]; do
    read -p "Your work email address: " work_email </dev/tty
  done

  # Prompt for company GitHub org/username
  local company_name=""
  while [[ -z "$company_name" ]]; do
    echo ""
    echo "Enter your company's GitHub organization or username."
    echo "Example: If your work repos are at github.com/company/*, enter 'company'"
    read -p "Company GitHub org/username: " company_name </dev/tty
  done

  # Create gitconfig.work
  cat >"$HOME/.gitconfig.work" <<EOF
# =============================================================================
# Work git configuration
# =============================================================================
# This file is automatically included for repos owned by: $company_name
# This file is NOT tracked by git.

[user]
    email = $work_email
EOF
  success "Created ~/.gitconfig.work with work email"

  # Add conditional includes to .gitconfig.local (guard against duplicates)
  if ! grep -qF "gitconfig.work" "$HOME/.gitconfig.local"; then
    cat >>"$HOME/.gitconfig.local" <<EOF

# -----------------------------------------------------------------------------
# Work repository configuration
# Automatically uses work email for repos owned by: $company_name
# -----------------------------------------------------------------------------

# SSH remotes: git@github.com:$company_name/*
[includeIf "hasconfig:remote.*.url:git@github.com:$company_name/**"]
    path = ~/.gitconfig.work

# HTTPS remotes: https://github.com/$company_name/*
[includeIf "hasconfig:remote.*.url:https://github.com/$company_name/**"]
    path = ~/.gitconfig.work
EOF
  fi

  success "Configured conditional work identity for $company_name repos"
  echo ""
  info "Git will automatically use your work email ($work_email)"
  info "for any repo with a remote at github.com/$company_name/*"
}

# -----------------------------------------------------------------------------
# Setup local override files
# -----------------------------------------------------------------------------
setup_local_files() {
  info "Setting up local override files..."

  # Create .zshrc.local if it doesn't exist
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    if [[ -f "$DOTFILES_DIR/local/.zshrc.local.example" ]]; then
      cp "$DOTFILES_DIR/local/.zshrc.local.example" "$HOME/.zshrc.local"
      success "Created ~/.zshrc.local from template"
    fi
  else
    info "~/.zshrc.local already exists, skipping"
  fi
}

# -----------------------------------------------------------------------------
# Setup 1Password CLI integration
# -----------------------------------------------------------------------------
setup_1password() {
  if ! command -v op &>/dev/null; then
    warn "1Password CLI not found. Install it to enable secrets integration."
    return 0
  fi

  if op account list &>/dev/null 2>&1; then
    success "1Password CLI already configured"
  else
    info "1Password CLI found but not configured"
    echo ""
    echo "To configure 1Password CLI, run:"
    echo "  op account add"
    echo ""
    echo "Then you can use 'op' to inject secrets into your environment."
  fi
}

# -----------------------------------------------------------------------------
# Set default shell to zsh
# -----------------------------------------------------------------------------
set_default_shell() {
  local current_shell=$(basename "$SHELL")

  if [[ "$current_shell" == "zsh" ]]; then
    success "Default shell is already zsh"
    return 0
  fi

  info "Changing default shell to zsh..."

  local zsh_path=$(which zsh)

  # Ensure zsh is in /etc/shells
  if ! grep -q "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$zsh_path"
  success "Default shell changed to zsh"
}

# -----------------------------------------------------------------------------
# Create XDG directories
# -----------------------------------------------------------------------------
setup_xdg_dirs() {
  info "Setting up XDG directories..."

  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.cache"

  success "XDG directories created"
}

# -----------------------------------------------------------------------------
# Offer to run macOS defaults
# -----------------------------------------------------------------------------
offer_macos_defaults() {
  if [[ ! -f "$DOTFILES_DIR/scripts/macos-defaults.sh" ]]; then
    return 0
  fi

  echo ""
  info "macOS defaults script available"
  echo "  This sets system preferences (Dock, Finder, keyboard, etc.)"
  echo ""
  read -p "Run macOS defaults script now? [y/N] " -n 1 -r </dev/tty
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$DOTFILES_DIR/scripts/macos-defaults.sh"
  else
    echo ""
    echo "You can run it later with:"
    echo "  $DOTFILES_DIR/scripts/macos-defaults.sh"
    echo ""
  fi
}

# -----------------------------------------------------------------------------
# Post-install message
# -----------------------------------------------------------------------------
post_install() {
  # Create installation marker
  date +%Y-%m-%d > "$INSTALL_MARKER"

  echo ""
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Installation complete!${NC}"
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo ""

  # Show install/update status
  if [[ -f "$INSTALL_MARKER" ]]; then
    echo "Last installed: $(cat "$INSTALL_MARKER")"
    echo ""
  fi

  # Mention backups if they were created
  if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${YELLOW}Backups:${NC}"
    echo "  Your existing config files were backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
    echo "  Review and delete when no longer needed:"
    echo "  rm -rf $BACKUP_DIR"
    echo ""
  fi

  echo "Next steps:"
  echo "  1. Restart your terminal or run: source ~/.zshrc"
  echo "  2. Edit ~/.zshrc.local for machine-specific settings"
  echo ""

  if ! command -v op &>/dev/null; then
    echo "Optional:"
    echo "  - Install 1Password CLI for secrets management"
    echo ""
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  echo ""
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}  macOS Dotfiles Installation${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo ""

  # Prerequisites (idempotent)
  install_xcode_cli
  install_homebrew
  install_gh
  auth_github

  # Setup
  setup_xdg_dirs
  install_brew_packages
  stow_packages
  setup_tpm
  setup_rust
  setup_macos_wm
  setup_git_config
  setup_local_files
  setup_1password
  set_default_shell
  offer_macos_defaults

  post_install
}

main "$@"
