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

    # Skapa användare
    useradd -m "$user"

    home="/home/$user"

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
    echo "Välkommen $user" > "$home/welcome.txt"
    echo "" >> "$home/welcome.txt"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$home/welcome.txt"

    # Rättigheter på fil
    chown "$user:$user" "$home/welcome.txt"
    chmod 600 "$home/welcome.txt"

done
