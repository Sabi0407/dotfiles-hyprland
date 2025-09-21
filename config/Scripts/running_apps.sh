#!/bin/bash
apps=$(ps -e -o cmd | grep -E 'discord|Telegram|steam|spotify|com.spotify.Client|signal|slack|teams|skype|obsidian|thunderbird|element|zoom|chromium|firefox|brave|vivaldi|org.telegram.desktop|org.signal.Signal|org.mozilla.firefox|org.chromium.Chromium|com.slack.Slack|com.skype.Client|com.obsidian.Obsidian|com.github.IsmaelMartinez.teams_for_linux|com.github.wwmm.pulseeffects|com.github.tchx84.Flatseal' | grep -v grep | sort | uniq)

if [ -n "$apps" ]; then
    echo "$apps" | sed 's/&/\&amp;/g'
fi 