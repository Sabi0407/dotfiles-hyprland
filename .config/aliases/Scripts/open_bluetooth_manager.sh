#!/bin/bash

# Launch Blueman Manager temporarily without leaving the Blueman tray icon.

# Check if the Blueman applet is already running
if pgrep -x blueman-applet >/dev/null 2>&1; then
    applet_running_before=true
else
    applet_running_before=false
fi

# Start Blueman Manager and wait for it to close
blueman-manager &
manager_pid=$!
wait "$manager_pid"

# If the applet was spawned just for this session, terminate it
if [ "$applet_running_before" = false ]; then
    pkill -x blueman-applet >/dev/null 2>&1
fi
