#!/bin/bash

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

# Loopa igenom alla användarnamn
for user in "$@"
do
    # Spara användare som redan finns innan den nya användaren skapas
    old_users=$(cut -d: -f1 /etc/passwd)

    # Skapa användaren och hemkatalogen
    if ! id "$user" >/dev/null 2>&1; then
        useradd --badname -m "$user" 2>/dev/null || useradd -m "$user"
    fi

    # Skapa mappar i hemkatalogen
    mkdir -p "/home/$user/Documents"
    mkdir -p "/home/$user/Downloads"
    mkdir -p "/home/$user/Work"

    # Sätt ägare på hemkatalog och undermappar
    chown -R "$user:$user" "/home/$user"

    # Sätt rättigheter så endast ägaren har åtkomst
    chmod 700 "/home/$user"
    chmod 700 "/home/$user/Documents"
    chmod 700 "/home/$user/Downloads"
    chmod 700 "/home/$user/Work"

    # Skapa welcome.txt
    echo "Välkommen $user" > "/home/$user/welcome.txt"
    echo "$old_users" | grep -v "^$user$" >> "/home/$user/welcome.txt"

    # Sätt ägare och rättigheter på welcome.txt
    chown "$user:$user" "/home/$user/welcome.txt"
    chmod 600 "/home/$user/welcome.txt"
done
