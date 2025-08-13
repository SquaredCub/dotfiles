#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Error: Missing argument"
  echo "Usage: $0 <workspace_number>"
  exit 1
fi

# Get current monitor focus and workspace
ACTIVE_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

# Get monitor names
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))
LEFT_MONITOR="${MONITORS[0]}"
RIGHT_MONITOR="${MONITORS[1]}"

# Target workspace ID (passed as $1)
TARGET_WS=$1

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