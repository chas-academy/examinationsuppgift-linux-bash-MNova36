#!/bin/bash

# Root check
if [ "$EUID" -ne 0 ]; then
    exit 1
fi

# Check args
if [ $# -eq 0 ]; then
    exit 1
fi

for user in "$@"; do

    # Skip if exists
    if id "$user" &>/dev/null; then
        continue
    fi

    # Create user (robust for CI)
    useradd -m "$user" 2>/dev/null || adduser --disabled-password --gecos "" "$user"

    # Verify user exists
    if ! id "$user" &>/dev/null; then
        continue
    fi

    # Get home dir
    home=$(getent passwd "$user" | cut -d: -f6)

    # Ensure home exists (CI fix)
    mkdir -p "$home"

    # Create folders
    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"

    # Create welcome file
    welcome="$home/welcome.txt"

    echo "Välkommen $user" > "$welcome"
    echo "" >> "$welcome"
    cut -d: -f1 /etc/passwd | grep -v "^$user$" >> "$welcome"

    # Set ownership (AFTER everything)
    chown -R "$user:$user" "$home"

    # Set permissions
    chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"
    chmod 600 "$welcome"

done
