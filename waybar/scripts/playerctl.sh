#!/bin/bash

player_status=$(playerctl -p spotify status 2> /dev/null)

if [ "$player_status" = "Playing" ]; then
    icon="▶"
elif [ "$player_status" = "Paused" ]; then
    icon="❚❚"
else
    echo ""
    exit
fi

artist=$(playerctl -p spotify metadata artist 2> /dev/null)
title=$(playerctl -p spotify metadata title 2> /dev/null)

if [ -n "$artist" ] && [ -n "$title" ]; then
    text="$artist - $title"
    max_length=50

    if [ ${#text} -gt $max_length ]; then
        # Create scrolling effect
        scroll_file="/tmp/waybar_scroll_pos"
        scroll_pos=0

        if [ -f "$scroll_file" ]; then
            scroll_pos=$(cat "$scroll_file")
        fi

        # Add spacing for marquee effect
        marquee_text="$text    +++    "
        text_len=${#marquee_text}

        # Get substring for display
        display_text=""
        for ((i=0; i<$max_length; i++)); do
            char_pos=$(( (scroll_pos + i) % text_len ))
            display_text="${display_text}${marquee_text:$char_pos:1}"
        done

        # Increment scroll position (scroll 4 characters at a time)
        scroll_pos=$(( (scroll_pos + 4) % text_len ))
        echo "$scroll_pos" > "$scroll_file"

        text="$display_text"
    fi

    echo "{\"text\":\"$icon $text\", \"tooltip\":\"$artist - $title\", \"class\":\"$player_status\"}"
else
    echo ""
fi
