#!/bin/bash

# Check if Waybar is running
if pgrep -x "waybar" > /dev/null; then
  pkill waybar
else
  waybar &
fi

