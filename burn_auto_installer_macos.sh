#!/bin/bash

# Color and icon definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_RESTART="🔄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_EXIT="❌"
ICON_REMOVE="🗑️"
ICON_VIEW="👀"

# Global variables
PROJECT_NAME="t3rn"
VERSION=47
T3RN_DIR="$HOME/t3rn"
LOGFILE="$T3RN_DIR/executor.log"
NODE_PM2_NAME="executor"

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Draw menu borders and telegram icon
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
}
draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════╣${RESET}"
}
draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
}
print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Follow us on Telegram!${RESET}"
}
display_ascii() {
    echo -e "${RED}    ____  _       _    _ _           _       _           ${RESET}"    
    echo -e "${GREEN}   / ___|| | __ _| | _(_) |__   __ _| | __ _| |_ ___     ${RESET}" 
    echo -e "${BLUE}   \\___ \\| |/ _\` | |/ / | '_ \\ / _\` | |/ _\` | __/ _ \\    ${RESET}"
    echo -e "${YELLOW}    ___) | | (_| |   <| | | | | (_| | | (_| | ||  __/    ${RESET}"
    echo -e "${MAGENTA}   |____/|_|\\__,_|_|\\_\\_|_| |_|\\__,_|_|\\__,_|\\__\\___|    ${RESET}"
    echo -e "${CYAN}                                                     ${RESET}"       
}

# Display main menu
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Subscribe to our channel: ${YELLOW}https://t.me/molfo9iya${RESET}"
    draw_middle_border
    echo -e "                ${GREEN}Node Manager for ${PROJECT_NAME}${RESET}"
    echo -e "    ${YELLOW}Please choose an option:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL}  Install Node"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} View Logs"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Restart Node"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP}  Stop Node"
    echo -e "    ${CYAN}5.${RESET} ${ICON_START}  Start Node"
    echo -e "    ${CYAN}6.${RESET} ${ICON_REMOVE}   Remove Node"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Exit"
    draw_bottom_border
    echo -ne "${YELLOW}Enter a command number [0-7]:${RESET} "
    read choice
}

# Install node function with registration link and check
install_node() {
    echo -e "${CYAN}To proceed, ensure you have at least ${RED}0.1 BRN ${CYAN}in your wallet.${RESET}"
    echo -e "${CYAN}Claim free BRN from the faucet here: https://faucet.brn.t3rn.io/${RESET}"
    echo -ne "${YELLOW}Do you have sufficient BRN balance in your wallet? (y/n): ${RESET}"
    read registered

    if [[ "$registered" != "y" && "$registered" != "Y" ]]; then
        echo -e "${RED}You need at least 0.1 BRN to continue. Please claim some from the faucet.${RESET}"
        read -p "Press Enter to return to the menu..."
        return
    fi

    echo -e "${GREEN}🛠️  Installing node...${RESET}"

    # Update packages (brew equivalent of apt update)
    if ! command_exists brew; then
        echo -e "${CYAN}⚙️  Homebrew is not installed. Installing Homebrew...${RESET}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}⚙️  Homebrew is already installed.${RESET}"
    fi

    brew update

    # Create t3rn Folder
    if [ ! -d "$T3RN_DIR" ]; then
        mkdir -p "$T3RN_DIR"
        cd "$T3RN_DIR"
        echo -e "${CYAN}🗂️  Folder $T3RN_DIR created.${RESET}"
    else
        echo -e "${RED}🗂️  Folder $T3RN_DIR already exists.${RESET}"
    fi

    # Check & Install pm2
    if ! command_exists pm2; then
        echo -e "${CYAN}⚙️  pm2 is not installed. Installing pm2...${RESET}"
        npm install -g pm2
    else
        echo -e "${GREEN}⚙️  pm2 is already installed.${RESET}"
        pm2 stop $NODE_PM2_NAME
        pm2 delete $NODE_PM2_NAME
    fi

    # Download and extract the executor
    echo -e "${CYAN}⬇️  Downloading executor-macosx-v0.$VERSION.0.tar.gz${RESET}"
    curl -L -O "https://github.com/t3rn/executor-release/releases/download/v0.$VERSION.0/executor-macosx-v0.$VERSION.0.tar.gz"

    echo -e "${YELLOW}🧰 Extracting the file...${RESET}"
    tar -xvzf "executor-macosx-v0.$VERSION.0.tar.gz"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅  Extraction successful.${RESET}"
    else
        echo -e "${RED}❌  Extraction failed. Check the tar.gz file.${RESET}"
        exit 1
    fi

    # Configure environment variables
    echo -ne "${RED}🔑  Enter your EVM private key  [Burner Wallet]:${RESET} "
    read -s PRIVATE_KEY_LOCAL
    echo -e "\n${GREEN}✅ Private key has been set.${RESET}"
    echo

    export NODE_ENV=testnet
    export LOG_LEVEL=debug
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn'
    export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL

    # Start executor with pm2
    pm2 start ./executor/executor/bin/executor --name $NODE_PM2_NAME --log "$LOGFILE"

    echo -e "${GREEN}✅ Node installed successfully.${RESET}"
    read -p "Press Enter to return to the menu..."
}


# View logs function
view_logs() {
    echo -e "${GREEN}📄 Viewing logs...${RESET}"
    tail -n 50 "$LOGFILE"
    echo
    read -p "Press Enter to return to the menu..."
}

# Restart node function
restart_node() {
    echo -e "${GREEN}🔄 Restarting node...${RESET}"
    pm2 restart "$NODE_PM2_NAME"
    echo -e "${GREEN}✅ Node restarted.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Stop node function
stop_node() {
    echo -e "${GREEN}⏹️ Stopping node...${RESET}"
    pm2 stop "$NODE_PM2_NAME"
    echo -e "${GREEN}✅ Node stopped.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Start node function
start_node() {
    echo -e "${GREEN}▶️ Starting node...${RESET}"
    pm2 start "$NODE_PM2_NAME"
    echo -e "${GREEN}✅ Node started.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Remove node function
remove_node() {
    echo -e "${GREEN}🗑️ Removing node...${RESET}"
    pm2 delete "$NODE_PM2_NAME"
    echo -e "${GREEN}✅ Node removed.${RESET}"
    read -p "Press Enter to return to the menu..."
}

# Main menu loop
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            view_logs
            ;;
        3)
            restart_node
            ;;
        4)
            stop_node
            ;;
        5)
            start_node
            ;;
        6)
            remove_node
            ;;
        0)
            echo -e "${GREEN}❌ Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid input. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done

