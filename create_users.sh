#!/bin/bash

# Script som skapar användare från argument,
# bygger upp deras hemkataloger och skriver en welcome.txt.
# Endast root får köra scriptet.

# Kontrollera att scriptet körs som root
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst ett användarnamn skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Loopa igenom alla användare som skickats in
for username in "$@"; do
    # Spara vilka användare som redan finns innan den nya användaren skapas
    existing_users="$(cut -d: -f1 /etc/passwd)"

    # Skapa användaren med hemkatalog och privat grupp
    if ! id "$username" >/dev/null 2>&1; then
        useradd -m -U "$username"
    fi

    home_dir="/home/$username"

    # Skapa undermappar med rätt ägare och rättigheter
    install -d -m 700 -o "$username" -g "$username" "$home_dir/Documents"
    install -d -m 700 -o "$username" -g "$username" "$home_dir/Downloads"
    install -d -m 700 -o "$username" -g "$username" "$home_dir/Work"

    # Skapa welcome.txt
    {
        echo "Välkommen $username"
        echo "$existing_users" | grep -vx "$username"
    } > "$home_dir/welcome.txt"

    # Sätt ägare och rättigheter på welcome.txt
    chown "$username:$username" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done
