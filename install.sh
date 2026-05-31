#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

echo -e "${RED}"
cat << "EOF"

██████╗  █████╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝
██║  ██║███████║██████╔╝█████╔╝
██║  ██║██╔══██║██╔══██╗██╔═██╗
██████╔╝██║  ██║██║  ██║██║  ██╗
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

EOF

echo -e "${WHITE}             DARK PLAYZ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
RAM=$(free -h | awk '/Mem:/ {print $2}')
CPU=$(nproc)
DISK=$(df -h / | awk 'NR==2 {print $2}')
USER=$(whoami)

echo -e "${GREEN}• OS     ${NC}: $OS"
echo -e "${GREEN}• RAM    ${NC}: $RAM"
echo -e "${GREEN}• CPU    ${NC}: $CPU Cores"
echo -e "${GREEN}• DISK   ${NC}: $DISK"
echo -e "${GREEN}• USER   ${NC}: $USER"

echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}[1] Install Panel${NC}"
echo -e "${YELLOW}[2] Install Java 21${NC}"
echo -e "${YELLOW}[3] Exit${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

read -p "Select ➜ " option

case $option in

1)
    clear
    echo -e "${CYAN}[+] Installing Panel...${NC}"

    apt update -y
    apt install -y git nodejs npm curl wget

    git clone https://github.com/pratikgamer11/crispy-adventure

    cd crispy-adventure || exit

    npm install express

    echo -e "${GREEN}[✓] Panel Installed!${NC}"

    node .
    ;;

2)
    clear
    echo -e "${CYAN}[+] Installing Java 21...${NC}"

    wget -O jdk21.deb https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb

    dpkg -i jdk21.deb

    echo ""
    echo -e "${GREEN}[✓] Java Installed Successfully!${NC}"
    java -version

    rm -f jdk21.deb
    ;;

3)
    echo -e "${GREEN}Thanks for using DARK PLAYZ!${NC}"
    exit
    ;;

*)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
