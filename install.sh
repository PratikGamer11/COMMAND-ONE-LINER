#!/bin/bash

# ==========================================
# GT INSTALLER - FULL FIXED VERSION
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
  local i=0
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr:$(($i % ${#spinstr})):1}
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
  echo -e "${WHITE}${BOLD}              GT INSTALLER${NC}"
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

main_menu() {
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
    warning "This will install Cloudflared..."
    read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      error "Cancelled!"
      exit 1
    fi
    
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
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  cloudflared tunnel --url localhost:3000"
    echo ""
    ;;
    
  4)
    clear
    echo -e "${MAGENTA}═══════════════════════════════════════════════${NC}"
    echo -e "${WHITE}          OPTIONAL PACKAGES                 ${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}[1]${NC} ${WHITE}Docker & Docker Compose${NC}"
    echo -e "  ${CYAN}[2]${NC} ${WHITE}Nginx Web Server${NC}"
    echo -e "  ${CYAN}[3]${NC} ${WHITE}Redis Database${NC}"
    echo -e "  ${CYAN}[4]${NC} ${WHITE}UFW Firewall${NC}"
    echo -e "  ${CYAN}[5]${NC} ${WHITE}Nano Editor${NC}"
    echo -e "  ${CYAN}[6]${NC} ${WHITE}Screen Manager${NC}"
    echo -e "  ${CYAN}[7]${NC} ${WHITE}Htop Monitor${NC}"
    echo -e "  ${CYAN}[8]${NC} ${WHITE}Update System${NC}"
    echo -e "  ${CYAN}[9]${NC} ${WHITE}Python 3 & Pip${NC}"
    echo -e "  ${CYAN}[10]${NC} ${WHITE}Go Back${NC}"
    echo ""
    
    read -p "  ${CYAN}Select =>${NC} " pkg
    
    case $pkg in
      1)
        echo ""
        warning "Installing Docker & Docker Compose..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing dependencies..."
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        log "Adding Docker GPG key..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        log "Adding Docker repository..."
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
        
        log "Updating packages..."
        apt update
        
        log "Installing Docker..."
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        log "Starting Docker..."
        systemctl start docker
        systemctl enable docker
        
        success "Docker installed successfully!"
        echo ""
        docker --version
        docker-compose --version
        ;;
        
      2)
        echo ""
        warning "Installing Nginx..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Nginx..."
        apt install -y nginx
        
        log "Starting Nginx..."
        systemctl start nginx
        systemctl enable nginx
        
        success "Nginx installed successfully!"
        echo ""
        nginx -v
        ;;
        
      3)
        echo ""
        warning "Installing Redis..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Redis..."
        apt install -y redis-server
        
        log "Starting Redis..."
        systemctl start redis-server
        systemctl enable redis-server
        
        success "Redis installed successfully!"
        echo ""
        redis-server --version
        ;;
        
      4)
        echo ""
        warning "Installing UFW Firewall..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing UFW..."
        apt install -y ufw
        
        success "UFW installed successfully!"
        echo ""
        ufw --version
        ;;
        
      5)
        echo ""
        warning "Installing Nano..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Nano..."
        apt install -y nano
        
        success "Nano installed successfully!"
        echo ""
        nano --version
        ;;
        
      6)
        echo ""
        warning "Installing Screen..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Screen..."
        apt install -y screen
        
        success "Screen installed successfully!"
        echo ""
        screen --version
        ;;
        
      7)
        echo ""
        warning "Installing Htop..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Htop..."
        apt install -y htop
        
        success "Htop installed successfully!"
        echo ""
        htop --version
        ;;
        
      8)
        echo ""
        warning "Updating System..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating package lists..."
        (apt update -y &) &
        spinner $!
        
        log "Upgrading packages..."
        (apt upgrade -y &) &
        spinner $!
        
        success "System updated successfully!"
        ;;
        
      9)
        echo ""
        warning "Installing Python 3 & Pip..."
        read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          error "Cancelled!"
          exit 1
        fi
        
        log "Updating packages..."
        apt update
        
        log "Installing Python 3 & Pip..."
        apt install -y python3 python3-pip
        
        success "Python 3 installed successfully!"
        echo ""
        python3 --version
        pip3 --version
        ;;
        
      10)
        echo ""
        log "Going back..."
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
    ;;
    
  6)
    warning "This will clean temporary files..."
    read -p "  DO YOU WANT TO CONTINUE = [Y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      log "Cleaning apt cache..."
      apt clean all
      log "Removing old logs..."
      find /var/log -type f -name "*.log" -delete 2>/dev/null
      rm -rf /tmp/* 2>/dev/null
      success "
