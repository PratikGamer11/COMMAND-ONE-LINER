#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

echo -e "${RED}"
cat << 'EOF'
██████╗  █████╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝
██║  ██║███████║██████╔╝█████╔╝
██║  ██║██╔══██║██╔══██╗██╔═██╗
██████╔╝██║  ██║██║  ██║██║  ██╗
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
EOF

echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${WHITE}               DARK PLAYZ INSTALLER${NC}"
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
echo -e "${YELLOW}[3] Install Cloudflared${NC}"
echo -e "${YELLOW}[4] Exit${NC}"
echo ""

read -p "Select => " option

case $option in

  1)
    echo ""
    echo -e "${CYAN}[+] Updating System...${NC}"
    apt update -y

    echo -e "${CYAN}[+] Installing Dependencies...${NC}"
    apt install git nodejs npm curl wget -y

    echo -e "${CYAN}[+] Downloading Panel...${NC}"
    git clone https://github.com/pratikgamer11/crispy-adventure

    cd crispy-adventure || exit

    echo -e "${CYAN}[+] Installing NPM Packages...${NC}"
    npm install express

    echo -e "${GREEN}[✓] Installation Completed!${NC}"
    echo -e "${GREEN}[✓] Starting Panel...${NC}"

    node .
    ;;

  2)
    echo ""
    echo -e "${CYAN}[+] Installing Java 21...${NC}"

    wget -q https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb

    dpkg -i jdk-21_linux-x64_bin.deb

    echo -e "${GREEN}[✓] Java 21 Installed!${NC}"
    java -version
    ;;

  3)
    echo ""
    echo -e "${CYAN}[+] Installing Cloudflared...${NC}"

    mkdir -p --mode=0755 /usr/share/keyrings

    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg

    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
    tee /etc/apt/sources.list.d/cloudflared.list

    apt update -y
    apt install -y cloudflared

    echo -e "${GREEN}[✓] Cloudflared Installed Successfully!${NC}"
    cloudflared --version
    ;;

  4)
    echo -e "${GREEN}Bye!${NC}"
    exit 0
    ;;

  *)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
