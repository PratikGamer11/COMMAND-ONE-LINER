#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

# Logo
echo -e "${RED}"
cat << "EOF"

██████╗  █████╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝
██║  ██║███████║██████╔╝█████╔╝
██║  ██║██╔══██║██╔══██╗██╔═██╗
██████╔╝██║  ██║██║  ██║██║  ██╗
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

EOF

echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${WHITE}          DARK PLAYZ INSTALLER${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"

echo ""
echo -e "${GREEN}System Information${NC}"
echo -e "OS      : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
echo -e "RAM     : $(free -h | awk '/Mem:/ {print $2}')"
echo -e "CPU     : $(nproc) Cores"
echo -e "User    : $(whoami)"
echo ""

echo -e "${YELLOW}[1] Install Panel${NC}"
echo -e "${YELLOW}[2] Exit${NC}"
echo ""

read -p "Select ➜ " option

case $option in
1)
    echo ""
    echo -e "${CYAN}[+] Updating System...${NC}"
    apt update -y

    echo -e "${CYAN}[+] Installing Dependencies...${NC}"
    apt install git nodejs npm curl -y

    echo -e "${CYAN}[+] Downloading Files...${NC}"
    git clone https://github.com/pratikgamer11/crispy-adventure

    cd crispy-adventure || exit

    echo -e "${CYAN}[+] Installing NPM Packages...${NC}"
    npm install express

    echo -e "${GREEN}[✓] Installation Completed!${NC}"
    echo -e "${GREEN}[✓] Starting Application...${NC}"

    node .
    ;;
2)
    echo "Goodbye!"
    exit
    ;;
*)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
