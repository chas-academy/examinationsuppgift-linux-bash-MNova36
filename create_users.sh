#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script as root"
    exit 1
fi

# Check args
if [ $# -eq 0 ]; then
    echo "ERROR: No users provided"
    exit 1
fi

for user in "$@"; do

    # Skip if exists
    if id "$user" &>/dev/null; then
        continue
    fi

    # Create user
    useradd -m -s /bin/bash "$user"

    # Get REAL home directory
    home=$(getent passwd "$user" | cut -d: -f6)

    # Create folders
    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"

    # Set owner FIRST
    chown -R "$user:$user" "$home"

    # Set permissions
    chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

    # Create welcome file
    welcome="$home/welcome.txt"

    {
        echo "Välkommen $user"
        echo ""
        cut -d: -f1 /etc/passwd | grep -v "^$user$"
    } > "$welcome"

    # FIX: set correct owner
    chown "$user:$user" "$welcome"
    chmod 600 "$welcome"

done
