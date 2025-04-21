#!/bin/bash

# Install all required tools for subdomain enumeration and recon
echo "[+] Installing required tools..."

sudo apt update && sudo apt install -y curl git jq build-essential dnsutils

# Install Golang if not already installed
if ! command -v go &> /dev/null; then
  echo "[*] Installing Golang..."
  wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  export PATH=$PATH:/usr/local/go/bin
  source ~/.bashrc
fi

# Ensure Go binary path is set
mkdir -p ~/go/bin
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc

# Install recon tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/tomnomnom/httprobe@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
go install -v github.com/ffuf/ffuf@latest

echo "[+] All tools installed successfully! Open a new terminal or source your ~/.bashrc."
