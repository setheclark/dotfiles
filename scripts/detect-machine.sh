#!/usr/bin/env bash
#
# Machine profile script
# Reads saved profile or prompts user to select one
#
# Usage:
#   source detect-machine.sh  # Sets DOTFILES_MACHINE
#   detect-machine.sh         # Prints current profile
#   detect-machine.sh --set   # Force re-selection

DOTFILES_MACHINE_FILE="$HOME/.dotfiles-machine"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Prompt user to select machine profile
# -----------------------------------------------------------------------------
ask_machine_profile() {
    echo ""
    echo -e "${BLUE}Which machine profile should be used?${NC}"
    echo ""
    echo "  1) macos-personal  - Personal MacBook"
    echo "  2) macos-work      - Work MacBook"
    echo "  3) linux           - Linux machine"
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

    # Save the choice
    echo "$DOTFILES_MACHINE" > "$DOTFILES_MACHINE_FILE"
    echo -e "${GREEN}Saved profile: $DOTFILES_MACHINE${NC}"
    export DOTFILES_MACHINE
}

# -----------------------------------------------------------------------------
# Get current profile (read from file or ask)
# -----------------------------------------------------------------------------
get_machine_profile() {
    # Check if already set in environment
    if [[ -n "$DOTFILES_MACHINE" ]]; then
        return 0
    fi

    # Check if saved to file
    if [[ -f "$DOTFILES_MACHINE_FILE" ]]; then
        DOTFILES_MACHINE=$(cat "$DOTFILES_MACHINE_FILE")
        export DOTFILES_MACHINE
        return 0
    fi

    # Not set - need to ask
    ask_machine_profile
}

# -----------------------------------------------------------------------------
# Ensure profile is set (for use in other scripts)
# -----------------------------------------------------------------------------
ensure_machine_profile() {
    get_machine_profile

    if [[ -z "$DOTFILES_MACHINE" ]]; then
        echo "Error: Could not determine machine profile" >&2
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# If run with --set, force re-selection
if [[ "$1" == "--set" ]]; then
    ask_machine_profile
    exit 0
fi

# If run directly (not sourced), print the profile
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_machine_profile
    echo "$DOTFILES_MACHINE"
fi
