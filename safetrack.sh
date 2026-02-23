#!/bin/bash

# === CONFIGURATION ===
GH_USER="ishanwarrior2012"
GH_REPO="vps123"
ADDON_PATH="" 
PTERO_DIR="/var/www/pterodactyl"
CORRECT_PIN="2012"
# =====================

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo su)"
  exit
fi

# --- PIN LOCK SYSTEM ---
clear
echo "=========================================="
echo "          SAFE TRACK NOW - SECURE         "
echo "=========================================="
read -s -p "Enter Security PIN to access: " user_pin
echo "" # For a new line after hidden input

if [ "$user_pin" != "$CORRECT_PIN" ]; then
    echo "Access Denied: Incorrect PIN."
    exit 1
fi
echo "Access Granted. Loading menu..."
sleep 1
# -----------------------

while true; do
    clear
    echo "=========================================="
    echo "             SAFE TRACK NOW               "
    echo "     © 2026 Safe Track Now org            "
    echo "=========================================="
    echo "1) > Install HestiaCP Panel (SMTP)"
    echo "2) > Configure SMTP (Internal Relay)"
    echo "3) > Install n8n (Automation Tool)"
    echo "4) > Pterodactyl & Addons Menu"
    echo "5) > Install CloudPanel (High Performance)"
    echo "6) > Install Cloudflare Tunnel (cloudflared)"
    echo "7) > Exit"
    echo "=========================================="
    
    read -p "Select an option [1-7]: " choice
    
    case "$choice" in
        4)
            while true; do
                clear
                echo "--- PTERODACTYL & ADDONS ---"
                echo "1) ⌈ Install Pterodactyl (Unofficial - .se script)"
                echo "2) | Install Pterodactyl (Official Manual)"
                echo "3) | Install Blueprint (Framework)"
                echo "4) | Update Blueprint (-upgrade)"
                echo "5) | Sync Addons from GitHub (vps123)"
                echo "6) ⌊ Back to Main Menu"
                
                read -p "Select [1-6]: " ptero_choice
                
                case "$ptero_choice" in
                    1)
                        echo "Running Unofficial Pterodactyl Installer..."
                        bash <(curl -s https://pterodactyl-installer.se)
                        read -p "Process finished. Press Enter..."
                        ;;
                    2)
                        echo "Downloading Official Pterodactyl Files..."
                        mkdir -p $PTERO_DIR && cd $PTERO_DIR
                        curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
                        tar -xzvf panel.tar.gz
                        chmod -R 755 storage/* bootstrap/cache/
                        read -p "Base files ready. Press Enter..."
                        ;;
                    3)
                        echo "Installing Blueprint Framework..."
                        bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/blueprint/main/blueprint-installer.sh)
                        read -p "Done. Press Enter..."
                        ;;
                    4)
                        cd $PTERO_DIR || { echo "Dir not found."; break; }
                        blueprint -upgrade
                        php artisan view:clear
                        php artisan config:clear
                        read -p "Blueprint Upgraded. Press Enter..."
                        ;;
                    5)
                        echo "Syncing from $GH_USER/$GH_REPO..."
                        cd $PTERO_DIR || { echo "Dir not found."; break; }
                        FILES=$(curl -s "https://api.github.com/repos/$GH_USER/$GH_REPO/contents/$ADDON_PATH" | grep -oP '(?<="name": ")[^"]*\.blueprint')
                        if [ -z "$FILES" ]; then
                            echo "No .blueprint files found."
                        else
                            for file in $FILES; do
                                echo "Processing: $file"
                                wget -q -O "$file" "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/$ADDON_PATH/$file"
                                if [ -f "$file" ]; then
                                    blueprint -install "$file"
                                    rm "$file"
                                fi
                            done
                            php artisan view:clear
                            echo "Sync Finished!"
                        fi
                        read -p "Press Enter..."
                        ;;
                    6) break ;;
                esac
            done
            ;;
        5)
            echo "--- Installing CloudPanel ---"
            curl -sS https://installer.cloudpanel.io -o install.sh
            DB_ENGINE=MARIADB_10.11 bash install.sh
            read -p "Press Enter to return..."
            ;;
        6)
            echo "--- Installing Cloudflare Tunnel ---"
            curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
            dpkg -i cloudflared.deb
            rm cloudflared.deb
            echo "Installation complete!"
            read -p "Enter Zero Trust Token (or leave blank to skip): " cf_token
            if [ ! -z "$cf_token" ]; then
                cloudflared service install "$cf_token"
            fi
            read -p "Press Enter to return..."
            ;;
        7)
            exit 0
            ;;
        *)
            read -p "Invalid selection. Press Enter to try again..."
            ;;
    esac
done
