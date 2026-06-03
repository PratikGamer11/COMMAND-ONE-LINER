#!/bin/bash

# ==========================================
#     JAPNEET NETWORK INSTALLER GOD MODE
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

# HELPERS
ok(){ echo -e "${GREEN}[✓] $1${NC}"; }
err(){ echo -e "${RED}[✗] $1${NC}"; }
warn(){ echo -e "${YELLOW}[!] $1${NC}"; }

# CLEAR SCREEN
clear

echo -e "${MAGENTA}"
cat << 'EOF'
     ██╗ █████╗ ██████╗ ███╗   ██╗███████╗███████╗████████╗
     ██║██╔══██╗██╔══██╗████╗  ██║██╔════╝██╔════╝╚══██╔══╝
     ██║███████║██████╔╝██╔██╗ ██║█████╗  █████╗     ██║
██   ██║██╔══██║██╔═══╝ ██║╚██╗██║██╔══╝  ██╔══╝     ██║
╚█████╔╝██║  ██║██║     ██║ ╚████║███████╗███████╗   ██║
 ╚════╝ ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═══╝╚══════╝╚══════╝   ╚═╝

                ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗
                ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
                ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
                ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
                ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
                ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${WHITE}      JAPNEET NETWORK GOD INSTALLER${NC}"
echo -e "${MAGENTA}=====================================${NC}"

# SAFE SERVICE START (NO systemd crash)
start_service() {
  service "$1" start 2>/dev/null || systemctl start "$1" 2>/dev/null
}

# =========================
# PANEL INSTALL (FIXED)
# =========================
install_panel() {
  warn "Installing PANEL + NODEJS..."

  apt update -y

  # Node.js LTS FIXED
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs git curl wget

  ok "Node: $(node -v)"
  ok "NPM: $(npm -v)"

  rm -rf crispy-adventure

  git clone https://github.com/pratikgamer11/crispy-adventure || {
    err "Git clone failed"
    return
  }

  cd crispy-adventure || exit
  npm install

  ok "PANEL INSTALLED SUCCESSFULLY"

  echo ""
  echo -e "${CYAN}START COMMAND:${NC}"
  echo "cd crispy-adventure && node ."
  echo ""

  read -p "Press Enter..."
}

# =========================
# DOCKER (100% SAFE MODE)
# =========================
install_docker() {
  warn "Installing Docker (SAFE MODE)..."

  apt update -y
  apt install -y docker.io

  start_service docker

  ok "Docker installed safely"
  docker --version

  read -p "Press Enter..."
}

# =========================
# OPTIONAL MENU
# =========================
optional_menu() {
  while true; do
    clear
    echo -e "${MAGENTA}OPTIONAL PACKAGES${NC}"
    echo ""
    echo "[1] Docker"
    echo "[2] Nginx"
    echo "[3] Redis"
    echo "[4] UFW"
    echo "[5] Nano"
    echo "[6] Screen"
    echo "[7] Htop"
    echo "[8] Update System"
    echo "[9] Python3"
    echo "[10] Back"
    echo ""

    read -p "Select => " p

    case $p in
      1) install_docker ;;
      2) apt install -y nginx && start_service nginx && ok "Nginx installed" ;;
      3) apt install -y redis-server && start_service redis-server && ok "Redis installed" ;;
      4) apt install -y ufw && ok "UFW installed" ;;
      5) apt install -y nano && ok "Nano installed" ;;
      6) apt install -y screen && ok "Screen installed" ;;
      7) apt install -y htop && ok "Htop installed" ;;
      8) apt update -y && apt upgrade -y && ok "System updated" ;;
      9) apt install -y python3 python3-pip && ok "Python installed" ;;
      10) break ;;
    esac
  done
}

# =========================
# MENU
# =========================
menu() {
  echo ""
  echo -e "${CYAN}[1] Install Panel"
  echo "[2] Install Java 21"
  echo "[3] Install Cloudflared"
  echo "[4] Optional Packages"
  echo "[5] System Check"
  echo "[6] Cleanup"
  echo "[7] Exit${NC}"
  echo ""
}

# =========================
# MAIN
# =========================
menu
read -p "Select => " opt

case $opt in

  1) install_panel ;;

  2)
    warn "Installing Java 21..."

    apt update -y
    apt install -y wget tar

    cd /opt || exit
    wget -q https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz

    tar -xvf jdk-21_linux-x64_bin.tar.gz
    mv jdk-21* java21

    echo 'export JAVA_HOME=/opt/java21' >> ~/.bashrc
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc

    java -version
    ok "Java Installed"
    read -p "Press Enter..."
    ;;

  3)
    warn "Installing Cloudflared..."

    ARCH=$(uname -m)

    case $ARCH in
      x86_64) CF="amd64" ;;
      aarch64) CF="arm64" ;;
      armv7l) CF="arm" ;;
      *) err "Unsupported architecture"; exit 1 ;;
    esac

    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$CF" -o /usr/local/bin/cloudflared
    chmod +x /usr/local/bin/cloudflared

    ok "Cloudflared installed"
    cloudflared --version
    read -p "Press Enter..."
    ;;

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
