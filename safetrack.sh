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
  exit 1
fi

# --- PIN LOCK SYSTEM ---
clear
echo "=========================================="
echo "          SAFE TRACK NOW - SECURE         "
echo "=========================================="

read -s -p "Enter Security PIN to access: " user_pin
echo ""

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
    echo "     © 2026 Safe Track Now org           "
    echo "=========================================="
    echo "1) > Install HestiaCP Panel (SMTP)"
    echo "2) > Configure SMTP (Internal Relay)"
    echo "3) > Install n8n (Automation Tool)"
    echo "4) > Pterodactyl & Addons Menu"
    echo "5) > Install CloudPanel (High Performance)"
    echo "6) > Install Cloudflare Tunnel (cloudflared)"
    echo "7) > System Update & VPS Info"
    echo "8) > Exit"
    echo "=========================================="

    read -p "Select an option [1-8]: " choice

    case "$choice" in

        1)
            echo "Installing HestiaCP..."
            bash <(curl -s https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh)
            read -p "Press Enter..."
            ;;

        2)
            echo "Installing SMTP (Postfix)..."
            apt update -y
            apt install -y postfix mailutils
            dpkg-reconfigure postfix
            read -p "Press Enter..."
            ;;

        3)
            echo "Installing n8n..."
            apt update -y
            apt install -y npm
            npm install -g n8n
            echo "Run using: n8n"
            read -p "Press Enter..."
            ;;

        4)
            while true; do
                clear
                echo "=================================="
                echo "     PTERODACTYL & ADDONS MENU    "
                echo "=================================="
                echo "1) Install Pterodactyl (Unofficial)"
                echo "2) Install Pterodactyl (Manual)"
                echo "3) Install Blueprint"
                echo "4) Update Blueprint"
                echo "5) Sync Addons (.blueprint)"
                echo "6) Update Pterodactyl Panel"
                echo "7) Back"

                read -p "Select [1-7]: " ptero_choice

                case "$ptero_choice" in

                    1)
                        echo "Running installer..."
                        bash <(curl -s https://pterodactyl-installer.se)
                        read -p "Done. Press Enter..."
                        ;;

                    2)
                        echo "Downloading panel..."
                        mkdir -p "$PTERO_DIR" && cd "$PTERO_DIR" || break
                        curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
                        tar -xzvf panel.tar.gz
                        chmod -R 755 storage/* bootstrap/cache/
                        read -p "Done. Press Enter..."
                        ;;

                    3)
                        echo "Installing Blueprint..."
                        bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/blueprint/main/blueprint-installer.sh)
                        read -p "Done. Press Enter..."
                        ;;

                    4)
                        cd "$PTERO_DIR" || { echo "Directory not found."; break; }
                        blueprint -upgrade
                        php artisan view:clear
                        php artisan config:clear
                        read -p "Blueprint updated. Press Enter..."
                        ;;

                    5)
                        echo "Syncing addons..."
                        cd "$PTERO_DIR" || { echo "Directory not found."; break; }

                        API_URL="https://api.github.com/repos/$GH_USER/$GH_REPO/contents/$ADDON_PATH"
                        FILES=$(curl -s "$API_URL" | grep '"name":' | cut -d '"' -f4 | grep '\.blueprint$')

                        if [ -z "$FILES" ]; then
                            echo "No addons found."
                        else
                            for file in $FILES; do
                                echo "Downloading $file"
                                RAW_URL="https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/$ADDON_PATH/$file"
                                wget -q -O "$file" "$RAW_URL"

                                if [ -f "$file" ]; then
                                    blueprint -install "$file"
                                    rm -f "$file"
                                fi
                            done

                            php artisan view:clear
                            php artisan config:clear
                            echo "Sync complete!"
                        fi

                        read -p "Press Enter..."
                        ;;

                    6)
                        echo "Updating Pterodactyl Panel..."
                        cd "$PTERO_DIR" || { echo "Directory not found."; break; }

                        php artisan down

                        git stash
                        git pull origin main

                        composer install --no-dev --optimize-autoloader
                        php artisan migrate --seed --force

                        chown -R www-data:www-data *
                        chmod -R 755 storage/* bootstrap/cache/

                        php artisan view:clear
                        php artisan config:clear
                        php artisan cache:clear

                        php artisan up

                        echo "Panel Updated Successfully!"
                        read -p "Press Enter..."
                        ;;

                    7)
                        break
                        ;;

                    *)
                        read -p "Invalid option..."
                        ;;
                esac
            done
            ;;

        5)
            echo "Installing CloudPanel..."
            curl -sS https://installer.cloudpanel.io -o install.sh
            DB_ENGINE=MARIADB_10.11 bash install.sh
            read -p "Press Enter..."
            ;;

        6)
            echo "Installing Cloudflare Tunnel..."
            curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
            dpkg -i cloudflared.deb
            rm -f cloudflared.deb

            read -p "Enter token (optional): " cf_token
            if [ ! -z "$cf_token" ]; then
                cloudflared service install "$cf_token"
            fi

            read -p "Press Enter..."
            ;;

        7)
            echo "Updating system..."
            apt update && apt upgrade -y

            echo "===== SYSTEM INFO ====="
            echo "Hostname: $(hostname)"
            echo "IP: $(hostname -I | awk '{print $1}')"
            echo "Kernel: $(uname -r)"

            echo "----- RAM -----"
            free -h

            echo "----- DISK -----"
            df -h

            echo "----- CPU -----"
            lscpu | grep "Model name"

            echo "----- UPTIME -----"
            uptime

            read -p "Press Enter..."
            ;;

        8)
            echo "Exiting..."
            exit 0
            ;;

        *)
            read -p "Invalid choice..."
            ;;
    esac
done
