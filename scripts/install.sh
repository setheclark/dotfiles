#!/usr/bin/env bash
#
# Main dotfiles installation script
# Run this after bootstrap.sh or directly if dependencies are already installed
#
# Usage: ./scripts/install.sh
# Environment: DOTFILES_MACHINE can be set to skip detection

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

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
# Ensure machine profile is set (ask if not)
# -----------------------------------------------------------------------------
setup_machine_profile() {
  source "$DOTFILES_DIR/scripts/detect-machine.sh"
  ensure_machine_profile
  info "Using machine profile: $DOTFILES_MACHINE"
}

# -----------------------------------------------------------------------------
# Install Homebrew packages (macOS)
# -----------------------------------------------------------------------------
install_brew_packages() {
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found, skipping brew packages"
    return 0
  fi

  info "Installing Homebrew packages..."

  # Install common packages
  if [[ -f "$DOTFILES_DIR/homebrew/Brewfile.common" ]]; then
    info "Installing common packages..."
    brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile.common" || warn "Some common packages failed to install"
  fi

  # Install profile-specific packages
  case "$DOTFILES_MACHINE" in
  macos-personal)
    if [[ -f "$DOTFILES_DIR/homebrew/Brewfile.personal" ]]; then
      info "Installing personal packages..."
      brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile.personal" || warn "Some personal packages failed to install"
    fi
    ;;
  macos-work)
    if [[ -f "$DOTFILES_DIR/homebrew/Brewfile.work" ]]; then
      info "Installing work packages..."
      brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile.work" || warn "Some work packages failed to install"
    fi
    ;;
  esac

  success "Homebrew packages installed"
}

# -----------------------------------------------------------------------------
# Install packages for Linux
# -----------------------------------------------------------------------------
install_linux_packages() {
  if [[ "$DOTFILES_MACHINE" != "linux" ]]; then
    return 0
  fi

  info "Installing Linux packages..."

  # Detect package manager and install common tools
  if command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y \
      zsh \
      neovim \
      fzf \
      ripgrep \
      bat \
      stow \
      curl \
      git
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm \
      zsh \
      neovim \
      fzf \
      ripgrep \
      bat \
      stow \
      curl \
      git
  fi

  # Install starship if not present
  if ! command -v starship &>/dev/null; then
    info "Installing starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  success "Linux packages installed"
}

