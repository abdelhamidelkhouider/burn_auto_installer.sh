#!/bin/bash

# Définition des couleurs et des icônes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_RESTART="🔄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_EXIT="❌"
ICON_REMOVE="🗑️"
ICON_VIEW="👀"
ICON_DOLLAR="💳"
ICON_UPDATE="⛽️"

# Variables globales
PROJECT_NAME="t3rn"
VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep 'tag_name' | cut -d\" -f4 | grep -oP '(?<=v0\.)\d+')

T3RN_DIR="$HOME/t3rn"
ENV_FILE="$T3RN_DIR/.env"
LOGFILE="$T3RN_DIR/executor.log"
NODE_PM2_NAME="executor"

# Fonctions pour afficher les bordures du menu
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
}
draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════╣${RESET}"
}
draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
}
display_ascii() {
    echo -e "${RED}    __  __       _       __        _______  _       _      _            ${RESET}"    
    echo -e "${GREEN}   |  \\/  |     (_)      \\ \\      / /  __ \\| |     (_)    (_)           ${RESET}" 
    echo -e "${BLUE}   | \\  / | ___  _ ______ \\ \\ /\\ / /| |  | | | ___  _ _ __ _ _ __   __ _ ${RESET}"
    echo -e "${YELLOW}   | |\\/| |/ _ \\| |______| \\ /  \\ / | |  | | |/ _ \\| | '__| | '_ \\ / _\` |${RESET}"
    echo -e "${MAGENTA}   | |  | | (_) | |       | |\\_/|  | |__| | |  __/| | |  | | | | | (_| | ${RESET}"
    echo -e "${CYAN}   |_|  |_|\\___/|_|       |_|   |_| \\____/|_|\\___|_|_|  |_|_| |_|\\__,_| ${RESET}"       
    echo -e "${CYAN}                          M O L F O 9 I Y A                             ${RESET}"
}

# Fonction d'installation
install_node() {
    echo -e "${CYAN}🛠️  Installation du nœud en cours...${RESET}"
    
    # Mise à jour des outils nécessaires
    if ! command -v brew &>/dev/null; then
        echo -e "${RED}Homebrew n'est pas installé. Installez-le d'abord : https://brew.sh/${RESET}"
        exit 1
    fi

    brew update
    
    # Création du dossier t3rn
    if [ ! -d "$T3RN_DIR" ]; then
        mkdir -p "$T3RN_DIR"
        echo -e "${CYAN}📂 Dossier $T3RN_DIR créé.${RESET}"
    else
        echo -e "${RED}📂 Le dossier $T3RN_DIR existe déjà.${RESET}"
        rm -rf "$T3RN_DIR/executor"
        rm -rf "$T3RN_DIR/executor-macosx-v0.$VERSION.0.tar.gz"
    fi
    cd "$T3RN_DIR"

    # Installation des dépendances avec npm
    if ! command -v npm &>/dev/null; then
        echo -e "${RED}Node.js et npm ne sont pas installés. Installation en cours...${RESET}"
        brew install node
    fi

    npm install -g ethers dotenv pm2

    # Téléchargement et extraction
    echo -e "${CYAN}⬇️  Téléchargement de l'exécuteur...${RESET}"
    curl -L -O "https://github.com/t3rn/executor-release/releases/download/v0.$VERSION.0/executor-macosx-v0.$VERSION.0.tar.gz"

    echo -e "${YELLOW}🧰 Extraction du fichier...${RESET}"
    tar -xvzf "executor-macosx-v0.$VERSION.0.tar.gz"

    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Échec de l'extraction.${RESET}"
        exit 1
    fi

    # Vérification ou création du fichier .env
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}❌ Fichier .env non trouvé. Création en cours...${RESET}"
        echo -ne "${YELLOW}🔑 Entrez votre clé privée : ${RESET}"
        read -s PRIVATE_KEY_LOCAL
        echo "PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL" > "$ENV_FILE"
    fi
    source "$ENV_FILE"

    # Lancement du nœud avec pm2
    pm2 start ./executor/executor/bin/executor --name "$NODE_PM2_NAME" --log "$LOGFILE"
    echo -e "${GREEN}✅ Installation terminée.${RESET}"
}

# Affichage des logs
view_logs() {
    echo -e "${GREEN}📄 Affichage des logs...${RESET}"
    tail -n 50 "$LOGFILE"
}

# Menu principal
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    echo -e "    ${GREEN}Gestionnaire de nœuds pour ${PROJECT_NAME}${RESET}"
    echo -e "    ${YELLOW}Veuillez choisir une option :${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Installer le nœud"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} Afficher les logs"
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Quitter"
    draw_bottom_border
    echo -ne "${YELLOW}Entrez un numéro [0-2] :${RESET} "
    read choice
}

# Boucle du menu
while true; do
    show_menu
    case $choice in
        1) install_node ;;
        2) view_logs ;;
        0) echo -e "${CYAN}👋 Au revoir.${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Choix invalide.${RESET}" ;;
    esac
done


#!/bin/bash

# --- Colors ---
RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"

