#!/bin/bash

# Skapar användare från argumentlistan, bygger upp deras hemkataloger
# och skapar en personlig welcome.txt.
# Endast root får köra scriptet.

# Kontrollera att scriptet körs som root
if [ "$(id -u)" -ne 0 ]; then
    echo "Fel: endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst ett användarnamn skickats in
if [ "$#" -lt 1 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Loopa igenom alla användarnamn som skickats in
for username in "$@"; do
    # Skapa en privat grupp om den inte redan finns
    if ! getent group "$username" > /dev/null 2>&1; then
        groupadd "$username"
    fi

    # Skapa användaren om den inte redan finns
    if ! id "$username" > /dev/null 2>&1; then
        useradd -m -g "$username" -s /bin/bash "$username"
    fi

    # Hämta hemkatalog från systemet
    home_dir="$(getent passwd "$username" | cut -d: -f6)"

    # Säkerhetskontroll: användaren måste ha en hemkatalog
    if [ -z "$home_dir" ]; then
        echo "Fel: kunde inte hitta hemkatalog för $username"
        continue
    fi

    # Skapa undermappar
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    # Sätt ägare på hemkatalog och undermappar
    chown "$username:$username" "$home_dir"
    chown "$username:$username" "$home_dir/Documents"
    chown "$username:$username" "$home_dir/Downloads"
    chown "$username:$username" "$home_dir/Work"

    # Endast ägaren ska ha åtkomst till mapparna
    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    # Skapa welcome.txt
    {
        echo "Välkommen $username"
        getent passwd | cut -d: -f1 | grep -v "^${username}$"
    } > "$home_dir/welcome.txt"

    # Sätt rätt ägare och rättigheter på welcome.txt
    chown "$username:$username" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done
