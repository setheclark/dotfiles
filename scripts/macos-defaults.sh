#!/usr/bin/env bash
#
# macOS System Preferences
# Sets sensible defaults for macOS
#
# Usage:
#   ./scripts/macos-defaults.sh          # Run all settings
#   ./scripts/macos-defaults.sh --help   # Show categories
#   ./scripts/macos-defaults.sh dock     # Run specific category
#
# Note: Some changes require logout/restart to take effect
#
# Based on:
#   https://mths.be/macos
#   https://macos-defaults.com

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is for macOS only"
    exit 1
fi

# =============================================================================
# General UI/UX
# =============================================================================
setup_general() {
    info "Setting up General UI/UX preferences..."

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Disable automatic capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Disable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    success "General UI/UX preferences set"
}

# =============================================================================
# Keyboard
# =============================================================================
setup_keyboard() {
    info "Setting up Keyboard preferences..."

    # Enable full keyboard access for all controls (Tab in dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2

    # Set short delay until key repeat
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    success "Keyboard preferences set"
}

# =============================================================================
# Trackpad
# =============================================================================
setup_trackpad() {
    info "Setting up Trackpad preferences..."

    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Enable three-finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

    # Disable "natural" (inverted) scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    success "Trackpad preferences set"
}

# =============================================================================
# Dock
# =============================================================================
setup_dock() {
    info "Setting up Dock preferences..."

    # Set icon size
    defaults write com.apple.dock tilesize -int 48

    # Enable magnification
    defaults write com.apple.dock magnification -bool true
    defaults write com.apple.dock largesize -int 64

    # Minimize windows using scale effect
    defaults write com.apple.dock mineffect -string "scale"

    # Minimize windows into their application icon
    defaults write com.apple.dock minimize-to-application -bool true

    # Don't show recent applications
    defaults write com.apple.dock show-recents -bool false

    # Auto-hide the Dock
    defaults write com.apple.dock autohide -bool true

    # Remove auto-hide delay
    defaults write com.apple.dock autohide-delay -float 0

    # Speed up hide/show animation
    defaults write com.apple.dock autohide-time-modifier -float 0.3

    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    success "Dock preferences set"
}

# =============================================================================
# Finder
# =============================================================================
setup_finder() {
    info "Setting up Finder preferences..."

    # Show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files on network and USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in all Finder windows by default
    # Four-letter codes: icnv (icon), clmv (column), glyv (gallery), Nlsv (list)
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Show the ~/Library folder
    chflags nohidden ~/Library

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes

    # Expand File Info panes: General, Open with, Sharing & Permissions
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true \
        OpenWith -bool true \
        Privileges -bool true

    success "Finder preferences set"
}

# =============================================================================
# Safari
# =============================================================================
setup_safari() {
    info "Setting up Safari preferences..."

    # Show the full URL in the address bar
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Enable the Develop menu and Web Inspector
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Add context menu item for showing Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

    # Disable AutoFill
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    # Enable "Do Not Track"
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    success "Safari preferences set"
}

# =============================================================================
# Terminal
# =============================================================================
setup_terminal() {
    info "Setting up Terminal preferences..."

    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4

    # Enable Secure Keyboard Entry in Terminal.app
    defaults write com.apple.terminal SecureKeyboardEntry -bool true

    success "Terminal preferences set"
}

# =============================================================================
# Activity Monitor
# =============================================================================
setup_activity_monitor() {
    info "Setting up Activity Monitor preferences..."

    # Show the main window when launching
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Show all processes
    defaults write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    success "Activity Monitor preferences set"
}

# =============================================================================
# Screenshots
# =============================================================================
setup_screenshots() {
    info "Setting up Screenshot preferences..."

    # Save screenshots to ~/Screenshots
    mkdir -p "$HOME/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Screenshots"

    # Save screenshots in PNG format (options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true

    success "Screenshot preferences set"
}

# =============================================================================
# App Store
# =============================================================================
setup_app_store() {
    info "Setting up App Store preferences..."

    # Enable automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Check for updates daily
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Install System data files and security updates
    defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

    success "App Store preferences set"
}

