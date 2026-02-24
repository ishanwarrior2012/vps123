#!/bin/bash

# === CONFIGURATION ===
GH_USER="ishanwarrior2012"
GH_REPO="vps123"
ADDON_PATH=""
PTERO_DIR="/var/www/pterodactyl"
AIRLINK_DAEMON_DIR="/etc/daemon"
AIRLINK_PANEL_DIR="/var/www/panel"
CORRECT_PIN="2012"
# =====================

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo su)"
  exit 1
fi

# --- PIN LOCK SYSTEM ---
clear
echo "=========================================="
echo "         SAFE TRACK NOW - SECURE          "
echo "=========================================="
read -s -p "Enter Security PIN to access: " user_pin
echo ""

if [ "$user_pin" != "$CORRECT_PIN" ]; then
    echo "Access Denied: Incorrect PIN."
    exit 1
fi

# Make sure unzip is installed for the addons
apt-get install -y unzip &> /dev/null

# --- INITIAL SYSTEM UPDATE ---
echo "Running system updates (apt update & upgrade)..."
apt update && apt upgrade -y
echo "System up to date."
sleep 1

# --- MAIN MENU LOOP ---
while true; do
    clear
    echo "=========================================="
    echo "              SAFE TRACK NOW               "
    echo "          © 2026 Safe Track Now org        "
    echo "=========================================="
    echo "1) > SMTP & Anti-Spam Settings"
    echo "2) > Game Server Panels (Ptero/Airlink)"
    echo "3) > n8n Automation"
    echo "4) > Hosting Panels"
    echo "5) > Cloudflare Tools"
    echo "6) > System Monitor (CPU/RAM)"
    echo "7) > Exit"
    echo "=========================================="

    read -p "Select an option [1-7]: " main_choice

    case "$main_choice" in
        1) # SMTP & ANTI-SPAM SUB-MENU
            while true; do
                clear
                echo "--- SMTP & ANTI-SPAM SETTINGS ---"
                echo "1) Install HestiaCP (Lightweight/Standard)"
                echo "2) Install HestiaCP + Heavy Anti-Spam (SpamAssassin & ClamAV)"
                echo "3) Apply Anti-Spam RBL Blockers (Spamhaus/SpamCop)"
                echo "4) Configure Internal Relay"
                echo "5) Back to Main Menu"
                read -p "Select [1-5]: " smtp_c
                case "$smtp_c" in
                    1) bash <(curl -s https://hs.hestiacp.com) ;;
                    2) 
                       echo "Downloading HestiaCP installer..."
                       wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
                       echo "Installing HestiaCP with SpamAssassin and ClamAV enabled..."
                       bash hst-install.sh --spamassassin yes --clamav yes --force
                       read -p "Installation finished. Press Enter..."
                       ;;
                    3)
                       echo "Configuring Anti-Spam RBLs (Real-time Blackhole Lists)..."
                       if [ -d "/etc/exim4" ]; then
                           echo "Exim mail server detected. Applying RBLs..."
                           sed -i '/deny message = unrouteable address/i \  deny message = DNSBL listed at $dnslist_domain\n       dnslists = zen.spamhaus.org : bl.spamcop.net' /etc/exim4/exim4.conf.template
                           systemctl restart exim4
                           echo "Anti-Spam RBLs successfully applied for Exim."
                       elif [ -d "/etc/postfix" ]; then
                           echo "Postfix mail server detected. Applying RBLs..."
                           postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, reject_rbl_client zen.spamhaus.org, reject_rbl_client bl.spamcop.net"
                           systemctl restart postfix
                           echo "Anti-Spam RBLs successfully applied for Postfix."
                       else
                           echo "No supported mail server (Exim/Postfix) found. Install an SMTP panel first."
                       fi
                       read -p "Press Enter to continue..."
                       ;;
                    4) echo "Configuring Relay..." ; sleep 2 ;;
                    5) break ;;
                esac
            done
            ;;

        2) # GAME SERVER SUB-MENU
            while true; do
                clear
                echo "--- GAME SERVER SELECTION ---"
                echo "1) Pterodactyl & Addons"
                echo "2) Airlink Panel & Daemon"
                echo "3) Back to Main Menu"
                read -p "Select [1-3]: " gs_choice
                case "$gs_choice" in
                    1) # PTERODACTYL MENU
                        while true; do
                            clear
                            echo "--- PTERODACTYL & ADDONS ---"
                            echo "1) Install Pterodactyl (Script)"
                            echo "2) Install Pterodactyl (Manual)"
                            echo "3) Install Blueprint (Framework)"
                            echo "4) Themes & Apollo Installer"
                            echo "5) Sync Addons from GitHub (.blueprint)"
                            echo "6) Back to Game Menu"

                            read -p "Select [1-6]: " ptero_choice
                            case "$ptero_choice" in
                                1) bash <(curl -s https://pterodactyl-installer.se) ;;
                                2) mkdir -p "$PTERO_DIR" && cd "$PTERO_DIR" ;; 
                                3) bash <(curl -fsSL https://raw.githubusercontent.com/hopingboyz/blueprint/main/blueprint-installer.sh) ;;
                                4) # THEMES & APOLLO SUB-MENU
                                    while true; do
                                        clear
                                        echo "--- THEMES & APOLLO ---"
                                        echo "1) Install Nebula Theme (BLUEPRINT)"
                                        echo "2) Install NightAdmin Theme (BLUEPRINT)"
                                        echo "3) Install Lemen Theme (BLUEPRINT)"
                                        echo "4) Run Apollo Installer (AMD64)"
                                        echo "5) Back"
                                        read -p "Select [1-5]: " t_a_choice
                                        case "$t_a_choice" in
                                            1) 
                                               cd "$PTERO_DIR" || break
                                               echo "Downloading and Installing Nebula..."
                                               wget -q -O nebula.blueprint "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/nebula.blueprint"
                                               blueprint -install nebula.blueprint && rm -f nebula.blueprint
                                               read -p "Nebula installed! Press Enter..."; break ;;
                                            2) 
                                               cd "$PTERO_DIR" || break
                                               echo "Downloading and Installing NightAdmin..."
                                               wget -q -O nightadmin.blueprint "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/nightadmin.blueprint"
                                               blueprint -install nightadmin.blueprint && rm -f nightadmin.blueprint
                                               read -p "NightAdmin installed! Press Enter..."; break ;;
                                            3) 
                                               cd "$PTERO_DIR" || break
                                               echo "Downloading and Installing Lemen..."
                                               wget -q -O lemen.blueprint "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/lemen.blueprint"
                                               blueprint -install lemen.blueprint && rm -f lemen.blueprint
                                               read -p "Lemen installed! Press Enter..."; break ;;
                                            4) 
                                               if [ -f "./ApolloInstallerAMD64" ]; then
                                                   chmod +x ApolloInstallerAMD64 && ./ApolloInstallerAMD64
                                               else
                                                   echo "Downloading Apollo Installer..."
                                                   wget -q https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/ApolloInstallerAMD64
                                                   chmod +x ApolloInstallerAMD64 && ./ApolloInstallerAMD64
                                               fi
                                               read -p "Press Enter..."; break ;;
                                            5) break ;;
                                        esac
                                    done
                                    ;;
                                5)
                                    # SYNC LOGIC
                                    cd "$PTERO_DIR" || break
                                    FILES=$(curl -s "https://api.github.com/repos/$GH_USER/$GH_REPO/contents/$ADDON_PATH" | grep '"name":' | cut -d '"' -f4 | grep '\.blueprint$')
                                    for file in $FILES; do
                                        wget -q -O "$file" "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/$ADDON_PATH/$file"
                                        blueprint -install "$file" && rm -f "$file"
                                    done
                                    read -p "Sync Complete. Press Enter..."
                                    ;;
                                6) break ;;
                            esac
                        done
                        ;;
                    2) # AIRLINK SUB-MENU
                        while true; do
                            clear
                            echo "--- AIRLINK TOOLS ---"
                            echo "1) Install Airlink Panel (Quick Script)"
                            echo "2) Install Airlink Panel (Manual Git)"
                            echo "3) Install Airlink Daemon"
                            echo "4) Install Airlink Addons (.zip from GitHub)"
                            echo "5) Panel Service: Start/Stop/PM2"
                            echo "6) Back to Game Menu"
                            read -p "Select [1-6]: " a_c
                            case "$a_c" in
                                1) bash <(curl -s https://raw.githubusercontent.com) ;;
                                2) 
                                   cd /var/www/ && git clone https://github.com && cd panel
                                   sudo chown -R www-data:www-data "$AIRLINK_PANEL_DIR"
                                   sudo chmod -R 755 "$AIRLINK_PANEL_DIR"
                                   npm install -g typescript && npm install --omit=dev && npm run migrate:dev && npm run build-ts
                                   read -p "Manual install finished. Press Enter..."
                                   ;;
                                3)
                                   cd /etc/ && git clone https://github.com && cd daemon
                                   sudo chown -R www-data:www-data "$AIRLINK_DAEMON_DIR"
                                   sudo chmod -R 755 "$AIRLINK_DAEMON_DIR"
                                   npm install -g typescript && npm install && cp example.env .env && npm run build
                                   read -p "Daemon ready. Configure .env then run 'npm run start'. Press Enter..."
                                   ;;
                                4) # AIRLINK ADDONS SUB-MENU
                                   while true; do
                                       clear
                                       echo "--- AIRLINK ADDONS ---"
                                       echo "1) Install Modrinth Store"
                                       echo "2) Install Parachute"
                                       echo "3) Back"
                                       read -p "Select [1-3]: " addon_c
                                       
                                       ADDONS_BASE="/var/www/panel/storage/addons"
                                       
                                       case "$addon_c" in
                                           1)
                                              echo "Installing Modrinth Store..."
                                              mkdir -p "$ADDONS_BASE/modrinth-store"
                                              cd "$ADDONS_BASE/modrinth-store" || break
                                              wget -q -O modrinth-store.zip "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/modrinth-store.zip"
                                              unzip -o modrinth-store.zip
                                              rm modrinth-store.zip
                                              npm install
                                              npm run build
                                              echo "Modrinth Store installed! Make sure to restart your Airlink Panel."
                                              read -p "Press Enter to continue..."
                                              ;;
                                           2)
                                              echo "Installing Parachute..."
                                              mkdir -p "$ADDONS_BASE/parachute"
                                              cd "$ADDONS_BASE/parachute" || break
                                              wget -q -O parachute.zip "https://raw.githubusercontent.com/$GH_USER/$GH_REPO/main/parachute.zip"
                                              unzip -o parachute.zip
                                              rm parachute.zip
                                              npm install
                                              npm run build
                                              echo "Parachute installed! Make sure to restart your Airlink Panel."
                                              read -p "Press Enter to continue..."
                                              ;;
                                           3) break ;;
                                       esac
                                   done
                                   ;;
                                5)
                                   echo "1) Start 2) Stop 3) PM2 Save/Startup"
                                   read -p "Choice: " s_choice
                                   case "$s_choice" in
                                       1) systemctl start airlink-panel ;;
                                       2) systemctl stop airlink-panel ;;
                                       3) npm install pm2 -g && pm2 start dist/app.js --name "panel" && pm2 save && pm2 startup ;;
                                   esac
                                   ;;
                                6) break ;;
                            esac
                        done
                        ;;
                    3) break ;;
                esac
            done
            ;;

        3) # N8N SUB-MENU
            while true; do
                clear
                echo "--- N8N AUTOMATION ---"
                echo "1) Install n8n (Docker Version)"
                echo "2) Install n8n (NPM Version)"
                echo "3) Back to Main Menu"
                read -p "Select [1-3]: " n8n_c
                case "$n8n_c" in
                    1) echo "Installing via Docker..." ; sleep 2 ;;
                    2) npm install n8n -g ;;
                    3) break ;;
                esac
            done
            ;;

        4) # HOSTING SUB-MENU
            while true; do
                clear
                echo "--- HOSTING PANELS ---"
                echo "1) Install CloudPanel (High Perf)"
                echo "2) Install CyberPanel"
                echo "3) Back to Main Menu"
                read -p "Select [1-3]: " host_c
                case "$host_c" in
                    1) curl -sS https://installer.cloudpanel.io -o install.sh && DB_ENGINE=MARIADB_10.11 bash install.sh ;;
                    2) sh <(curl https://cyberpanel.net || wget -O - https://cyberpanel.net) ;;
                    3) break ;;
                esac
            done
            ;;

        5) # CLOUDFLARE SUB-MENU
            while true; do
                clear
                echo "--- CLOUDFLARE TOOLS ---"
                echo "1) Install Cloudflare Tunnel (cloudflared)"
                echo "2) Enter Token and Start"
                echo "3) Back to Main Menu"
                read -p "Select [1-3]: " cf_c
                case "$cf_c" in
                    1) curl -L -o cf.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && dpkg -i cf.deb && rm cf.deb ;;
                    2) read -p "Token: " cf_token; if [ ! -z "$cf_token" ]; then cloudflared service install "$cf_token"; fi ;;
                    3) break ;;
                esac
            done
            ;;

        6) # SYSTEM MONITOR SUB-MENU
            while true; do
                clear
                echo "--- SYSTEM MONITOR ---"
                echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}')"
                echo "RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
                echo "Disk: $(df -h / | awk '/\// {print $3 "/" $2}')"
                echo "-----------------------"
                echo "1) Refresh"
                echo "2) Run htop"
                echo "3) Back to Main Menu"
                read -p "Select [1-3]: " sys_c
                case "$sys_c" in
                    1) continue ;;
                    2) if ! command -v htop &> /dev/null; then apt install htop -y; fi; htop ;;
                    3) break ;;
                esac
            done
            ;;

        7) exit 0 ;;
        *) read -p "Invalid choice. Press Enter..." ;;
    esac
done
