#!/bin/bash

# Claude Code Notification Tool
# Sends system push notifications when Claude needs user input

# Configuration
ICON_PATH="$HOME/.claude-code-notifier/icon.png"

# Check if terminal-notifier is installed
check_notifier() {
  if ! command -v terminal-notifier &>/dev/null; then
    echo "Error: terminal-notifier not found"
    echo "Please run install.sh first"
    exit 1
  fi
}

# Send notification
send_notification() {
  local title="$1"
  local message="$2"
  local sound="${3:-default}"

  check_notifier

  # Build notification command arguments
  local args=(-title "$title" -message "$message" -sound "$sound")

  # Add icon parameter if icon exists
  if [ -f "$ICON_PATH" ]; then
    args+=(-appIcon "$ICON_PATH")
  fi

  # Activate terminal window
  args+=(-activate com.mitchellh.ghostty)

  # Send notification
  terminal-notifier "${args[@]}"
}

# Send different notifications based on scenario
case "${1:-default}" in
"input")
  send_notification "Claude Code Needs Input" "Claude is waiting for your response" "Ping"
  ;;
"choice")
  send_notification "Claude Code Needs Choice" "Claude needs you to make a decision" "Ping"
  ;;
"complete")
  send_notification "Claude Code Task Complete" "Task completed, please check results" "Glass"
  ;;
"error")
  send_notification "Claude Code Error" "An error occurred during execution" "Basso"
  ;;
"question")
  send_notification "Claude Code Has Question" "Claude needs more information" "Ping"
  ;;
"custom")
  # Custom notification: ./notify.sh custom "title" "message" "sound-optional"
  send_notification "${2:-Claude Code}" "${3:-New notification}" "${4:-default}"
  ;;
*)
  send_notification "Claude Code" "New message to review" "default"
  ;;
esac