# =============================================================================
# TextEdit
# =============================================================================
setup_textedit() {
    info "Setting up TextEdit preferences..."

    # Use plain text mode for new documents
    defaults write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    success "TextEdit preferences set"
}

# =============================================================================
# Menu Bar (for Sketchybar)
# =============================================================================
setup_menubar() {
    info "Setting up Menu Bar preferences..."

    # Automatically hide and show the menu bar
    defaults write NSGlobalDomain _HIHideMenuBar -bool true

    success "Menu Bar preferences set"
    warn "The default menu bar will be hidden (using Sketchybar instead)"
}

# =============================================================================
# Energy & Power
# =============================================================================
setup_energy() {
    info "Setting up Energy preferences..."

    # Enable lid wake
    sudo pmset -a lidwake 1

    # Sleep display after 10 minutes on battery
    sudo pmset -b displaysleep 10

    # Sleep display after 15 minutes on power
    sudo pmset -c displaysleep 15

    # Disable machine sleep while on charger
    sudo pmset -c sleep 0

    # Set machine sleep to 10 minutes on battery
    sudo pmset -b sleep 10

    success "Energy preferences set"
}

# =============================================================================
# Kill affected applications
# =============================================================================
restart_apps() {
    info "Restarting affected applications..."

    local apps=(
        "Activity Monitor"
        "cfprefsd"
        "Dock"
        "Finder"
        "Safari"
        "SystemUIServer"
    )

    for app in "${apps[@]}"; do
        killall "${app}" &>/dev/null || true
    done

    success "Applications restarted"
}

# =============================================================================
# Help
# =============================================================================
show_help() {
    echo ""
    echo "macOS Defaults Script"
    echo ""
    echo "Usage: $0 [category...]"
    echo ""
    echo "Categories:"
    echo "  general      - General UI/UX settings"
    echo "  keyboard     - Keyboard settings"
    echo "  trackpad     - Trackpad settings"
    echo "  dock         - Dock settings"
    echo "  finder       - Finder settings"
    echo "  safari       - Safari settings"
    echo "  terminal     - Terminal settings"
    echo "  activity     - Activity Monitor settings"
    echo "  screenshots  - Screenshot settings"
    echo "  appstore     - App Store settings"
    echo "  textedit     - TextEdit settings"
    echo "  menubar      - Menu Bar settings (hide for Sketchybar)"
    echo "  energy       - Energy & Power settings"
    echo ""
    echo "  all          - Run all categories (default)"
    echo ""
    echo "Examples:"
    echo "  $0              # Run all settings"
    echo "  $0 dock finder  # Run only dock and finder settings"
    echo ""
}

# =============================================================================
# Main
# =============================================================================
main() {
    # Show help
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  macOS Defaults${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""

    warn "This script will modify macOS system preferences."
    warn "Some changes require logout or restart to take effect."
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    echo ""

    # Close System Preferences to prevent conflicts
    osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

    # If no arguments, run all
    if [[ $# -eq 0 ]] || [[ "$1" == "all" ]]; then
        setup_general
        setup_keyboard
        setup_trackpad
        setup_dock
        setup_finder
        setup_safari
        setup_terminal
        setup_activity_monitor
        setup_screenshots
        setup_app_store
        setup_textedit
        setup_menubar
        setup_energy
    else
        # Run specific categories
        for category in "$@"; do
            case "$category" in
                general)     setup_general ;;
                keyboard)    setup_keyboard ;;
                trackpad)    setup_trackpad ;;
                dock)        setup_dock ;;
                finder)      setup_finder ;;
                safari)      setup_safari ;;
                terminal)    setup_terminal ;;
                activity)    setup_activity_monitor ;;
                screenshots) setup_screenshots ;;
                appstore)    setup_app_store ;;
                textedit)    setup_textedit ;;
                menubar)     setup_menubar ;;
                energy)      setup_energy ;;
                *)
                    warn "Unknown category: $category"
                    ;;
            esac
        done
    fi

    echo ""
    read -p "Restart affected applications? [y/N] " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_apps
    fi

    echo ""
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}  macOS defaults applied!${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "Note: Some changes may require logout or restart."
    echo ""
}

main "$@"
