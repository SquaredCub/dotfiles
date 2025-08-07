#!/bin/bash

# Function to extract the best mode from availableModes
get_best_mode() {
    local modes=("$@")
    local best_mode=""
    local best_pixels=0
    local best_refresh=0

    for mode in "${modes[@]}"; do
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

    echo "$best_mode"
}

monitors_json=$(hyprctl monitors -j)
mapfile -t monitor_names < <(echo "$monitors_json" | jq -r '.[].name')
mapfile -t monitor_modes < <(echo "$monitors_json" | jq -c '.[] | {name, availableModes}')

position_x=0

for monitor_info in "${monitor_modes[@]}"; do
    name=$(echo "$monitor_info" | jq -r '.name')
    modes_raw=$(echo "$monitor_info" | jq -r '.availableModes[]')

    mapfile -t modes_array <<< "$modes_raw"

    best_mode=$(get_best_mode "${modes_array[@]}")

    if [[ "$best_mode" =~ ([0-9]+)x([0-9]+)@([0-9.]+) ]]; then
        width="${BASH_REMATCH[1]}"
        height="${BASH_REMATCH[2]}"
        refresh="${BASH_REMATCH[3]}"
    else
        echo "Could not parse best mode for $name"
        continue
    fi

    echo "Configuring $name to ${width}x${height}@${refresh} at ${position_x}x0"
    
    # Correct syntax for hyprctl monitor dispatch
    hyprctl keyword monitor "$name,${width}x${height}@${refresh},${position_x}x0,1"

    position_x=$((position_x + width))
done
