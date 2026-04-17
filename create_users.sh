#!/bin/bash
# Script to create users, folders, permissions and welcome file

# ---------- ROOT CHECK ----------
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root"
    exit 1
fi

# ---------- INPUT CHECK ----------
if [ $# -eq 0 ]; then
    echo "ERROR: No usernames provided"
    exit 1
fi

# ---------- LOOP USERS ----------
for user in "$@"
do
    echo "Creating user: $user"

    # Check if user already exists
    if id "$user" &>/dev/null; then
        echo "User already exists: $user"
        continue
    fi

    # ---------- CREATE USER ----------
    useradd -m "$user"

    # Get REAL home directory (important for tests)
    home=$(eval echo "~$user")

    # Check home directory exists
    if [ ! -d "$home" ]; then
        echo "ERROR: Home not created for $user"
        continue
    fi

    # ---------- CREATE FOLDERS ----------
    mkdir -p "$home/Documents" "$home/Downloads" "$home/Work"

    # ---------- SET OWNERSHIP FIRST ----------
    chown -R "$user:$user" "$home"

    # ---------- SET PERMISSIONS ----------
    chmod 700 "$home/Documents" "$home/Downloads" "$home/Work"

    # ---------- CREATE WELCOME FILE ----------
    welcome="$home/welcome.txt"

    {
        echo "Välkommen $user"
        echo "Andra användare i systemet:"
        awk -F: '$3 >= 1000 {print $1}' /etc/passwd | grep -v "^$user$"
    } > "$welcome"

    # Set correct owner and permissions
    chown "$user:$user" "$welcome"
    chmod 600 "$welcome"

    echo "Done: $user created"
done

echo "All users created successfully"
