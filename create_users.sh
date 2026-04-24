#!/bin/bash

# =========================
# Kontroll: måste köras som root
# =========================
if [ "$EUID" -ne 0 ]; then
    echo "FEL: Du måste köra detta som root"
    exit 1
fi

# =========================
# Kontroll: finns användare?
# =========================
if [ $# -eq 0 ]; then
    echo "FEL: Inga användare angivna"
    exit 1
fi

# =========================
# Lista av användare
# =========================
users=("$@")

# =========================
# Skapa användare
# =========================
for user in "${users[@]}"; do

    # Skapa användare
    useradd -m "$user"

    # Hemkatalog
    home="/home/$user"

    # Skapa mappar
    mkdir -p "$home/Documents"
    mkdir -p "$home/Downloads"
    mkdir -p "$home/Work"

    # Sätt ägare
    chown -R "$user:$user" "$home"

    # Sätt rättigheter (endast ägare)
    chmod 700 "$home/Documents"
    chmod 700 "$home/Downloads"
    chmod 700 "$home/Work"

    # Skapa välkomstfil
    echo "Välkommen $user" > "$home/welcome.txt"
    echo "" >> "$home/welcome.txt"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$home/welcome.txt"

    # Sätt rätt ägare och rättigheter på filen
    chown "$user:$user" "$home/welcome.txt"
    chmod 600 "$home/welcome.txt"

done
