#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "ERROR"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "NO USERS"
    exit 1
fi

for user in "$@"; do

    home="/home/$user"

    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    chown -R "$user:$user" "$home"

    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    echo "Välkommen $user" > "$home/welcome.txt"
    echo "" >> "$home/welcome.txt"

    for u in "$@"; do
        if [ "$u" != "$user" ]; then
            echo "$u" >> "$home/welcome.txt"
        fi
    done

    chown "$user:$user" "$home/welcome.txt"
    chmod 600 "$home/welcome.txt"

done
