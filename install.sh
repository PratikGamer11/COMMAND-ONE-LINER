#!/bin/bash

# ==========================================
#  JAPNEET NETWORK INSTALLER (FIXED V2)
# ==========================================

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
BLINK='\033[5m'
BOLD='\033[1m'
NC='\033[0m'

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}${BLINK}[✗] PLEASE RUN AS ROOT (sudo bash installer.sh)${NC}"
  exit 1
fi

# FUNCTIONS
log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[✓] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}"; }
warning() { echo -e "${YELLOW}[!] $1${NC}"; }

# HEADER
header() {
  clear
  echo -e "${MAGENTA}"
  cat << 'EOF'
  ██████╗ ███████╗████████╗██████╗
  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗
  ██║  ██║█████╗     ██║   ██████╔╝
  ██║  ██║██╔══╝     ██║   ██╔══██╗
  ██████╔╝███████╗   ██║   ██║  ██║
  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝
EOF
  echo -e "${CYAN}══════════════════════════════${NC}"
  echo -e "${WHITE}${BOLD}   JAPNEET NETWORK INSTALLER  ${NC}"
  echo -e "${CYAN}══════════════════════════════${NC}"
}

# SYSTEM INFO
system_info() {
  echo -e "${MAGENTA}SYSTEM INFO${NC}"
  echo -e "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
  echo -e "Kernel: $(uname -r)"
  echo -e "RAM: $(free -h | awk '/Mem:/ {print $2}')"
  echo -e "CPU: $(nproc) cores"
  echo ""
}

# MENU
menu() {
  echo -e "${MAGENTA}MAIN MENU${NC}"
  echo -e "${CYAN}[1]${NC} Install Panel"
  echo -e "${CYAN}[2]${NC} Install Java 21"
  echo -e "${CYAN}[3]${NC} Install Cloudflared"
  echo -e "${CYAN}[4]${NC} Optional Packages"
  echo -e "${CYAN}[5]${NC} System Check"
  echo -e "${CYAN}[6]${NC} Cleanup System"
  echo -e "${CYAN}[7]${NC} Exit"
}

# OPTIONAL MENU
optional_menu() {
  while true; do
    clear
    echo -e "${MAGENTA}OPTIONAL PACKAGES${NC}"
    echo -e "[1] Docker"
    echo -e "[2] Nginx"
    echo -e "[3] Redis"
    echo -e "[4] UFW"
    echo -e "[5] Nano"
    echo -e "[6] Screen"
    echo -e "[7] Htop"
    echo -e "[8] Update System"
    echo -e "[9] Python3 + Pip"
    echo -e "[10] Back"

    read -p "Select => " p

    case $p in

      1)
        warning "Installing Docker..."
        apt update -y
        apt install -y ca-certificates curl gnupg

        install -m 0755 -d /etc/apt/keyrings

        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list

        apt update -y
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        systemctl enable docker
        systemctl start docker

        success "Docker installed"
        read -p "Enter..."
        ;;

      2)
        apt update -y && apt install -y nginx
        systemctl enable nginx && systemctl start nginx
        success "Nginx installed"
        read -p "Enter..."
        ;;

      3)
        apt update -y && apt install -y redis-server
        systemctl enable redis-server && systemctl start redis-server
        success "Redis installed"
        read -p "Enter..."
        ;;

      4)
        apt update -y && apt install -y ufw
        success "UFW installed"
        read -p "Enter..."
        ;;

      5)
        apt install -y nano
        success "Nano installed"
        read -p "Enter..."
        ;;

      6)
        apt install -y screen
        success "Screen installed"
        read -p "Enter..."
        ;;

      7)
        apt install -y htop
        success "Htop installed"
        read -p "Enter..."
        ;;

      8)
        apt update -y && apt upgrade -y
        success "System updated"
        read -p "Enter..."
        ;;

      9)
        apt install -y python3 python3-pip
        success "Python installed"
        read -p "Enter..."
        ;;

      10)
        break
        ;;
    esac
  done
}

# MAIN SCRIPT
header
system_info
menu

read -p "Select => " opt

case $opt in

  1)
    warning "Installing Panel..."
    apt update -y
    apt install -y git nodejs npm curl wget

    if [ -d "crispy-adventure" ]; then
      rm -rf crispy-adventure
    fi

    git clone https://github.com/pratikgamer11/crispy-adventure

    if [ ! -d "crispy-adventure" ]; then
      error "Clone failed"
      exit 1
    fi

    cd crispy-adventure || exit

    npm install

    success "Panel Installed"
    echo "Run: cd crispy-adventure && node ."
    ;;

  2)
    warning "Installing Java 21..."

    apt update -y
    apt install -y wget tar

    cd /opt || exit
    wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz

    tar -xvf jdk-21_linux-x64_bin.tar.gz
    mv jdk-21* java21

    echo 'export JAVA_HOME=/opt/java21' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc

    java -version
    success "Java installed"
    ;;

  3)
    warning "Installing Cloudflared..."

    ARCH=$(uname -m)

    case $ARCH in
      x86_64) CF="amd64" ;;
      aarch64) CF="arm64" ;;
      armv7l) CF="arm" ;;
      *) error "Unsupported arch"; exit 1 ;;
    esac

    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$CF" -o /usr/local/bin/cloudflared

    chmod +x /usr/local/bin/cloudflared

    if command -v cloudflared >/dev/null; then
      success "Cloudflared installed"
      cloudflared --version
    else
      error "Install failed"
    fi
    ;;

  4)
    optional_menu
    ;;

  5)
    echo "RAM:"
    free -h | awk '/Mem:/ {print $3"/"$2}'

    echo "Disk:"
    df -h /

    echo "CPU:"
    uptime
    ;;

  6)
    warning "Cleaning system..."
    apt clean
    rm -rf /tmp/* 2>/dev/null
    success "Clean done"
    ;;

  7)
    echo "Bye!"
    exit
    ;;

  *)
    error "Invalid option"
    ;;
esac
