#!/bin/bash

# ==========================================
#  JAPNEET NETWORK INSTALLER
#  FULLY FIXED VERSION
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
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr:$(($i % ${#spinstr})):1}
    printf "\r[${temp}] Processing... "
    sleep $delay
    ((i++))
  done
  printf "\r[✓] DONE!                 \n"
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

# HEADER
header() {
  clear
  echo -e "${MAGENTA}"
  cat << 'EOF'
  ██████╗ ███████╗████████╗██████╗  ██████╗ 
  ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗
  ██║  ██║█████╗     ██║   ██████╔╝██║   ██║
  ██║  ██║██╔══╝     ██║   ██╔══██╗██║   ██║
  ██████╔╝███████╗   ██║   ██║  ██║╚██████╔╝
  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ 
EOF
  echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
  echo -e "${WHITE}${BOLD}              JAPNEET NETWORK                ${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
  echo ""
}

# SYSTEM INFO
system_info() {
  echo -e "${MAGENTA}▓▓▓▓▓▓▓▓▓▓▓ SYSTEM INFORMATION ▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo ""
  echo -e "  ${WHITE}OS:${NC}       $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
  echo -e "  ${WHITE}Kernel:${NC}   $(uname -r)"
  echo -e "  ${WHITE}RAM:${NC}      $(free -h | awk '/Mem:/ {print $2}')"
  echo -e "  ${WHITE}CPU:${NC}      $(nproc) Cores @ $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
  echo -e "  ${WHITE}User:${NC}     $(whoami)"
  echo -e "  ${WHITE}Uptime:${NC}   $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | tr -d ',')"
  echo ""
}

# MAIN MENU
main_menu() {
  echo -e "${MAGENTA}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ MAIN MENU ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo ""
  echo -e "  ${CYAN}[1]${NC} ${WHITE}INSTALL PANEL${NC}              - Setup game panel"
  echo -e "  ${CYAN}[2]${NC} ${WHITE}INSTALL JAVA 21${NC}            - Java runtime"
  echo -e "  ${CYAN}[3]${NC} ${WHITE}INSTALL CLOUDFLARED${NC}       - Tunnel service"
  echo -e "  ${CYAN}[4]${NC} ${WHITE}OPTIONAL PACKAGES${NC}         - Additional tools"
  echo -e "  ${CYAN}[5]${NC} ${WHITE}SYSTEM HEALTH CHECK${NC}        - Check system status"
  echo -e "  ${CYAN}[6]${NC} ${WHITE}CLEANUP SYSTEM${NC}            - Free up space"
  echo -e "  ${CYAN}[7]${NC} ${WHITE}EXIT${NC}                      - Goodbye!"
  echo ""
}

# OPTIONAL PACKAGES
optional_packages_menu() {
  while true; do
    clear
    echo -e "${MAGENTA}═══════════════════════════ OPTIONAL PACKAGES ═════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} ${WHITE}DOCKER & DOCKER COMPOSE${NC}"
    echo -e "  ${CYAN}[2]${NC} ${WHITE}NGINX WEB SERVER${NC}"
    echo -e "  ${CYAN}[3]${NC} ${WHITE}REDIS DATABASE${NC}"
    echo -e "  ${CYAN}[4]${NC} ${WHITE}UFW FIREWALL${NC}"
    echo -e "  ${CYAN}[5]${NC} ${WHITE}NANO EDITOR${NC}"
    echo -e "  ${CYAN}[6]${NC} ${WHITE}SCREEN MANAGER${NC}"
    echo -e "  ${CYAN}[7]${NC} ${WHITE}HTOP MONITOR${NC}"
    echo -e "  ${CYAN}[8]${NC} ${WHITE}UPDATE SYSTEM${NC}"
    echo -e "  ${CYAN}[9]${NC} ${WHITE}PYTHON 3 & PIP${NC}"
    echo -e "  ${CYAN}[10]${NC} ${WHITE}GO BACK${NC}"
    echo ""
    
    read -p "  ${CYAN}Select =>${NC} " pkg
    
    case $pkg in
      1)
        echo ""
        warning "Installing Docker & Docker Compose..."
        log "Updating packages..."
        apt update -y
        
        log "Installing dependencies..."
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        log "Adding Docker GPG key..."
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        log "Adding Docker repository..."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
        
        log "Updating packages..."
        apt update -y
        
        log "Installing Docker..."
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        log "Starting Docker..."
        systemctl start docker
        systemctl enable docker
        
        success "Docker installed successfully!"
        docker --version
        docker-compose --version
        
        read -p "Press Enter to continue..."
        ;;
        
      2)
        echo ""
        warning "Installing Nginx..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Nginx..."
        apt install -y nginx
        
        log "Starting Nginx..."
        systemctl start nginx
        systemctl enable nginx
        
        success "Nginx installed successfully!"
        nginx -v
        
        read -p "Press Enter to continue..."
        ;;
        
      3)
        echo ""
        warning "Installing Redis..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Redis..."
        apt install -y redis-server
        
        log "Starting Redis..."
        systemctl start redis-server
        systemctl enable redis-server
        
        success "Redis installed successfully!"
        redis-server --version
        
        read -p "Press Enter to continue..."
        ;;
        
      4)
        echo ""
        warning "Installing UFW Firewall..."
        log "Updating packages..."
        apt update -y
        
        log "Installing UFW..."
        apt install -y ufw
        
        success "UFW installed successfully!"
        ufw --version
        
        read -p "Press Enter to continue..."
        ;;
        
      5)
        echo ""
        warning "Installing Nano..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Nano..."
        apt install -y nano
        
        success "Nano installed successfully!"
        nano --version
        
        read -p "Press Enter to continue..."
        ;;
        
      6)
        echo ""
        warning "Installing Screen..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Screen..."
        apt install -y screen
        
        success "Screen installed successfully!"
        screen --version
        
        read -p "Press Enter to continue..."
        ;;
        
      7)
        echo ""
        warning "Installing Htop..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Htop..."
        apt install -y htop
        
        success "Htop installed successfully!"
        htop --version
        
        read -p "Press Enter to continue..."
        ;;
        
      8)
        echo ""
        warning "Updating System..."
        log "Updating package lists..."
        apt update -y
        
        log "Upgrading packages..."
        apt upgrade -y
        
        success "System updated successfully!"
        
        read -p "Press Enter to continue..."
        ;;
        
      9)
        echo ""
        warning "Installing Python 3 & Pip..."
        log "Updating packages..."
        apt update -y
        
        log "Installing Python 3 & Pip..."
        apt install -y python3 python3-pip
        
        success "Python 3 installed successfully!"
        python3 --version
        pip3 --version
        
        read -p "Press Enter to continue..."
        ;;
        
      10)
        break
        ;;
        
      *)
        error "Invalid option! Please select 1-10"
        sleep 2
        ;;
    esac
  done
}

