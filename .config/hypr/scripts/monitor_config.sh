#!/bin/bash

# Load monitor info
monitors_json=$(hyprctl monitors -j)

# Read all monitor JSON objects into an array
mapfile -t monitor_objs < <(echo "$monitors_json" | jq -c '.[]')

# Handle "swap" argument
if [[ "$1" == "swap" ]]; then
    echo "Swapping monitor order"
    # Reverse the array safely
    mapfile -t monitor_objs < <(printf "%s\n" "${monitor_objs[@]}" | tac)
fi

# Configuration loop
position_x=0
for mon in "${monitor_objs[@]}"; do
    name=$(echo "$mon" | jq -r '.name')
    modes_raw=$(echo "$mon" | jq -r '.availableModes[]')
    mapfile -t modes_array <<< "$modes_raw"

    # Get best mode
    best_mode=""
    best_pixels=0
    best_refresh=0
    for mode in "${modes_array[@]}"; do
        if [[ "$mode" =~ ([0-9]+)x([0-9]+)@([0-9.]+)Hz ]]; then
            width="${BASH_REMATCH[1]}"
            height="${BASH_REMATCH[2]}"
            refresh_float="${BASH_REMATCH[3]}"
            refresh_int=$(printf "%.0f" "$(echo "$refresh_float * 100" | awk '{ printf "%.0f", $1 }')")
            pixels=$((width * height))
            if (( pixels > best_pixels || (pixels == best_pixels && refresh_int > best_refresh) )); then
                best_pixels=$pixels
                best_refresh=$refresh_int
                best_mode="${width}x${height}@${refresh_float}"
            fi
        fi
    done

    if [[ "$best_mode" =~ ([0-9]+)x([0-9]+)@([0-9.]+) ]]; then
        width="${BASH_REMATCH[1]}"
        height="${BASH_REMATCH[2]}"
        refresh="${BASH_REMATCH[3]}"
    else
        echo "Could not parse best mode for $name"
        continue
    fi

    echo "Configuring $name to ${width}x${height}@${refresh} at ${position_x}x0"
    hyprctl keyword monitor "$name,${width}x${height}@${refresh},${position_x}x0,1"
    position_x=$((position_x + width))
done
