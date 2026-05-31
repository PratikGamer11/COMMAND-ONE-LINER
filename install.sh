case $option in
1)
    echo ""
    echo -e "${CYAN}[+] Updating System...${NC}"
    apt update -y

    echo -e "${CYAN}[+] Installing Dependencies...${NC}"
    apt install git nodejs npm curl -y

    echo -e "${CYAN}[+] Downloading Files...${NC}"
    git clone https://github.com/pratikgamer11/crispy-adventure

    cd crispy-adventure || exit

    echo -e "${CYAN}[+] Installing NPM Packages...${NC}"
    npm install express

    echo -e "${GREEN}[✓] Installation Completed!${NC}"
    echo -e "${GREEN}[✓] Starting Application...${NC}"

    node .
    ;;

2)
    echo ""
    echo -e "${CYAN}[+] Installing Java 21...${NC}"

    wget -O jdk21.deb https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
    dpkg -i jdk21.deb

    echo -e "${GREEN}[✓] Java 21 Installed!${NC}"
    java -version

    rm -f jdk21.deb
    ;;

3)
    echo "Goodbye!"
    exit
    ;;

*)
    echo -e "${RED}Invalid Option!${NC}"
    ;;
esac
