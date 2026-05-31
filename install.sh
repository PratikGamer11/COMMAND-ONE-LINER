#!/bin/bash

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
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
echo -e "${YELLOW}[2] Install Java 21${NC}"
echo -e "${YELLOW}[3] Basic Installer${NC}"
echo -e "${YELLOW}[4] Exit${NC}"
echo ""

read -p "Select ➜ " option

case $option in
  1)
    echo -e "${CYAN}[+] Updating System...${NC}"
    apt update -y
    echo -e "${CYAN}[+] Installing Dependencies...${NC}"
    apt install git nodejs npm curl wget -y
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
    echo -e "${CYAN}[+] Installing Java 21...${NC}"
    wget -q https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
    dpkg -i jdk-21_linux-x64_bin.deb
    echo -e "${GREEN}[✓] Java 21 Installed Successfully!${NC}"
    java -version
    ;;
  3)
    echo -e "${CYAN}[+] Starting Basic Installer...${NC}"
    echo -e "${CYAN}[+] Updating Package Lists...${NC}"
    apt update -y
    echo -e "${CYAN}[+] Upgrading Packages...${NC}"
    apt upgrade -y
    echo -e "${CYAN}[+] Installing Node.js & NPM...${NC}"
    apt install nodejs npm -y
    echo -e "${CYAN}[+] Installing Essential Dependencies...${NC}"
    apt install git curl wget unzip build-essential libssl-dev -y
    echo -e "${CYAN}[+] Installing Python & Python Pip...${NC}"
    apt install python3 python3-pip -y
    echo -e "${CYAN}[+] Installing Screen & Htop...${NC}"
    apt install screen htop -y
    echo -e "${GREEN}[✓] Basic Installer Completed!${NC}"
    echo -e "${GREEN}[✓] Node Version: $(node -v)${NC}"
    echo -e "${GREEN}[✓] NPM Version: $(npm -v)${NC}"
    ;;
  4)
    echo -e "${GREEN}Goodbye!${NC}"
    exit
    ;;
  *)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
