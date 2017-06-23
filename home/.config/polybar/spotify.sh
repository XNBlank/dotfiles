#!/bin/bash

if [ "$(playerctl status >>/dev/null 2>&1; echo $?)" == "1" ]
then
        echo "Spotify is not open... "
        exit 0
fi

if [ "$(playerctl status)" == "Playing" ]
then
        title=$(playerctl metadata xesam:title)
        artist=$(playerctl metadata xesam:artist)
        echo "$title | $artist" | zscroll -n -a " " -b " " -d 0.2 
else
        echo "Not playing... "
fi