# -----------------------------------------------------------------------------
# Backup existing files that would conflict with stow
# -----------------------------------------------------------------------------
backup_conflicts() {
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
  )

  # macOS window management packages
  if [[ "$DOTFILES_MACHINE" == macos-* ]]; then
    packages+=(
      # "aerospace"
      "sketchybar"
      "borders"
      "karabiner"
      "amethyst"
    )
  fi

  # Add fish if the user wants to experiment with it
  if [[ -d "$DOTFILES_DIR/fish" ]]; then
    packages+=("fish")
  fi

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
# Setup SSH directory and permissions
# -----------------------------------------------------------------------------
setup_ssh() {
  info "Setting up SSH configuration..."

  # Ensure ~/.ssh exists with correct permissions
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # Create sockets directory for ControlMaster
  mkdir -p "$HOME/.ssh/sockets"
  chmod 700 "$HOME/.ssh/sockets"

  # Create config.d directory if it doesn't exist (stow might not create empty dirs)
  mkdir -p "$HOME/.ssh/config.d"
  chmod 700 "$HOME/.ssh/config.d"

  # Set correct permissions on config files
  if [[ -f "$HOME/.ssh/config" ]]; then
    chmod 600 "$HOME/.ssh/config"
  fi

  # Set permissions on config.d files
  for f in "$HOME/.ssh/config.d"/*.conf; do
    [[ -f "$f" ]] && chmod 600 "$f"
  done

  # Create config.local if it doesn't exist
  if [[ ! -f "$HOME/.ssh/config.local" ]]; then
    if [[ -f "$DOTFILES_DIR/local/.ssh.config.local.example" ]]; then
      cp "$DOTFILES_DIR/local/.ssh.config.local.example" "$HOME/.ssh/config.local"
      chmod 600 "$HOME/.ssh/config.local"
      success "Created ~/.ssh/config.local from template"
    else
      # Create empty file so Include doesn't complain
      touch "$HOME/.ssh/config.local"
      chmod 600 "$HOME/.ssh/config.local"
    fi
  else
    chmod 600 "$HOME/.ssh/config.local"
    info "~/.ssh/config.local already exists, skipping"
  fi

  success "SSH configuration complete"
}

# -----------------------------------------------------------------------------
# Install Catppuccin themes for bat and delta
# -----------------------------------------------------------------------------
setup_catppuccin_themes() {
  info "Setting up Catppuccin themes..."

  # Install bat themes
  if command -v bat &>/dev/null; then
    local bat_themes_dir="$(bat --config-dir)/themes"
    mkdir -p "$bat_themes_dir"

    # Download Catppuccin Frappe theme for bat if not present
    if [[ ! -f "$bat_themes_dir/Catppuccin Frappe.tmTheme" ]]; then
      info "Downloading Catppuccin Frappe theme for bat..."
      curl -sLo "$bat_themes_dir/Catppuccin Frappe.tmTheme" \
        "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Frappe.tmTheme" &&
        bat cache --build &>/dev/null &&
        success "Installed Catppuccin theme for bat" ||
        warn "Failed to download bat theme"
    else
      info "Catppuccin theme for bat already installed"
    fi
  fi

  success "Catppuccin themes setup complete"
}

# -----------------------------------------------------------------------------
# Setup macOS window management tools
# -----------------------------------------------------------------------------
setup_macos_wm() {
  if [[ "$DOTFILES_MACHINE" != macos-* ]]; then
    return 0
  fi

  info "Setting up macOS window management..."

  # Make sketchybar plugins executable
  if [[ -d "$HOME/.config/sketchybar/plugins" ]]; then
    chmod +x "$HOME/.config/sketchybar/plugins/"*.sh 2>/dev/null || true
    success "Made sketchybar plugins executable"
  fi

  # Make borders config executable
  if [[ -f "$HOME/.config/borders/bordersrc" ]]; then
    chmod +x "$HOME/.config/borders/bordersrc"
    success "Made borders config executable"
  fi

  # Make sketchybar config executable
  if [[ -f "$HOME/.config/sketchybar/sketchybarrc" ]]; then
    chmod +x "$HOME/.config/sketchybar/sketchybarrc"
  fi

  # Make sketchybar colors script executable
  if [[ -f "$HOME/.config/sketchybar/colors.sh" ]]; then
    chmod +x "$HOME/.config/sketchybar/colors.sh"
  fi

  # Start services if installed
  if command -v sketchybar &>/dev/null; then
    if ! brew services list | grep -q "sketchybar.*started"; then
      info "Starting sketchybar service..."
      brew services start sketchybar 2>/dev/null || warn "Failed to start sketchybar"
    else
      info "Restarting sketchybar to apply config..."
      brew services restart sketchybar 2>/dev/null || true
    fi
  fi

  if command -v borders &>/dev/null; then
    if ! brew services list | grep -q "borders.*started"; then
      info "Starting borders service..."
      brew services start borders 2>/dev/null || warn "Failed to start borders"
    else
      info "Restarting borders to apply config..."
      brew services restart borders 2>/dev/null || true
    fi
  fi

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

  # Add conditional includes to .gitconfig.local
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
# Offer to run macOS defaults (macOS only)
# -----------------------------------------------------------------------------
offer_macos_defaults() {
  if [[ "$DOTFILES_MACHINE" != macos-* ]]; then
    return 0
  fi

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
  echo ""
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}  Installation complete!${NC}"
  echo -e "${GREEN}════════════════════════════════════════${NC}"
  echo ""
  echo "Machine profile: $DOTFILES_MACHINE"
  echo ""

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
  echo -e "${BLUE}  Dotfiles Installation${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"
  echo ""

  setup_machine_profile
  setup_xdg_dirs

  case "$DOTFILES_MACHINE" in
  macos-*)
    install_brew_packages
    ;;
  linux)
    install_linux_packages
    ;;
  esac

  stow_packages
  setup_ssh
  setup_catppuccin_themes
  setup_macos_wm
  setup_git_config
  setup_local_files
  setup_1password
  set_default_shell
  offer_macos_defaults
  post_install
}

main "$@"
