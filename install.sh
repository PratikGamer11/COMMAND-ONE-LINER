#!/bin/bash

# ==========================================
# DARK PLAYZ - ENHANCED INSTALLER V2
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

# Check Root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}${BLINK}[✗] Please run as root (sudo bash installer.sh)${NC}"
  exit 1
fi

# Functions
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr:$((${i:-0}%${#spinstr})):1}
    printf "\r[${temp}] Processing... "
    sleep $delay
    ((i++))
  done
  printf "\r[✓] Done!                 \n"
}

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
}

system_info() {
  echo -e "${MAGENTA}▓▓▓ SYSTEM INFORMATION ▓▓▓${NC}"
  echo -e "  ${WHITE}OS:${NC}       $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
  echo -e "  ${WHITE}Kernel:${NC}   $(uname -r)"
  echo -e "  ${WHITE}RAM:${NC}      $(free -h | awk '/Mem:/ {print $2}')"
  echo -e "  ${WHITE}CPU:${NC}      $(nproc) Cores @ $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
  echo -e "  ${WHITE}User:${NC}     $(whoami)"
  echo -e "  ${WHITE}Uptime:${NC}   $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | tr -d ',')"
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

# Main Script
header
system_info
menu

read -p "  ${CYAN}Select =>${NC} " option

case $option in
  1)
    echo ""
    warning "This will install the Panel..."
    read -p "Continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      error "Cancelled!"
      exit 1
    fi
    
    log "Updating package lists..."
    (apt update -y &) &
    spinner $!
    success "Packages updated"
    
    log "Installing dependencies: git, nodejs, npm, curl, wget..."
    (apt install -y git nodejs npm curl wget &) &
    spinner $!
    success "Dependencies installed"
    
    if [ -d "crispy-adventure" ]; then
      warning "Removing existing installation..."
      rm -rf crispy-adventure
    fi
    
    log "Cloning Panel repository..."
    (git clone https://github.com/pratikgamer11/crispy-adventure &) &
    spinner $!
    
    if [ ! -d "crispy-adventure" ]; then
      error "Failed to clone repository!"
      exit 1
    fi
    
    cd crispy-adventure || exit
    
    if [ -f "package.json" ]; then
      log "Installing Node modules..."
      (npm install &) &
      spinner $!
    else
      warning "No package.json found, installing express..."
      npm install express
    fi
    
    success "Panel installed successfully!"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}  Panel is ready! Run: cd crispy-adventure && node .${NC}"
    echo -e "${GREEN}════════════════════════════════════════╝${NC}"
    ;;
    
  2)
    echo ""
    log "Installing Java 21 JDK..."
    (apt install -y openjdk-21-jdk &) &
    spinner $!
    success "Java 21 installed"
    echo ""
    java -version
    echo ""
    ;;
    
  3)
    echo ""
    log "Installing Cloudflared..."
    
    dpkg --configure -a
    apt install -f -y
    
    mkdir -p --mode=0755 /usr/share/keyrings
    
    (curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --dearmor -o /usr/share/keyrings/cloudflare-main.gpg &) &
    spinner $!
    
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list
    
    (apt update -y &) &
    spinner $!
    (apt install -y cloudflared &) &
    spinner $!
    
    success "Cloudflared installed!"
    echo ""
    cloudflared --version
    echo ""
    ;;
    
  4)
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
        apt update
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        (curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &) &
        spinner $!
        
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
        
        apt update
        (apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin &) &
        spinner $!
        
        systemctl start docker
        systemctl enable docker
        
        success "Docker installed!"
        docker --version
        ;;
      2)
        log "Installing Nginx..."
        (apt install -y nginx &) &
        spinner $!
        success "Nginx installed!"
        ;;
      3)
        log "Installing Redis..."
        (apt install -y redis-server &) &
        spinner $!
        success "Redis installed!"
        ;;
      4)
        log "Installing UFW Firewall..."
        (apt install -y ufw &) &
        spinner $!
        success "UFW installed!"
        ;;
      5)
        log "Installing Nano..."
        (apt install -y nano &) &
        spinner $!
        success "Nano installed!"
        ;;
      6)
        log "Installing Screen..."
        (apt install -y screen &) &
        spinner $!
        success "Screen installed!"
        ;;
      7)
        log "Installing Htop..."
        (apt install -y htop &) &
        spinner $!
        success "Htop installed!"
        ;;
      8)
        log "Updating system..."
        (apt update -y && apt upgrade -y &) &
        spinner $!
        success "System updated!"
        ;;
      9)
        log "Installing Python 3..."
        (apt install -y python3 python3-pip &) &
        spinner $!
        success "Python 3 installed!"
        python3 --version
        ;;
      10)
        exit 0
        ;;
      *)
        error "Invalid option!"
        ;;
    esac
    ;;
    
  5)
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
    echo -e "${CYAN}Running Services:${NC}"
    systemctl list-units --type=service --state=running | grep -E "nginx|docker|redis" || echo "  No game services running"
    echo ""
    echo -e "${CYAN}Network Connections:${NC}"
    netstat -tuln 2>/dev/null | grep LISTEN | head -5 || ss -tuln | head -5
    echo ""
    ;;
    
  6)
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
    fi
    ;;
    
  7)
    echo ""
    echo -e "${GREEN}Goodbye! Thanks for using Dark Playz Installer${NC}"
    exit 0
    ;;
    
  *)
    error "Invalid option!"
    ;;
esac
