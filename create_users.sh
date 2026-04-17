#!/bin/bash

# Kontrollera att scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "Fel: endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Hämta lista över befintliga användare 
existing_users=$(cut -d: -f1 /etc/passwd)

# Loopa igenom alla användarnamn
for username in "$@"; do
    
    # Skapa användaren med hemkatalog
    useradd -m "$username"

    # Sätt variabel för hemkatalog
    home_dir="/home/$username"

    # Skapa mappar
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Sätt rätt ägare
    chown -R "$username:$username" "$home_dir"

    # Sätt rättigheter (endast ägaren)
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    # Skapa welcome.txt
    welcome_file="$home_dir/welcome.txt"

    echo "Välkommen $username" > "$welcome_file"
    echo "" >> "$welcome_file"
    echo "Andra användare i systemet:" >> "$welcome_file"
    echo "$existing_users" >> "$welcome_file"

    # Sätt rätt ägare på filen
    chown "$username:$username" "$welcome_file"

    echo "Användare $username skapad!"
done
