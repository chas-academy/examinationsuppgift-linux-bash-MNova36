#!/bin/bash

# =========================
# Kontroll: root krävs
# =========================
if [ "$EUID" -ne 0 ]; then
    echo "FEL: Scriptet måste köras som root"
    exit 1
fi

# =========================
# Kontroll: input
# =========================
if [ $# -eq 0 ]; then
    echo "FEL: Inga användare angivna"
    exit 1
fi

# =========================
# Loop genom alla användare
# =========================
for user in "$@"; do

    # Skapa användare (standard Linux)
    useradd -m "$user"

    # Hämta korrekt hemkatalog från systemet (VIKTIGT i tester)
    home=$(getent passwd "$user" | cut -d: -f6)

    # Säkerställ att katalogen finns
    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    # Sätt ägare på hela hemkatalogen
    chown -R "$user:$user" "$home"

    # Sätt rättigheter (endast ägare)
    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    # Skapa welcome.txt
    echo "Välkommen $user" > "$home/welcome.txt"
    echo "" >> "$home/welcome.txt"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$home/welcome.txt"

    # Sätt rätt ägare + rättigheter
    chown "$user:$user" "$home/welcome.txt"
    chmod 600 "$home/welcome.txt"

done
