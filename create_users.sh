#!/bin/bash
#-------------------------------
#Check if script is run as root
#-------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

#-------------------------------
#Check if at least one username is given
#------------------------------------
if [ $# -eq 0 ]; then
    echo "ERROR: No usernames provided"
    echo "Usage: $0 user1 user2 ..."
    exit 1
fi

#----------------------------------
#Loop through all given users
#----------------------------------
for user in "$@"
do
    echo "Creating user $user"
    #--------------------------
    #Check if user already exist
    #--------------------------
    if id "$user" &>/dev/null; then
        echo "Warning: User $user already exist"
        continue
    fi

    #---------------------------------
    #create user with home directory
    #---------------------------------
    useradd -m -s /bin/bash "$user"
    home="/home/$user"

    #---------------------------------
    #Check if home directory exist
    #---------------------------------
    if [ ! -d "$home" ]; then
        echo "ERROR: Home directory not created for $user"
        continue
    fi

    #--------------------------
    #Create folders inside home
    #--------------------------
    mkdir -p "$home/Documents" "$home/Downloads" "$home/projects"

    #--------------
    #Set permissions for only users
    #----------------
    chmod 700 "$home/Documents" "$home/Downloads" "$home/projects"

    #-----------------------------
    #Set ownership to user
    #-----------------------------
    chown -R "$user:$user" "$home"

    #--------------------------
    #Create welcome file
    #--------------------------
    welcome="$home/welcome.txt"
    {
        echo "Welcome $user!"
        echo ""
        echo "Other system users:"
        awk -F: -v current_user="$user" '$3 >= 1000 && $1 != current_user {print $1}' /etc/passwd
    } > "$welcome"

    #-----------------------------------
    # Secure welcome file
    #-----------------------------
    chmod 600 "$welcome"
    chown "$user:$user" "$welcome"
    echo "Done: $user created successfully"
done
echo "All users created"
