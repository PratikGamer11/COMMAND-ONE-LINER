#!/bin/bash

# ==========================================
#   JAPNEET NETWORK SMART INSTALLER V1
# ==========================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[✗] Run as root (sudo bash installer.sh)${NC}"
  exit 1
fi

# =========================
# DETECT ENVIRONMENT
# =========================

IS_CONTAINER=false

if grep -qa docker /proc/1/cgroup 2>/dev/null; then
  IS_CONTAINER=true
fi

if [ -f /.dockerenv ]; then
  IS_CONTAINER=true
fi

# =========================
# HELPERS
# =========================

log(){ echo -e "${CYAN}[$(date '+%H:%M:%S')] $1${NC}"; }
ok(){ echo -e "${GREEN}[✓] $1${NC}"; }
err(){ echo -e "${RED}[✗] $1${NC}"; }
warn(){ echo -e "${YELLOW}[!] $1${NC}"; }

# =========================
# HEADER
# =========================

clear
echo -e "${MAGENTA}"
cat << 'EOF'
██╗ █████╗ ██████╗  ██████╗ ███████╗████████╗
██║██╔══██╗██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝
██║███████║██████╔╝██║   ██║█████╗     ██║
██║██╔══██║██╔═══╝ ██║   ██║██╔══╝     ██║
██║██║  ██║██║     ╚██████╔╝███████╗   ██║
╚═╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝   ╚═╝
EOF
echo -e "${WHITE}      JAPNEET NETWORK SMART INSTALLER${NC}"
echo -e "${MAGENTA}======================================${NC}"

# Show environment
if $IS_CONTAINER; then
  warn "Container environment detected (Pterodactyl / VPS limit mode)"
else
  ok "Full VPS detected"
fi

# =========================
# SAFE SERVICE FUNCTION
# =========================

start_service() {
  service $1 start 2>/dev/null || systemctl start $1 2>/dev/null
}

# =========================
# SAFE DOCKER INSTALL
# =========================

install_docker() {
  warn "Installing Docker (SMART MODE)..."

  apt update -y

  if $IS_CONTAINER; then
    # SAFE MODE FOR CONTAINERS
    apt install -y docker.io
    start_service docker
    ok "Docker installed via docker.io (container safe)"
  else
    # FULL VPS MODE
    apt install -y ca-certificates curl gnupg

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
    > /etc/apt/sources.list.d/docker.list

    apt update -y
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    ok "Docker CE installed (full mode)"
  fi

  docker --version
  echo ""
  read -p "Enter..."
}

# =========================
# MENU
# =========================

menu() {
  echo -e "${CYAN}"
  echo "[1] Install Panel"
  echo "[2] Install Java 21"
  echo "[3] Install Cloudflared"
  echo "[4] Optional Packages"
  echo "[5] System Check"
  echo "[6] Cleanup"
  echo "[7] Exit"
  echo -e "${NC}"
}

optional_menu() {
  while true; do
    clear
    echo -e "${MAGENTA}OPTIONAL PACKAGES (SMART MODE)${NC}"
    echo ""
    echo "[1] Docker"
    echo "[2] Nginx"
    echo "[3] Redis"
    echo "[4] UFW"
    echo "[5] Nano"
    echo "[6] Screen"
    echo "[7] Htop"
    echo "[8] Update"
    echo "[9] Python3"
    echo "[10] Back"
    echo ""

    read -p "Select => " p

    case $p in

      1) install_docker ;;

      2)
        apt update -y
        apt install -y nginx
        start_service nginx
        ok "Nginx installed"
        read -p "Enter..."
        ;;

      3)
        apt update -y
        apt install -y redis-server
        start_service redis-server
        ok "Redis installed"
        read -p "Enter..."
        ;;

      4)
        apt install -y ufw
        ok "UFW installed"
        read -p "Enter..."
        ;;

      5)
        apt install -y nano
        ok "Nano installed"
        read -p "Enter..."
        ;;

      6)
        apt install -y screen
        ok "Screen installed"
        read -p "Enter..."
        ;;

      7)
        apt install -y htop
        ok "Htop installed"
        read -p "Enter..."
        ;;

      8)
        apt update -y && apt upgrade -y
        ok "System updated"
        read -p "Enter..."
        ;;

      9)
        apt install -y python3 python3-pip
        ok "Python installed"
        read -p "Enter..."
        ;;

      10)
        break
        ;;
    esac
  done
}

# =========================
# MAIN
# =========================

menu
read -p "Select => " opt

case $opt in

  4) optional_menu ;;

  5)
    echo "RAM: $(free -h | awk '/Mem:/ {print $3\"/\"$2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3\"/\"$2}')"
    echo "Uptime: $(uptime)"
    ;;

  6)
    apt clean
    rm -rf /tmp/* 2>/dev/null
    ok "Clean done"
    ;;

  7)
    echo "Bye from JAPNEET NETWORK"
    exit
    ;;

  *)
    err "Invalid option"
    ;;
esac
