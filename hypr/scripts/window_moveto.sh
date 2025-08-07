#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: Missing argument"
  echo "Usage: $0 <workspace_number>"
  exit 1
fi

# Get current monitor focus and workspace
ACTIVE_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '.pid')

# Target workspace ID (passed as $1)
TARGET_WS=$1

# Move current window silently
hyprctl dispatch movetoworkspacesilent "$TARGET_WS"

# Determine if the workspace is even or odd
if (( TARGET_WS % 2 == 0 )); then
  # Even: switch to paired odd first, then even
  hyprctl dispatch workspace $((TARGET_WS - 1))
  hyprctl dispatch workspace $TARGET_WS
else
  # Odd: switch to paired even first, then odd
  hyprctl dispatch workspace $((TARGET_WS + 1))
  hyprctl dispatch workspace $TARGET_WS
fi

# Refocus the original window
hyprctl dispatch focuswindow "$ACTIVE_WINDOW"