#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1;31mPlease run as root (sudo bash installer.sh)\033[0m"
  exit
fi

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
    echo -e "${CYAN}[+] Updating packages...${NC}"
    apt update -y
    
    echo -e "${CYAN}[+] Installing dependencies...${NC}"
    apt install -y git nodejs npm curl wget
    
    if [ -d "crispy-adventure" ]; then
      rm -rf crispy-adventure
    fi
    
    echo -e "${CYAN}[+] Cloning Panel...${NC}"
    git clone https://github.com/pratikgamer11/crispy-adventure
    
    if [ ! -d "crispy-adventure" ]; then
      echo -e "${RED}[✗] Failed to clone repository${NC}"
      exit 1
    fi
    
    cd crispy-adventure || exit
    
    if [ -f "package.json" ]; then
      npm install
    else
      echo -e "${YELLOW}[!] No package.json found, installing express...${NC}"
      npm install express
    fi

    echo -e "${GREEN}[✓] Starting Panel...${NC}"
    node .
    ;;

  2)
    echo -e "${CYAN}[+] Installing Java 21...${NC}"

    apt install -y openjdk-21-jdk
    
    java -version
    ;;

  3)
    echo -e "${CYAN}[+] Installing Cloudflared...${NC}"

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
        echo -e "${CYAN}[+] Installing Docker...${NC}"
        # Alternative method if get.docker.com fails
        apt update
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        systemctl start docker
        systemctl enable docker
        
        echo -e "${GREEN}[✓] Docker installed successfully${NC}"
        docker --version
        ;;
      2)
        apt install -y nginx
        echo -e "${GREEN}[✓] Nginx installed${NC}"
        ;;
      3)
        apt install -y redis-server
        echo -e "${GREEN}[✓] Redis installed${NC}"
        ;;
      4)
        apt install -y ufw
        echo -e "${GREEN}[✓] UFW installed${NC}"
        ;;
      5)
        apt install -y nano
        echo -e "${GREEN}[✓] Nano installed${NC}"
        ;;
      6)
        apt install -y screen
        echo -e "${GREEN}[✓] Screen installed${NC}"
        ;;
      7)
        apt install -y htop
        echo -e "${GREEN}[✓] Htop installed${NC}"
        ;;
      8)
        apt update -y && apt upgrade -y
        echo -e "${GREEN}[✓] System updated${NC}"
        ;;
      *)
        echo -e "${RED}Invalid Option!${NC}"
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
