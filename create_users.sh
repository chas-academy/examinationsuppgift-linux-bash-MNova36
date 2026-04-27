#!/bin/bash

# Jag kontrollerar om scriptet körs som root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script as root"
    exit 1
fi

# Jag kollar om användarnamn har skickats in
if [ $# -eq 0 ]; then
    echo "ERROR: No users provided"
    exit 1
fi

# Jag går igenom alla användare en i taget
for user in "$@"
do
    echo "Creating user: $user"

    # Jag kollar om användaren redan finns
    if id "$user" &>/dev/null; then
        echo "WARNING: User already exists"
        continue
    fi

    # Jag skapar en ny användare med hemkatalog
    useradd -m "$user"

    # Jag sparar hemkatalogens sökväg
    home="/home/$user"

    # Jag kollar att hemkatalogen finns
    if [ ! -d "$home" ]; then
        echo "ERROR: Home directory not created"
        continue
    fi

    # Jag skapar standardmappar
    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"

    # Jag sätter rättigheter så bara ägaren kan använda mapparna
    chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

    # Jag gör användaren till ägare av alla filer
    chown -R "$user:$user" "$home"

    # Jag skapar welcome-fil
    welcome="$home/welcome.txt"

    # Jag skriver välkomstmeddelande och listar andra användare
    {
        echo "Välkommen $user"
        echo ""
        echo "Other system users:"
        awk -F: '$3 >= 1000 {print $1}' /etc/passwd | grep -v "^$user$"
    } > "$welcome"

    # Jag skyddar filen så bara användaren kan läsa den
    chmod 600 "$welcome"

    echo "DONE: $user created successfully"

done

echo "ALL USERS CREATED"
