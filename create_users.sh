#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Kör scriptet som root: sudo $0"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Användning: sudo $0 <användare1> <användare2>"
    exit 1
fi

# Steg 1: Skapa alla användare och mappar först
for username in "$@"; do
    if id "$username" &>/dev/null; then
        echo "Användaren '$username' finns redan."
        continue
    fi

    useradd -m -s /bin/bash "$username"

    home_dir=$(getent passwd "$username" | cut -d: -f6)

    mkdir -p "${home_dir}/Documents"
    mkdir -p "${home_dir}/Downloads"
    mkdir -p "${home_dir}/Work"

    chown -R "${username}:${username}" "$home_dir"
    chmod 700 "${home_dir}/Documents"
    chmod 700 "${home_dir}/Downloads"
    chmod 700 "${home_dir}/Work"

    echo "Användare '$username' skapad."
done

# Steg 2: Skapa welcome.txt för alla användare (nu finns alla i /etc/passwd)
for username in "$@"; do
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    [ -z "$home_dir" ] && continue

    echo "Välkommen $username" > "${home_dir}/welcome.txt"
    echo "" >> "${home_dir}/welcome.txt"
    echo "Andra användare i systemet:" >> "${home_dir}/welcome.txt"

    while IFS=: read -r name _ uid _; do
        if [ "$uid" -ge 1000 ] && [ "$name" != "$username" ]; then
            echo "  - $name" >> "${home_dir}/welcome.txt"
        fi
    done < /etc/passwd

    chown "${username}:${username}" "${home_dir}/welcome.txt"
done

exit 0
