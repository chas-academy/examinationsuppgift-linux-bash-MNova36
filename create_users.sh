#!/bin/bash

# ============================================
# Skapar användare + katalogstruktur + welcome
# ============================================

# --- ROOT CHECK ---
if [ "$EUID" -ne 0 ]; then
    echo "Måste köras som root"
    exit 1
fi

# --- KONTROLLERA INPUT ---
if [ "$#" -lt 1 ]; then
    echo "Användning: $0 användare..."
    exit 1
fi

# --- 1. SKAPA ALLA ANVÄNDARE FÖRST ---
for USER in "$@"
do
    if ! id "$USER" &>/dev/null; then
        useradd "$USER"
        mkdir -p "/home/$USER"
    fi
done

# --- 2. KONFIGURERA VARJE ANVÄNDARE ---
for USER in "$@"
do
    HOME_DIR="/home/$USER"

    # säkerställ hemkatalog
    mkdir -p "$HOME_DIR"

    # skapa mappar
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # sätt ägare
    chown -R "$USER:$USER" "$HOME_DIR"

    # sätt rättigheter (strikta)
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # --- skapa welcome.txt ---
    FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USER" > "$FILE"

    # lista ALLA användare EFTER att alla skapats
    cut -d: -f1 /etc/passwd >> "$FILE"

    # rätt ägare
    chown "$USER:$USER" "$FILE"
    chmod 644 "$FILE"

done

exit 0
