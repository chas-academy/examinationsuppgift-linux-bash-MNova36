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
    useradd -m -s /bin/bash "$user"

    # Jag sparar hemkatalogens sökväg
    home=$(getent passwd "$user" | cut -d: -f6)

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

done
#Skapa welcome.txt efter att alla användare finns. I videon var scriptet lite annorlunda, 
#men eftersom jag inte fick full poäng ändrade jag denna del här så att welcome.txt skapas efter att alla användare har skapats.


for user in "$@"
do
    home=$(getent passwd "$user" | cut -d: -f6)

    # Hoppa över om hemkatalog saknas
    [ -z "$home" ] && continue

    welcome="$home/welcome.txt"

    echo "Välkommen $user" > "$welcome"
    echo "" >> "$welcome"
    echo "Andra användare i systemet:" >> "$welcome"

    while IFS=: read -r name _ uid _
    do
        if [ "$uid" -ge 1000 ] && [ "$name" != "$user" ]; then
            echo "- $name" >> "$welcome"
        fi
    done < /etc/passwd

    chown "$user:$user" "$welcome"
    chmod 600 "$welcome"

done
