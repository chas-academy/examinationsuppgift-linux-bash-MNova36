#!/bin/bash

# This script creates users, folders, permissions, and welcome files.

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root." >&2
    exit 1
fi

if [ "$#" -eq 0 ]; then
    echo "Error: Please provide at least one username." >&2
    exit 1
fi

# First create all users.
for username in "$@"; do
    if ! id "$username" >/dev/null 2>&1; then
        useradd -m -s /bin/bash "$username"
    fi
done

# Then create folders, permissions, and welcome files for each user.
for username in "$@"; do
    home_dir="/home/$username"
    user_group=$(id -gn "$username")

    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Work"

    chown -R "$username:$user_group" "$home_dir"

    chmod 700 "$home_dir/Documents"
    chmod 700 "$home_dir/Downloads"
    chmod 700 "$home_dir/Work"

    welcome_file="$home_dir/welcome.txt"

    echo "Välkommen $username" > "$welcome_file"
    getent passwd | cut -d: -f1 | grep -vx "$username" >> "$welcome_file"

    chown "$username:$user_group" "$welcome_file"
    chmod 600 "$welcome_file"
done
