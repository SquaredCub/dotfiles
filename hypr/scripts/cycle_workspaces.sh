#!/bin/bash

# Set workspace pairs
# e.g., (1,2), (3,4), (5,6), ...
# Adjust max pair count as needed
MAX_PAIR=5

# Get current monitor focus and workspace
ACTIVE_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

# Calculate current pair
PAIR_INDEX=$(( (ACTIVE_WORKSPACE - 1) / 2 + 1 ))

# Determine next pair
if [ "$1" == "prev" ]; then
  NEXT_PAIR=$((PAIR_INDEX - 1))
else
  NEXT_PAIR=$((PAIR_INDEX + 1))
fi

# Wrap around
if (( NEXT_PAIR < 1 )); then
  NEXT_PAIR=$MAX_PAIR
elif (( NEXT_PAIR > MAX_PAIR )); then
  NEXT_PAIR=1
fi

# Extract new workspace IDs
ODD_WS=$((NEXT_PAIR * 2 - 1))
EVEN_WS=$((NEXT_PAIR * 2))

# Get monitor names
MONITORS=($(hyprctl monitors -j | jq -r '.[].name'))
LEFT_MONITOR="${MONITORS[0]}"
RIGHT_MONITOR="${MONITORS[1]}"

# Dispatch workspaces to monitors
hyprctl dispatch workspace "$ODD_WS"
hyprctl dispatch workspace "$EVEN_WS"

# Focus whichever monitor was active before
if [[ "$ACTIVE_MONITOR" == "$LEFT_MONITOR" ]]; then
  hyprctl dispatch focusmonitor "$LEFT_MONITOR"
else
  hyprctl dispatch focusmonitor "$RIGHT_MONITOR"
fi
