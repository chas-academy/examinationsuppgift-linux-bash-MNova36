#!/bin/bash


# --- FÄRGER FÖR OUTPUT ---
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- 1. KONTROLLERA ROOT ---
# Scriptet måste köras som root (UID 0)
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Fel: Detta script måste köras som root (sudo).${NC}"
    exit 1
fi

# --- 2. KONTROLLERA ARGUMENT ---
# Minst en användare måste anges
if [ "$#" -lt 1 ]; then
    echo "Användning: $0 användare1 användare2 ..."
    exit 1
fi

# --- FUNKTION: SKAPA ANVÄNDARE ---
create_user() {
    USERNAME=$1

    # Skapa användaren med hemkatalog om den inte finns
    if id "$USERNAME" &>/dev/null; then
        echo "Användaren $USERNAME finns redan."
    else
        useradd -m "$USERNAME"
        echo -e "${GREEN}Skapade användare: $USERNAME${NC}"
    fi

    HOME_DIR="/home/$USERNAME"

    # --- 3. SKAPA KATALOGSTRUKTUR ---
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # Sätt rätt ägare
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

    # --- 4. SÄTT RÄTTIGHETER ---
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # --- 5. SKAPA WELCOME-FIL ---
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USERNAME" > "$WELCOME_FILE"

    # Lista alla användare i systemet (från /etc/passwd)
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Sätt rätt ägare även på filen
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 644 "$WELCOME_FILE"
}

# --- LOOPA IGENOM ALLA ARGUMENT ---
for USER in "$@"
do
    create_user "$USER"
done

exit 0
