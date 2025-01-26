# Before you start you need to do this :

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Verify Homebrew installation
brew --version

# Install required tools
brew install curl screen unzip git node jq aria2 htop

# Verify tools installation
curl --version
screen --version
unzip --version
git --version
node --version
npm --version
jq --version
aria2c --version
htop --version
