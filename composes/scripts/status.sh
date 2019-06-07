#!/usr/bin/env bash

# check if stdout is a terminal...
if test -t 1; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
    fi
fi

docker-compose -f composes/docker-compose-devnet.yml up status 2>&1 | grep '|' | awk -F "|" '/1/ {print ">>" $2}' | sed 's,YES,'"$bold$underline$green"'YES'"$normal"',' | sed 's,NO,'"$bold$underline$red"'NO'"$normal"','
