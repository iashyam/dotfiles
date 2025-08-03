#!/bin/bash

LID_STATE=$(cat /proc/acpi/button/lid/LID*/state | awk '{print $2}')
INTERNAL="eDP-1"

if [ "$LID_STATE" = "closed" ]; then
    hyprctl keyword monitor "$INTERNAL,disable"
else
    hyprctl keyword monitor "$INTERNAL,preferred,auto,1"
fi

