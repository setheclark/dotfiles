#!/usr/bin/env bash
#
# Bootstrap script for dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/USERNAME/dotfiles/main/scripts/bootstrap.sh | bash
#
# This script:
# 1. Installs minimal dependencies (Xcode CLI tools, Homebrew, gh)
# 2. Asks which machine profile to use
# 3. Clones the dotfiles repo
# 4. Runs the full installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_REPO="git@github.com:USERNAME/dotfiles.git"  # Update with your repo
DOTFILES_DIR="$HOME/git/dotfiles"

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      error "Unsupported operating system" ;;
    esac
}

OS=$(detect_os)
info "Detected OS: $OS"

# -----------------------------------------------------------------------------
# Ask for machine profile and save it
# -----------------------------------------------------------------------------
ask_machine_profile() {
    echo ""
    echo -e "${BLUE}Which machine profile should be used?${NC}"
    echo ""
    echo "  1) macos-personal  - Personal MacBook"
    echo "  2) macos-work      - Work MacBook"
    echo "  3) linux           - Linux machine (Omarchy)"
    echo ""

    while true; do
        read -p "Enter choice [1-3]: " choice
        case $choice in
            1) DOTFILES_MACHINE="macos-personal"; break ;;
            2) DOTFILES_MACHINE="macos-work"; break ;;
            3) DOTFILES_MACHINE="linux"; break ;;
            *) echo "Please enter 1, 2, or 3" ;;
        esac
    done

    # Save to file for future use
    echo "$DOTFILES_MACHINE" > "$HOME/.dotfiles-machine"
    success "Saved profile: $DOTFILES_MACHINE"
    export DOTFILES_MACHINE
}

# -----------------------------------------------------------------------------
# macOS: Install Xcode Command Line Tools
# -----------------------------------------------------------------------------
install_xcode_cli() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi

    if xcode-select -p &>/dev/null; then
        success "Xcode CLI tools already installed"
        return 0
    fi

    info "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to complete
    echo "Waiting for Xcode CLI tools installation..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    success "Xcode CLI tools installed"
}

# -----------------------------------------------------------------------------
# macOS: Install Homebrew
# -----------------------------------------------------------------------------
install_homebrew() {
    if [[ "$OS" != "macos" ]]; then
        return 0
    fi

    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    success "Homebrew installed"
}

# -----------------------------------------------------------------------------
# Linux: Install base dependencies
# -----------------------------------------------------------------------------
install_linux_deps() {
    if [[ "$OS" != "linux" ]]; then
        return 0
    fi

    info "Installing base dependencies..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y git curl stow
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm git curl stow
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git curl stow
    else
        warn "Unknown package manager. Please install git, curl, and stow manually."
    fi

    success "Base dependencies installed"
}

# -----------------------------------------------------------------------------
# Install GitHub CLI
# -----------------------------------------------------------------------------
install_gh() {
    if command -v gh &>/dev/null; then
        success "GitHub CLI already installed"
        return 0
    fi

    info "Installing GitHub CLI..."

    if [[ "$OS" == "macos" ]]; then
        brew install gh
    elif [[ "$OS" == "linux" ]]; then
        if command -v apt-get &>/dev/null; then
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y gh
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm github-cli
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y gh
        fi
    fi

    success "GitHub CLI installed"
}

# -----------------------------------------------------------------------------
# Authenticate with GitHub
# -----------------------------------------------------------------------------
auth_github() {
    if gh auth status &>/dev/null; then
        success "Already authenticated with GitHub"
        return 0
    fi

    info "Authenticating with GitHub..."
    echo "Please follow the prompts to authenticate with GitHub."
    echo "This is required to clone your private dotfiles repository."
    echo ""

    gh auth login

    success "GitHub authentication complete"
}

# -----------------------------------------------------------------------------
# Clone dotfiles repository
# -----------------------------------------------------------------------------
clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        success "Dotfiles already cloned at $DOTFILES_DIR"
        info "Pulling latest changes..."
        git -C "$DOTFILES_DIR" pull
        return 0
    fi

    info "Cloning dotfiles repository..."

    # Create parent directory if needed
    mkdir -p "$(dirname "$DOTFILES_DIR")"

    # Clone the repository
    gh repo clone "$DOTFILES_REPO" "$DOTFILES_DIR" || git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

    success "Dotfiles cloned to $DOTFILES_DIR"
}

# -----------------------------------------------------------------------------
# Run full installation
# -----------------------------------------------------------------------------
run_install() {
    info "Running full installation..."

    cd "$DOTFILES_DIR"

    # Make scripts executable
    chmod +x scripts/*.sh

    # Run install (profile is already saved to ~/.dotfiles-machine)
    ./scripts/install.sh

    success "Installation complete!"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        Dotfiles Bootstrap Script       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    ask_machine_profile

    if [[ "$OS" == "macos" ]]; then
        install_xcode_cli
        install_homebrew
    else
        install_linux_deps
    fi

    install_gh
    auth_github
    clone_dotfiles
    run_install

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Bootstrap complete! Restart your    ║${NC}"
    echo -e "${GREEN}║    terminal to apply all changes.      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

main "$@"
