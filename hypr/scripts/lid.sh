#!/bin/bash

lid_state=$(cat /proc/acpi/button/lid/LID0/state | grep -i open)

if [ -z "$lid_state" ]; then
  hyprctl keyword monitor "eDP-1,disable"
else
  hyprctl keyword monitor "eDP-1,1366x768@60,0x0,1"
fi