# --- Global Variables ---
NODE_PM2_NAME="your_node_process_name"
T3RN_DIR="/path/to/t3rn"
ENV_FILE="$T3RN_DIR/.env"

# --- Helper Functions ---
pause() {
    read -p "Press Enter to continue..."
}

success_message() {
    echo -e "${GREEN}✅ $1${RESET}"
}

error_message() {
    echo -e "${RED}❌ $1${RESET}"
}

# --- Node Control Functions ---
restart_node() {
    echo -e "${GREEN}🔄 Restarting node...${RESET}"
    pm2 restart $NODE_PM2_NAME && success_message "Node restarted." || error_message "Failed to restart node."
    pause
}

stop_node() {
    echo -e "${YELLOW}⏹️  Stopping node...${RESET}"
    pm2 stop $NODE_PM2_NAME && success_message "Node stopped." || error_message "Failed to stop node."
    pause
}

start_node() {
    echo -e "${GREEN}▶️ Starting node...${RESET}"
    pm2 start $NODE_PM2_NAME && success_message "Node started." || error_message "Failed to start node."
    pause
}

remove_node() {
    echo -e "${YELLOW}🗑️  Removing node...${RESET}"
    pm2 delete $NODE_PM2_NAME
    rm -rf "$T3RN_DIR/executor" "$T3RN_DIR/executor.log" "$T3RN_DIR/getBalance.js" "$T3RN_DIR/.env" $T3RN_DIR/*.tar.gz
    success_message "Node removed."
    pause
}

# --- Wallet Balance Function ---
check_wallet_balance() {
    echo -e "${BLUE}🔌  Checking wallet balance...${RESET}"
    cd "$T3RN_DIR" || { error_message "Directory not found!"; exit 1; }

    # Check and install dependencies
    for package in ethers dotenv; do
        if npm list "$package" >/dev/null 2>&1; then
            success_message "$package is already installed."
        else
            echo -e "${GREEN}Installing $package...${RESET}"
            npm install "$package" || { error_message "Failed to install $package"; exit 1; }
        fi
    done

    # Load environment variables
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    else
        error_message ".env file not found!"
        read -sp "Enter your private key: " PRIVATE_KEY_LOCAL
        echo "PRIVATE_KEY_LOCAL=${PRIVATE_KEY_LOCAL}" >> .env
    fi

    # Validate private key
    if [ -z "$PRIVATE_KEY_LOCAL" ]; then
        error_message "Private key not provided. Exiting..."
        exit 1
    fi

    # Generate getBalance.js if missing
    generate_getBalance_js_file

    # Check balance on networks
    for network in brn sepolia base_sepolia op_sepolia arbitrum_sepolia blast_sepolia; do
        echo -e "${BLUE}⏱️  Checking $network network...${RESET}"
        node getBalance.js "$network"
        echo
    done

    pause
}

generate_getBalance_js_file() {
    echo -e "${CYAN}📃 Generating getBalance.js file...${RESET}"
    cat > "$T3RN_DIR/getBalance.js" << 'EOF'
const { ethers } = require("ethers");
require("dotenv").config();

const NETWORKS = {
  sepolia: "https://ethereum-sepolia-rpc.publicnode.com",
  base_sepolia: "https://sepolia.base.org",
  op_sepolia: "https://optimism-sepolia-rpc.publicnode.com",
  arbitrum_sepolia: "https://arbitrum-sepolia-rpc.publicnode.com",
  blast_sepolia: "https://sepolia.blast.io",
  brn: "https://brn.rpc.caldera.xyz/http",
};

async function getEthBalance(pk, network) {
  const rpcUrl = NETWORKS[network.toLowerCase()];
  if (!rpcUrl) {
    console.error(`Invalid network: ${network}.`);
    return;
  }

  try {
    const wallet = new ethers.Wallet(pk);
    const provider = new ethers.JsonRpcProvider(rpcUrl);
    const balance = await provider.getBalance(wallet.address);
    console.log(`Balance on ${network.toUpperCase()}: ${ethers.formatEther(balance)} ETH`);
  } catch (error) {
    console.error("Error:", error);
  }
}

const privateKey = process.env.PRIVATE_KEY_LOCAL;
const net = process.argv[2] || "sepolia";
if (!privateKey) {
  console.error("PRIVATE_KEY_LOCAL is not set in the .env file");
  process.exit(1);
}

getEthBalance(privateKey, net);
EOF
    success_message "getBalance.js file generated."
}

# --- Menu ---
show_menu() {
    clear
    echo -e "${CYAN}Node Management Script${RESET}"
    echo "1) Restart Node"
    echo "2) Stop Node"
    echo "3) Start Node"
    echo "4) Remove Node"
    echo "5) Check Wallet Balance"
    echo "0) Exit"
    echo
    read -p "Enter your choice: " choice
}

# --- Main Loop ---
while true; do
    show_menu
    case $choice in
        1) restart_node ;;
        2) stop_node ;;
        3) start_node ;;
        4) remove_node ;;
        5) check_wallet_balance ;;
        0) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
        *) error_message "Invalid choice. Try again."; pause ;;
    esac
done

