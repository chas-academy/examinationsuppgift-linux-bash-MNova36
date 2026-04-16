#!/bin/bash
#-------------------------------
#Chek if script is run as root
#-------------------------------
if [ "EUID" -ne 0 ]; then
    echo "ERROR: Please run as root"
    exit 1
fi

#-------------------------------
#Chek if at least one usernam is given
#------------------------------------
if [ $# -eq 0 ]; then
    echo "ERROR: No usernames orivided"
    echo "Usage: $0 user 1 user2 ..."
    exit 1
fi

#----------------------------------
#Lopp through all given users
#----------------------------------
for user in "$@"
do
    echo "Creating user $user"
    #--------------------------
    #Chek if user already exist
    #--------------------------
    if id "$user" &>/dev/null; then
        echo "Warning: User $user already exist"
        continue
    fi

    #---------------------------------
    #create user with home directory
    #---------------------------------
    useradd -m "$user"
    home="/home/$user"

    #---------------------------------
    #Check if home directory exist
    #---------------------------------
    if [ ! -d "home" ]; then
        echo "ERROR: Home directory not created for $user"
        continue
    fi

    #--------------------------
    #Create folders inside home
    #--------------------------
    mkdir -p "$home/Documents" "$home/Dowloads" "$home/Work"

    #--------------
    #Set permissions for only users
    #----------------
    chmod 700 "$user/Documents" "$home/Dowloads" "$home/Work"

    #-----------------------------
    #Set ownership to user
    #-----------------------------
    chown -R "$user:$user" "$home"

    #--------------------------
    #Create welcome file
    #--------------------------

    welcom="$home/welcom.txt"
    {
        echo "Welcome $user"
        echo ""
        echo "Other system users:"
        awk -F: "$3 >= 1000 {print $1}" /etc/passwd | grep -v "^$user$"
    }  > "$welcom"

    #-----------------------------------
    # Secure welcom file
    #-----------------------------
    chmod 600 "$welcome"
    echo "Done: $user created successfully"
done
echo "All users created"
        
  
    
  
