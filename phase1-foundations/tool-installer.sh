```bash
#!/usr/bin/env bash
# =============================================================================
#  Automated Cybersecurity Toolbox Installer
#  Targets: Debian / Ubuntu / Kali
#  Version: Professional Edition
# =============================================================================

set -Eeuo pipefail

# =============================================================================
# GLOBALS
# =============================================================================

LOGFILE="/var/log/cybertoolbox-install.log"
INSTALL_DIR="/opt/cybertoolbox"
TOOLS_DIR="${INSTALL_DIR}/tools"
WORDLIST_DIR="${INSTALL_DIR}/wordlists"

export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# LOGGING
# =============================================================================

mkdir -p "$(dirname "$LOGFILE")"
touch "$LOGFILE"

exec > >(tee -a "$LOGFILE") 2>&1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
err()   { echo -e "${RED}[-]${NC} $*"; }

trap 'err "Installation failed at line $LINENO."' ERR

# =============================================================================
# ROOT CHECK
# =============================================================================

if [[ $EUID -ne 0 ]]; then
    err "Run this script as root or with sudo."
    exit 1
fi

# =============================================================================
# OS CHECK
# =============================================================================

if ! grep -qiE 'debian|ubuntu|kali' /etc/os-release; then
    warn "Unsupported OS detected. Continuing anyway..."
fi

ARCH=$(dpkg --print-architecture)
info "Detected architecture: $ARCH"

# =============================================================================
# FLAGS
# =============================================================================

INSTALL_MODE="full"

for arg in "$@"; do
    case "$arg" in
        --minimal)
            INSTALL_MODE="minimal"
            ;;
        --full)
            INSTALL_MODE="full"
            ;;
        --recon-only)
            INSTALL_MODE="recon"
            ;;
        --web-only)
            INSTALL_MODE="web"
            ;;
    esac
done

info "Installation mode: $INSTALL_MODE"

# =============================================================================
# DIRECTORIES
# =============================================================================

mkdir -p \
    "$TOOLS_DIR" \
    "$WORDLIST_DIR"

mkdir -p ~/{
    tools,
    labs,
    loot,
    reports,
    screenshots,
    notes,
    targets
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

install_apt_tool() {
    local pkg="$1"

    if dpkg -s "$pkg" &>/dev/null; then
        info "$pkg already installed."
        return
    fi

    info "Installing apt package: $pkg"

    if apt install -y "$pkg"; then
        info "$pkg installed successfully."
    else
        warn "Failed to install $pkg"
    fi
}

verify_tool() {
    local tool="$1"

    if command -v "$tool" &>/dev/null; then
        info "$tool verified."
    else
        warn "$tool not found in PATH."
    fi
}

append_if_missing() {
    local line="$1"
    local file="$2"

    grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

checkpoint() {
    touch "/tmp/$1.done"
}

is_done() {
    [[ -f "/tmp/$1.done" ]]
}

# =============================================================================
# SYSTEM UPDATE
# =============================================================================

if ! is_done "system_update"; then
    info "Updating system..."

    apt update -y
    apt upgrade -y

    checkpoint "system_update"
fi

# =============================================================================
# BASE DEPENDENCIES
# =============================================================================

BASE_PACKAGES=(
    curl
    wget
    git
    unzip
    zip
    tar
    jq
    vim
    nano
    tmux
    zsh
    build-essential
    software-properties-common
    apt-transport-https
    ca-certificates
    gnupg
    lsb-release
    net-tools
    dnsutils
    whois
    python3
    python3-pip
    python3-venv
    python3-dev
    ruby
    ruby-dev
    docker.io
    docker-compose
)

if ! is_done "base_packages"; then
    info "Installing base packages..."

    for pkg in "${BASE_PACKAGES[@]}"; do
        install_apt_tool "$pkg"
    done

    checkpoint "base_packages"
fi

# =============================================================================
# DOCKER SETUP
# =============================================================================

if ! is_done "docker"; then
    info "Configuring Docker..."

    systemctl enable docker --now

    if [[ -n "${SUDO_USER:-}" ]]; then
        usermod -aG docker "$SUDO_USER"
    fi

    checkpoint "docker"
fi

# =============================================================================
# GO INSTALLATION
# =============================================================================

if ! command -v go &>/dev/null; then
    info "Installing Go..."

    GO_VERSION="1.22.4"

    wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" \
        -O /tmp/go.tar.gz

    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go.tar.gz
    rm -f /tmp/go.tar.gz
fi

export PATH=$PATH:/usr/local/go/bin
export GOPATH="${HOME}/go"
export PATH="$PATH:$GOPATH/bin"

mkdir -p "$GOPATH/bin"

append_if_missing 'export PATH=$PATH:/usr/local/go/bin' /etc/profile.d/go.sh
append_if_missing 'export PATH=$PATH:$HOME/go/bin' /etc/profile.d/go.sh

append_if_missing 'export PATH=$PATH:$HOME/go/bin' "${HOME}/.bashrc"
append_if_missing 'export PATH=$PATH:$HOME/go/bin' "${HOME}/.zshrc"

# =============================================================================
# CORE APT TOOLS
# =============================================================================

CORE_TOOLS=(
    nmap
    sqlmap
    wireshark
    hashcat
    john
    gobuster
    masscan
    feroxbuster
    responder
    enum4linux
    smbclient
    bettercap
    exploitdb
    adb
    whatweb
    wpscan
    aircrack-ng
)

if ! is_done "core_tools"; then
    info "Installing core security tools..."

    for pkg in "${CORE_TOOLS[@]}"; do
        install_apt_tool "$pkg"
    done

    checkpoint "core_tools"
fi

# =============================================================================
# GO-BASED TOOLS
# =============================================================================

install_go_tool() {
    local pkg="$1"

    info "Installing Go tool: $pkg"

    if go install -v "$pkg"; then
        info "Installed: $pkg"
    else
        warn "Failed: $pkg"
    fi
}

if ! is_done "go_tools"; then
    install_go_tool github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    install_go_tool github.com/projectdiscovery/httpx/cmd/httpx@latest
    install_go_tool github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    install_go_tool github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
    install_go_tool github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    install_go_tool github.com/projectdiscovery/katana/cmd/katana@latest
    install_go_tool github.com/projectdiscovery/uncover/cmd/uncover@latest

    install_go_tool github.com/ffuf/ffuf/v2@latest
    install_go_tool github.com/OJ/gobuster/v3@latest
    install_go_tool github.com/lc/gau/v2/cmd/gau@latest
    install_go_tool github.com/tomnomnom/waybackurls@latest
    install_go_tool github.com/tomnomnom/gf@latest
    install_go_tool github.com/tomnomnom/qsreplace@latest
    install_go_tool github.com/tomnomnom/assetfinder@latest

    install_go_tool github.com/projectdiscovery/chaos-client/cmd/chaos@latest
    install_go_tool github.com/hahwul/dalfox/v2@latest
    install_go_tool github.com/jpillora/chisel@latest
    install_go_tool github.com/ropnop/kerbrute@latest

    checkpoint "go_tools"
fi

# =============================================================================
# PYTHON VENV
# =============================================================================

PYTHON_ENV="/opt/pentest-venv"

if ! is_done "python_env"; then
    info "Creating Python virtual environment..."

    python3 -m venv "$PYTHON_ENV"

    source "$PYTHON_ENV/bin/activate"

    pip install --upgrade pip setuptools wheel

    pip install \
        impacket \
        frida-tools \
        dirsearch \
        wfuzz \
        theHarvester \
        recon-ng \
        mitm6 \
        pycryptodome \
        bloodhound \
        mitmproxy

    deactivate

    checkpoint "python_env"
fi

# =============================================================================
# RUBY TOOLS
# =============================================================================

if ! is_done "ruby_tools"; then
    info "Installing Ruby gems..."

    gem install evil-winrm
    gem install wpscan --no-document

    checkpoint "ruby_tools"
fi

# =============================================================================
# METASPLOIT
# =============================================================================

if ! command -v msfconsole &>/dev/null; then
    info "Installing Metasploit..."

    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
        > /tmp/msfinstall

    chmod +x /tmp/msfinstall
    /tmp/msfinstall

    rm -f /tmp/msfinstall
fi

# =============================================================================
# BURP SUITE
# =============================================================================

if ! command -v burpsuite &>/dev/null; then
    info "Installing Burp Suite Community..."

    apt install -y snapd || true
    systemctl enable --now snapd || true
    snap install burpsuite-community || true
fi

# =============================================================================
# MOBILE SECURITY
# =============================================================================

if ! is_done "mobile"; then
    info "Setting up mobile security tools..."

    docker pull opensecurity/mobile-security-framework-mobsf:latest

    pip install objection || true

    checkpoint "mobile"
fi

# =============================================================================
# WORDLISTS
# =============================================================================

if ! is_done "wordlists"; then
    info "Downloading wordlists..."

    git clone --depth 1 \
        https://github.com/danielmiessler/SecLists.git \
        "${WORDLIST_DIR}/SecLists" || true

    git clone --depth 1 \
        https://github.com/swisskyrepo/PayloadsAllTheThings.git \
        "${WORDLIST_DIR}/PayloadsAllTheThings" || true

    git clone --depth 1 \
        https://github.com/fuzzdb-project/fuzzdb.git \
        "${WORDLIST_DIR}/fuzzdb" || true

    checkpoint "wordlists"
fi

# =============================================================================
# EYEWITNESS
# =============================================================================

if [[ ! -d "/opt/EyeWitness" ]]; then
    info "Installing EyeWitness..."

    git clone https://github.com/RedSiege/EyeWitness.git /opt/EyeWitness

    pushd /opt/EyeWitness/Python

    pip install -r requirements.txt || true

    popd
fi

# =============================================================================
# TESTSSL
# =============================================================================

if ! command -v testssl &>/dev/null; then
    info "Installing testssl.sh..."

    git clone --depth 1 \
        https://github.com/drwetter/testssl.sh.git \
        /opt/testssl.sh

    ln -sf /opt/testssl.sh/testssl.sh /usr/local/bin/testssl
fi

# =============================================================================
# RUSTSCAN
# =============================================================================

if ! command -v rustscan &>/dev/null; then
    info "Installing RustScan..."

    case "$ARCH" in
        amd64)
            RUSTSCAN_FILE="rustscan_2.2.3_amd64.deb"
            ;;
        arm64)
            RUSTSCAN_FILE="rustscan_2.2.3_arm64.deb"
            ;;
        *)
            warn "Unsupported architecture for RustScan."
            RUSTSCAN_FILE=""
            ;;
    esac

    if [[ -n "$RUSTSCAN_FILE" ]]; then
        wget \
            "https://github.com/RustScan/RustScan/releases/download/2.2.3/${RUSTSCAN_FILE}" \
            -O /tmp/rustscan.deb

        dpkg -i /tmp/rustscan.deb || apt install -f -y

        rm -f /tmp/rustscan.deb
    fi
fi

# =============================================================================
# NUCLEI TEMPLATES
# =============================================================================

if command -v nuclei &>/dev/null; then
    info "Updating Nuclei templates..."

    nuclei -update-templates || true
fi

# =============================================================================
# WIRESHARK
# =============================================================================

if [[ -n "${SUDO_USER:-}" ]]; then
    usermod -aG wireshark "$SUDO_USER" || true
fi

# =============================================================================
# CLEANUP
# =============================================================================

info "Running cleanup..."

apt autoremove -y
apt autoclean -y

# =============================================================================
# VERIFICATION
# =============================================================================

info "Verifying installed tools..."

VERIFY_TOOLS=(
    nmap
    ffuf
    subfinder
    amass
    httpx
    nuclei
    sqlmap
    msfconsole
    wireshark
    hashcat
    john
    gobuster
    feroxbuster
    responder
    rustscan
)

for tool in "${VERIFY_TOOLS[@]}"; do
    verify_tool "$tool"
done

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN}      CYBERSECURITY TOOLBOX INSTALL COMPLETE         ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo ""

echo "Installed categories:"
echo "  - Recon & Enumeration"
echo "  - Web Application Pentesting"
echo "  - Active Directory"
echo "  - Mobile Pentesting"
echo "  - Wireless Security"
echo "  - Docker Security"
echo "  - Password Attacks"
echo "  - Vulnerability Scanning"
echo "  - OSINT & Automation"
echo ""

echo "Workspace:"
echo "  ~/tools"
echo "  ~/labs"
echo "  ~/loot"
echo "  ~/reports"
echo "  ~/targets"
echo ""

echo "Logs:"
echo "  $LOGFILE"
echo ""

echo "Useful commands:"
echo "  source ${PYTHON_ENV}/bin/activate"
echo "  docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest"
echo ""

echo "Relogin recommended for:"
echo "  - Docker group changes"
echo "  - Wireshark permissions"
echo "  - PATH updates"
echo ""

info "Installation finished successfully."
```
