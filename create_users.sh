#!/bin/bash

# Script som skapar användare, hemkataloger, undermappar
# och en personlig welcome.txt för varje användare.
# Endast root får köra scriptet.

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 username1 username2 username3"
    exit 1
fi

# Först: skapa alla användare
for user in "$@"; do
    if ! id "$user" >/dev/null 2>&1; then
        useradd -m "$user"
    fi
done

# Sedan: skapa mappar, sätt rättigheter och skriv welcome.txt
for user in "$@"; do
    home_dir="/home/$user"

    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    chown -R "$user:$user" "$home_dir"

    chmod 700 "$home_dir"
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    {
        echo "Välkommen $user"
        cut -d: -f1 /etc/passwd | grep -v "^$user$"
    } > "$home_dir/welcome.txt"

    chown "$user:$user" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done

exit 0
