#!/bin/bash

# ==========================================
# DARK PLAYZ - ENHANCED INSTALLER V2 (FIXED)
# ==========================================

# Color Codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
MAGENTA='\033[1;35m'
BLINK='\033[5m'
BOLD='\033[1m'
NC='\033[0m'

SPINNERChars='|/-\'

# Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}${BLINK}[✗] Please run as root (sudo bash installer.sh)${NC}"
  exit 1
fi

log() {
  echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"
}

success() {
  echo -e "${GREEN}[✓] $1${NC}"
}

error() {
  echo -e "${RED}[✗] $1${NC}"
}

warning() {
  echo -e "${YELLOW}[!] $1${NC}"
}

header() {
  clear
  echo -e "${RED}"
  cat << 'EOF'
  ██████╗ ███████╗████████╗██████╗  ██████╗ 
  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗
  ██║  ██║█████╗     ██║   ██████╔╝██║   ██║
  ██║  ██║██╔══╝     ██║   ██╔══██╗██║   ██║
  ██████╔╝███████╗   ██║   ██║  ██║╚██████╔╝
  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 
EOF
  echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
  echo -e "${WHITE}${BOLD}            DARK PLAYZ INSTALLER V2${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}    ⚡ Fixed & Improved Version ⚡${NC}"
  echo ""
}

system_info() {
  echo -e "${MAGENTA}▓▓▓ SYSTEM INFORMATION ▓▓▓${NC}"
  local os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Unknown")
  local kernel=$(uname -r)
  local ram=$(free -h | awk '/Mem:/ {print $2}')
  local cpu_cores=$(nproc)
  local cpu_model=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
  local user=$(whoami)
  local uptime_str=$(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | tr -d ',')
  
  echo -e "  ${WHITE}OS:${NC}       ${os_name}"
  echo -e "  ${WHITE}Kernel:${NC}   ${kernel}"
  echo -e "  ${WHITE}RAM:${NC}      ${ram}"
  echo -e "  ${WHITE}CPU:${NC}      ${cpu_cores} Cores @ ${cpu_model}"
  echo -e "  ${WHITE}User:${NC}     ${user}"
  echo -e "  ${WHITE}Uptime:${NC}   ${uptime_str}"
  echo ""
}

menu() {
  echo -e "${MAGENTA}▓▓▓▓▓▓▓▓▓▓▓ MAIN MENU ▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo ""
  echo -e "  ${CYAN}[1]${NC} ${WHITE}Install Panel${NC}              - Setup game panel"
  echo -e "  ${CYAN}[2]${NC} ${WHITE}Install Java 21${NC}            - Java runtime"
  echo -e "  ${CYAN}[3]${NC} ${WHITE}Install Cloudflared${NC}       - Tunnel service"
  echo -e "  ${CYAN}[4]${NC} ${WHITE}Optional Packages${NC}         - Additional tools"
  echo -e "  ${CYAN}[5]${NC} ${WHITE}System Health Check${NC}        - Check system status"
  echo -e "  ${CYAN}[6]${NC} ${WHITE}Cleanup System${NC}            - Free up space"
  echo -e "  ${CYAN}[7]${NC} ${WHITE}Exit${NC}                      - Goodbye!"
  echo ""
}

install_panel() {
  echo ""
  warning "This will install the Panel..."
  read -p "Continue? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    error "Cancelled!"
    exit 1
  fi
  
  log "Updating package lists..."
  apt update -y 2>&1 | tail -5
  
  log "Installing dependencies: git, curl, wget..."
  apt install -y git curl wget 2>&1 | grep -E "Setting up|already" || true
  
  if ! command -v node &> /dev/null; then
    log "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - 2>&1 | tail -3
    apt install -y nodejs 2>&1 | grep -E "Setting up|already" || true
  else
    success "Node.js already installed: $(node --version)"
  fi
  
  if ! command -v npm &> /dev/null; then
    log "Installing npm..."
    apt install -y npm 2>&1 | tail -3
  fi
  
  if [ -d "crispy-adventure" ]; then
    warning "Removing existing installation..."
    rm -rf crispy-adventure
  fi
  
  log "Cloning Panel repository..."
  if git clone https://github.com/pratikgamer11/crispy-adventure 2>&1; then
    success "Repository cloned!"
  else
    error "Failed to clone repository!"
    exit 1
  fi
  
  cd crispy-adventure || exit 1
  
  if [ -f "package.json" ]; then
    log "Installing Node modules..."
    npm install --legacy-peer-deps 2>&1 | tail -10
    success "Node modules installed!"
  else
    warning "No package.json found, installing express..."
    npm install express --legacy-peer-deps
  fi
  
  success "Panel installed successfully!"
  echo ""
  echo -e "${GREEN}════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}  Panel is ready!${NC}"
  echo -e "${GREEN}  Run: cd crispy-adventure && node index.js${NC}"
  echo -e "${GREEN}════════════════════════════════════════╝${NC}"
}

install_java() {
  echo ""
  log "Installing Java 21 JDK..."
  
  log "Adding Adoptium repository..."
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - 2>&1
  echo "deb https://packages.adoptium.net/artifactory/deb $(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2) main" | tee /etc/apt/sources.list.d/adoptium.list
  
  apt update -y 2>&1 | tail -3
  
  apt install -y temurin-21-jdk 2>&1 | tail -5
  
  export JAVA_HOME=/usr/lib/jvm/temurin-21-jdk
  export PATH=$JAVA_HOME/bin:$PATH
  
  success "Java 21 installed!"
  echo ""
  java -version 2>&1 | head -1
  echo ""
}

