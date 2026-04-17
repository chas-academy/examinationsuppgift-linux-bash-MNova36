#!bin/bash/

if [ "$EUID" -ne 0 ]; then
    echo "Fel: endast root får köra detta script."
    exit 1
fi

# Kontrollera att minst ett användarnamn skickats in
if [ "$#" -eq 0 ]; then
    echo "Användning: $0 användare1 användare2 användare3"
    exit 1
fi

# Loopa igenom alla användarnamn som skickats in
for user in "$@"; do
    # Skapa användaren om den inte redan finns
    if id "$user" >/dev/null 2>&1; then
        echo "Användaren $user finns redan, hoppar över skapandet."
    else
        useradd -m "$user"
        echo "Användaren $user skapades."
    fi

    # Hämta användarens hemkatalog från systemet
    home_dir=$(getent passwd "$user" | cut -d: -f6)

    # Skapa undermappar i hemkatalogen
    mkdir -p "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Sätt rätt ägare på hemkatalog och undermappar
    chown -R "$user:$user" "$home_dir"

    # Endast ägaren ska kunna läsa/skriva/öppna mapparna
    chmod 700 "$home_dir/Documents" "$home_dir/Downloads" "$home_dir/Work"

    # Skapa welcome.txt med personligt välkomstmeddelande
    {
        echo "Välkommen $user"
        echo
        echo "Andra användare i systemet:"
        getent passwd | cut -d: -f1 | grep -vx "$user"
    } > "$home_dir/welcome.txt"

    # Sätt rättigheter på welcome.txt
    chown "$user:$user" "$home_dir/welcome.txt"
    chmod 600 "$home_dir/welcome.txt"
done
