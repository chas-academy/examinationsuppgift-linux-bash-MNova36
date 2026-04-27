#!/bin/bash
# Script to create users, folders and welcome file

# ---------- Check root ----------
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script with sudo"
    exit 1
fi

# ---------- Check arguments ----------
if [ $# -lt 1 ]; then
    echo "Usage: sudo $0 user1 user2 user3"
    exit 1
fi

# =====================================
# PART 1: Create users and directories
# =====================================

for username in "$@"
do
    # Skip if user already exists
    if id "$username" >/dev/null 2>&1; then
        echo "User '$username' already exists"
        continue
    fi

    # Create new user with home directory
    useradd -m -s /bin/bash "$username"

    # Find user home path from system
    user_home=$(getent passwd "$username" | cut -d: -f6)

    # Create required folders
    for folder in Documents Downloads Work
    do
        mkdir -p "$user_home/$folder"
        chmod 700 "$user_home/$folder"
    done

    # Change owner of everything
    chown -R "$username:$username" "$user_home"

    echo "Created: $username"
done

# =====================================
# PART 2: Create welcome.txt
# =====================================

for username in "$@"
do
    user_home=$(getent passwd "$username" | cut -d: -f6)

    # If home folder not found → skip
    if [ -z "$user_home" ]; then
        continue
    fi

    file="$user_home/welcome.txt"

    {
        echo "Välkommen $username"
        echo ""
        echo "Alla andra användare i systemet:"

        while IFS=: read -r name _ uid _
        do
            if [ "$uid" -ge 1000 ] && [ "$name" != "$username" ]; then
                echo "$name"
            fi
        done < /etc/passwd

    } > "$file"

    # Set correct owner and file permission
    chown "$username:$username" "$file"
    chmod 600 "$file"

    echo "welcome.txt created for $username"
done

echo "Script finished successfully"

exit 0