# MAIN SCRIPT
header
system_info
main_menu

read -p "  ${CYAN}Select =>${NC} " option

case $option in
  1)
    echo ""
    warning "This will install the Panel..."
    read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      error "Cancelled!"
      exit 1
    fi
    
    log "Updating package lists..."
    apt update -y
    success "Packages updated"
    
    log "Installing dependencies: git, nodejs, npm, curl, wget..."
    apt install -y git nodejs npm curl wget
    success "Dependencies installed"
    
    if [ -d "crispy-adventure" ]; then
      warning "Removing existing installation..."
      rm -rf crispy-adventure
    fi
    
    log "Cloning Panel repository..."
    git clone https://github.com/pratikgamer11/crispy-adventure
    
    if [ ! -d "crispy-adventure" ]; then
      error "Failed to clone repository!"
      exit 1
    fi
    
    cd crispy-adventure || exit
    
    if [ -f "package.json" ]; then
      log "Installing Node modules..."
      npm install
    else
      warning "No package.json found, installing express..."
      npm install express
    fi
    
    success "Panel installed successfully!"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           PANEL INSTALLED SUCCESSFULLY!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}▓▓▓ START PANEL WITH THESE COMMANDS: ▓▓▓${NC}"
    echo ""
    echo -e "${CYAN}  cd crispy-adventure${NC}"
    echo -e "${CYAN}  node .${NC}"
    echo ""
    echo -e "${MAGENTA}  OR IN ONE LINE:${NC}"
    echo -e "${WHITE}  cd crispy-adventure && node .${NC}"
    echo ""
    ;;
    
  2)
    echo ""
    warning "This will install Java 21..."
    read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      error "Cancelled!"
      exit 1
    fi
    
    log "Updating packages..."
    apt update -y
    
    log "Installing Java 21 JDK..."
    apt install -y openjdk-21-jdk
    success "Java 21 installed"
    echo ""
    java -version
    echo ""
    ;;
    
  3)
    echo ""
    warning "This will install Cloudflared..."
    read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      error "Cancelled!"
      exit 1
    fi
    
    log "Installing Cloudflared using binary method..."
    
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
      CLOUDFLARED_ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ]; then
      CLOUDFLARED_ARCH="arm64"
    elif [ "$ARCH" = "armv7l" ]; then
      CLOUDFLARED_ARCH="arm"
    else
      error "Unsupported architecture: $ARCH"
      exit 1
    fi
    
    log "Downloading cloudflared for ${CLOUDFLARED_ARCH}..."
    curl -sSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CLOUDFLARED_ARCH}" -o /usr/local/bin/cloudflared
    
    chmod +x /usr/local/bin/cloudflared
    
    if command -v cloudflared &> /dev/null; then
      success "Cloudflared installed successfully!"
      echo ""
      cloudflared --version
    else
      error "Failed to install Cloudflared!"
      exit 1
    fi
    
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo -e "  cloudflared tunnel --url localhost:3000"
    echo ""
    ;;
    
  4)
    optional_packages_menu
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
    uptime |
 ;;
