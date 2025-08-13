#!/bin/bash

scripts_dir="$HOME/.config/hypr/scripts"

# Use --only-show-match so Tab will insert the highlighted choice into the input
choice=$(ls "$scripts_dir" \
    | wofi --dmenu --allow-markup --only-show-match --prompt "Select script (Tab for args)" --print-input-text)

# If the choice matches an existing script exactly → run with no args
if [ -f "$scripts_dir/$choice" ]; then
    "$SHELL" -c "$scripts_dir/$choice"
else
    # Otherwise assume "scriptname args"
    script=$(echo "$choice" | awk '{print $1}')
    args=$(echo "$choice" | cut -d" " -f2-)
    "$SHELL" -c "$scripts_dir/$script $args"
fi