install_cloudflared() {
  echo ""
  log "Installing Cloudflared..."
  
  dpkg --configure -a 2>&1 | tail -2
  mkdir -p --mode=0755 /usr/share/keyrings
  
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg 2>&1
  
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' > /etc/apt/sources.list.d/cloudflared.list
  
  apt update -y 2>&1 | tail -3
  apt install -y cloudflared 2>&1 | tail -5
  
  success "Cloudflared installed!"
  echo ""
  cloudflared --version
  echo ""
}

optional_packages() {
  clear
  echo -e "${MAGENTA}═══════════════════════════════${NC}"
  echo -e "${WHITE}      OPTIONAL PACKAGES${NC}"
  echo -e "${MAGENTA}═══════════════════════════════${NC}"
  echo ""
  echo "[1] Docker & Docker Compose"
  echo "[2] Nginx Web Server"
  echo "[3] Redis Database"
  echo "[4] UFW Firewall"
  echo "[5] Nano Editor"
  echo "[6] Screen Manager"
  echo "[7] Htop Monitor"
  echo "[8] Update System"
  echo "[9] Python 3 & Pip"
  echo "[10] Go Back"
  echo ""
  
  read -p "Select Package: " pkg
  
  case $pkg in
    1)
      log "Installing Docker..."
      apt update -y
      apt install -y ca-certificates curl gnupg lsb-release 2>&1 | tail -3
      mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
      apt update -y
      apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>&1 | tail -5
      systemctl start docker 2>/dev/null || true
      systemctl enable docker 2>/dev/null || true
      success "Docker installed!"
      docker --version 2>/dev/null || docker-compose version
      ;;
    2)
      log "Installing Nginx..."
      apt update -y
      apt install -y nginx 2>&1 | tail -3
      systemctl start nginx 2>/dev/null || true
      systemctl enable nginx 2>/dev/null || true
      success "Nginx installed!"
      nginx -v 2>&1
      ;;
    3)
      log "Installing Redis..."
      apt update -y
      apt install -y redis-server 2>&1 | tail -3
      systemctl start redis-server 2>/dev/null || true
      systemctl enable redis-server 2>/dev/null || true
      success "Redis installed!"
      ;;
    4)
      log "Installing UFW Firewall..."
      apt update -y
      apt install -y ufw 2>&1 | tail -3
      success "UFW installed!"
      echo -e "${YELLOW}Note: Run 'ufw enable' to activate${NC}"
      ;;
    5)
      log "Installing Nano..."
      apt update -y
      apt install -y nano 2>&1 | tail -3
      success "Nano installed!"
      nano --version 2>&1 | head -1
      ;;
    6)
      log "Installing Screen..."
      apt update -y
      apt install -y screen 2>&1 | tail -3
      success "Screen installed!"
      ;;
    7)
      log "Installing Htop..."
      apt update -y
      apt install -y htop 2>&1 | tail -3
      success "Htop installed!"
      ;;
    8)
      log "Updating system..."
      apt update -y
      apt upgrade -y
      success "System updated!"
      ;;
    9)
      log "Installing Python 3..."
      apt update -y
      apt install -y python3 python3-pip 2>&1 | tail -3
      success "Python 3 installed!"
      python3 --version
      ;;
    10)
      return
      ;;
    *)
      error "Invalid option!"
      ;;
  esac
}

system_health() {
  echo ""
  echo -e "${MAGENTA}▓▓▓ SYSTEM HEALTH CHECK ▓▓▓${NC}"
  echo ""
  
  echo -e "${CYAN}Memory Usage:${NC}"
  free -h | awk '/Mem:/ {printf "  Used: %s / Total: %s (%.0f%%)\n", $3, $2, ($3/$2)*100}'
  echo ""
  
  echo -e "${CYAN}Disk Usage:${NC}"
  df -h / | awk 'NR==2 {printf "  Used: %s / Total: %s (%s)\n", $3, $2, $5}'
  echo ""
  
  echo -e "${CYAN}CPU Load:${NC}"
  uptime | awk -F'load average:' '{print "  " $2}'
  echo ""
  
  echo -e "${CYAN}Game Services Status:${NC}"
  for svc in nginx docker redis; do
    if systemctl is-active --quiet $svc 2>/dev/null; then
      echo -e "  ${GREEN}●${NC} $svc: Running"
    else
      echo -e "  ${RED}○${NC} $svc: Not running"
    fi
  done
  echo ""
  
  echo -e "${CYAN}Network Ports:${NC}"
  if command -v ss &> /dev/null; then
    ss -tuln 2>/dev/null | grep LISTEN | head -5 | awk '{print "  " $1 ":" $5}' || echo "  No listeners"
  else
    echo "  ss command not available"
  fi
  echo ""
  
  echo -e "${CYAN}Top Processes by Memory:${NC}"
  ps aux --sort=-%mem | awk 'NR<=6 {print "  " $11,$6}'
  echo ""
}

cleanup_system() {
  warning "This will clean temporary files and cache..."
  read -p "Continue? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    log "Cleaning apt cache..."
    apt clean all
    log "Removing old logs..."
    find /var/log -type f -name "*.log" -delete 2>/dev/null
    log "Cleaning tmp..."
    rm -rf /tmp/* 2>/dev/null
    success "System cleaned!"
  else
    error "Cancelled!"
  fi
}

# ==========================================
# MAIN SCRIPT
# ==========================================
header
system_info
menu

read -p "  ${CYAN}Select =>${NC} " option

case $option in
  1) install_panel ;;
  2) install_java ;;
  3) install_cloudflared ;;
  4) optional_packages ;;
  5) system_health ;;
  6) cleanup_system ;;
  7)
    echo ""
    echo -e "${GREEN}Goodbye! Thanks for using Dark Playz Installer${NC}"
    exit 0
    ;;
  *)
    error "Invalid option!"
    ;;
esac
