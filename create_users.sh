#!/bin/bash
# Script for creating users and preparing their home folders

# ---------- Root check ----------
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo"
    exit 1
fi

# ---------- Check if usernames are given ----------
if [ $# -eq 0 ]; then
    echo "Usage: sudo $0 username1 username2 ..."
    exit 1
fi

# =====================================
# Step 1: Create users and folders
# =====================================

for person in "$@"
do
    # Check if user already exists
    if id "$person" >/dev/null 2>&1; then
        echo "User $person already exists"
        continue
    fi

    # Create user with home directory
    useradd -m -s /bin/bash "$person"

    # Get user's home directory
    home_path=$(getent passwd "$person" | cut -d: -f6)

    # Create folders inside home directory
    mkdir -p "$home_path/Documents"
    mkdir -p "$home_path/Downloads"
    mkdir -p "$home_path/Work"

    # Give ownership to the user
    chown -R "$person:$person" "$home_path"

    # Set permissions so only owner has access
    chmod 700 "$home_path/Documents"
    chmod 700 "$home_path/Downloads"
    chmod 700 "$home_path/Work"

    echo "User $person created"
done

# =====================================
# Step 2: Create welcome.txt
# =====================================

for person in "$@"
do
    home_path=$(getent passwd "$person" | cut -d: -f6)

    # Skip if home directory does not exist
    [ -z "$home_path" ] && continue

    welcome="$home_path/welcome.txt"

    echo "Välkommen $person" > "$welcome"
    echo "" >> "$welcome"
    echo "Other users in the system:" >> "$welcome"

    # Show all other users
    while IFS=: read -r name _ uid _
    do
        if [ "$uid" -ge 1000 ] && [ "$name" != "$person" ]; then
            echo "$name" >> "$welcome"
        fi
    done < /etc/passwd

    # Secure the file
    chown "$person:$person" "$welcome"
    chmod 600 "$welcome"

    echo "welcome.txt created for $person"
done

echo "All tasks completed"

exit 0
