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
echo -e "${WHITE}         DARK PLAYZ INSTALLER${NC}"
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
echo -e "${YELLOW}[4] Optional Packages${NC}"
echo -e "${YELLOW}[5] Exit${NC}"
echo ""

read -p "Select => " option

case $option in

  1)
    apt update -y
    apt install -y git nodejs npm curl wget

    git clone https://github.com/pratikgamer11/crispy-adventure
    cd crispy-adventure || exit

    npm install express

    echo -e "${GREEN}[✓] Starting Panel...${NC}"
    node .
    ;;

  2)
    echo -e "${CYAN}[+] Installing Java 21...${NC}"

    wget -q https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
    dpkg -i jdk-21_linux-x64_bin.deb

    java -version
    ;;

  3)
    echo -e "${CYAN}[+] Fixing Packages...${NC}"

    dpkg --configure -a
    apt install -f -y

    mkdir -p --mode=0755 /usr/share/keyrings

    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg

    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
    tee /etc/apt/sources.list.d/cloudflared.list

    apt update -y
    apt install -y cloudflared

    cloudflared --version
    ;;

  4)
    clear

    echo -e "${CYAN}══════════════════════════════${NC}"
    echo -e "${WHITE}      OPTIONAL PACKAGES${NC}"
    echo -e "${CYAN}══════════════════════════════${NC}"

    echo ""
    echo "[1] Docker"
    echo "[2] Nginx"
    echo "[3] Redis"
    echo "[4] UFW Firewall"
    echo "[5] Nano"
    echo "[6] Screen"
    echo "[7] Htop"
    echo "[8] Update System"
    echo ""

    read -p "Select Package => " pkg

    case $pkg in
      1)
        curl -fsSL https://get.docker.com | sh
        ;;
      2)
        apt install -y nginx
        ;;
      3)
        apt install -y redis-server
        ;;
      4)
        apt install -y ufw
        ;;
      5)
        apt install -y nano
        ;;
      6)
        apt install -y screen
        ;;
      7)
        apt install -y htop
        ;;
      8)
        apt update -y && apt upgrade -y
        ;;
      *)
        echo "Invalid Option!"
        ;;
    esac
    ;;

  5)
    echo -e "${GREEN}Bye!${NC}"
    exit 0
    ;;

  *)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
