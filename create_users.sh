#!/bin/bash

# Script som skapar användare, hemkatalog, undermappar
# och en personlig welcome.txt för varje användare.
# Endast root får köra scriptet.

# Kontrollera att scriptet körs som root
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst en användare skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Skapa varje användare som skickas in till scriptet
for username in "$@"; do
    # Spara alla användare som redan finns i systemet innan ny användare skapas
    existing_users="$(cut -d: -f1 /etc/passwd)"

    # Skapa användaren om den inte redan finns
    # --badname gör att namn som Anna/Bjorn/Charlie fungerar i tester
    if ! id "$username" >/dev/null 2>&1; then
        useradd --badname -m -U "$username"
    fi

    # Hämta användarens hemkatalog från systemet
    home_dir="$(getent passwd "$username" | cut -d: -f6)"

    # Om hemkatalog inte kunde hittas, gå vidare till nästa användare
    if [ -z "$home_dir" ]; then
        continue
    fi

    # Skapa undermappar i hemkatalogen
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Sätt ägare på mapparna
    chown "$username:$username" "$home_dir/Documents"
    chown "$username:$username" "$home_dir/Downloads"
    chown "$username:$username" "$home_dir/Work"

    # Endast ägaren får läsa, skriva och gå in i mapparna
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    # Skapa welcome.txt i hemkatalogen
    {
        echo "Välkommen $username"
        echo "$existing_users" | grep -vx "$username"
    } > "$home_dir/welcome.txt"

    # Sätt ägare och rättigheter på welcome.txt
    chown "$username:$username" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done
