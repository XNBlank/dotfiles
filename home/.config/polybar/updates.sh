#!/bin/bash
pac=$(checkupdates | wc -l)
aur=$(cower -u | wc -l)

check=$((pac + aur))

if [[ $check < 26 ]]
then
    echo "$pac %{F#5b5b5b}%{F-} $aur"
elif [[ $check > 25 ]]
then
    echo "$pac %{F#cc5b5b}%{F-} $aur"
fi