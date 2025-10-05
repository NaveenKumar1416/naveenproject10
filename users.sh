#!/bin/bash
# ==============================================================
# Script Name: create_users.sh
# Description: Automates Linux user and group creation based on
#              an input file formatted as "username;group1,group2".
# Author: [Your Name]
# Date: [Today's Date]
# ==============================================================

# --- CONFIGURATION ---
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# --- PREPARATION ---

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root." >&2
  exit 1
fi

# Ensure input file is provided
if [ $# -ne 1 ]; then
  echo "Usage: bash $0 <user_list_file>"
  exit 1
fi

INPUT_FILE="$1"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Input file '$INPUT_FILE' not found!" >&2
  exit 1
fi

# Create log and password storage files securely
mkdir -p /var/secure
touch "$LOG_FILE"
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

# --- MAIN PROCESSING ---
echo "===== User Creation Script Started on $(date) =====" >> "$LOG_FILE"

while IFS=";" read -r username groups; do
  # Trim whitespace
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs | tr -d ' ')
  
  # Skip empty lines
  if [ -z "$username" ]; then
    continue
  fi

  echo "Processing user: $username" >> "$LOG_FILE"

  # Ensure personal group exists
  if ! getent group "$username" > /dev/null; then
    groupadd "$username"
    echo "[+] Group '$username' created." >> "$LOG_FILE"
  else
    echo "[!] Group '$username' already exists." >> "$LOG_FILE"
  fi

  # Create user with personal group and home directory
  if id "$username" &>/dev/null; then
    echo "[!] User '$username' already exists. Skipping creation." >> "$LOG_FILE"
  else
    useradd -m -g "$username" -s /bin/bash "$username"
    echo "[+] User '$username' created with home directory." >> "$LOG_FILE"
  fi

  # Add user to additional groups if specified
  if [ -n "$groups" ]; then
    IFS=',' read -ra group_list <<< "$groups"
    for grp in "${group_list[@]}"; do
      if ! getent group "$grp" > /dev/null; then
        groupadd "$grp"
        echo "[+] Group '$grp' created." >> "$LOG_FILE"
      fi
      usermod -aG "$grp" "$username"
      echo "[+] User '$username' added to group '$grp'." >> "$LOG_FILE"
    done
  fi

  # Generate a random secure password
  password=$(openssl rand -base64 12)
  echo "$username,$password" >> "$PASSWORD_FILE"

  # Set password for the user
  echo "$username:$password" | chpasswd
  echo "[+] Password set for '$username'." >> "$LOG_FILE"

  # Set correct permissions
  chmod 700 "/home/$username"
  chown "$username:$username" "/home/$username"
  echo "[+] Permissions set for /home/$username" >> "$LOG_FILE"

done < "$INPUT_FILE"

echo "===== Script Completed Successfully on $(date) =====" >> "$LOG_FILE"
echo "✅ User creation process completed. Check logs at $LOG_FILE"
echo "✅ Passwords stored securely in $PASSWORD_FILE"

