#!/bin/bash

# Kontrollera root
if [ "$EUID" -ne 0 ]; then
    echo "Run as root"
    exit 1
fi

# Kontrollera input
if [ $# -eq 0 ]; then
    echo "No users provided"
    exit 1
fi

# Loop
for user in "$@"; do

    # Kontrollera om användaren redan finns
    if id "$user" &>/dev/null; then
        echo "WARNING: User already exists"
        continue
    fi

    # Skapa användare
    useradd -m "$user"

    home="/home/$user"

    # Kontrollera att hemkatalogen skapades
    if [ ! -d "$home" ]; then
        echo "ERROR: Home directory not created"
        continue
    fi

    # Skapa mappar
    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    # Sätt ägare
    chown -R "$user:$user" "$home"

    # Sätt rättigheter
    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    # Skapa welcome.txt
    welcome="$home/welcome.txt"
    echo "Välkommen $user" > "$welcome"
    echo "" >> "$welcome"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$welcome"

    # Rättigheter på fil (FIX: $welcome not $welcom!)
    chmod 600 "$welcome"
    chown "$user:$user" "$welcome"

done
