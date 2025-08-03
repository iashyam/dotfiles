#!/bin/bash

direction="$1"

# Get current workspace ID
current_ws=$(hyprctl activeworkspace -j | jq '.id')

# Get active workspaces (non-empty)
active_workspaces=($(hyprctl workspaces -j | jq '[.[] | select(.windows > 0) | .id] | sort | .[]'))

# If no active workspaces, exit
[ ${#active_workspaces[@]} -eq 0 ] && exit

# Try to find index of current workspace
current_index=-1
for i in "${!active_workspaces[@]}"; do
    if [[ "${active_workspaces[$i]}" -eq "$current_ws" ]]; then
        current_index=$i
        break
    fi
done

# If current workspace is not in the list (empty), pick default index
if [[ "$current_index" -eq -1 ]]; then
    if [[ "$direction" == "prev" ]]; then
        target_index=$((${#active_workspaces[@]} - 1))
    else
        target_index=0
    fi
else
    # Move to next or previous
    if [[ "$direction" == "prev" ]]; then
        target_index=$(( (current_index - 1 + ${#active_workspaces[@]}) % ${#active_workspaces[@]} ))
    else
        target_index=$(( (current_index + 1) % ${#active_workspaces[@]} ))
    fi
fi

target_ws=${active_workspaces[$target_index]}

# Switch to that workspace
hyprctl dispatch workspace "$target_ws"

