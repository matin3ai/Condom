#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "WELCOME! ❌ This script must be run as root. Use 'sudo' or log in as root and try again."
    exit 1
fi

echo "🔒 Starting VPS Security Hardening & Setup..."
sleep 2

# Prompt the user for a new sudo username
read -p "Enter the new sudo username: " USERNAME
while [[ -z "$USERNAME" ]]; do
    echo "❌ Username cannot be empty. Please enter a valid username."
    read -p "Enter the new sudo username: " USERNAME
done

# Prompt for SSH Port (Default: 22)
read -p "Enter SSH Port (default 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}  # Set default to 22 if empty

# Function to update DNS settings (Cloudflare DNS)
change_dns() {
    echo "🌐 Changing DNS servers to Cloudflare DNS (1.1.1.1 and 1.0.0.1)..."
    cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
    echo "✅ DNS servers updated."
}

# Disable IPv6
disable_ipv6() {
    echo "🚫 Disabling IPv6..."
    cat <<EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    sysctl -p
    echo "✅ IPv6 disabled."
}

# Install Docker
install_docker() {
    echo "🐳 Installing Docker..."
    apt remove -y docker docker-engine docker.io containerd runc
    apt install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
    chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "✅ Docker installed successfully."
}

# Install basic tools
install_tools() {
    echo "🛠️ Installing essential tools..."
    apt install -y ufw fail2ban unattended-upgrades curl git htop net-tools
    echo "✅ Tools installed."
}

# Apply DNS and system update
change_dns
disable_ipv6
apt update && apt upgrade -y

install_tools

# Create sudo user
if id "$USERNAME" &>/dev/null; then
    echo "✅ User '$USERNAME' already exists."
else
    echo "👤 Creating new sudo user: $USERNAME..."
    adduser --gecos "" "$USERNAME"
    usermod -aG sudo "$USERNAME"
fi

# SSH hardening (allow password login, custom port, disable root login)
echo "🔐 Configuring SSH..."
sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
systemctl restart sshd

# UFW firewall
echo "🛡️ Configuring UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp
ufw allow 2375/tcp       # Docker (non-TLS, optional - remove if not needed)
ufw allow 2376/tcp       # Docker (TLS)
ufw allow 80/tcp         # HTTP
ufw allow 443/tcp        # HTTPS
ufw --force enable

# Install Docker and add user to docker group
install_docker
usermod -aG docker "$USERNAME"
systemctl enable docker && systemctl start docker

# Enable automatic security updates
echo "📦 Enabling unattended upgrades..."
dpkg-reconfigure -plow unattended-upgrades

# System hardening
echo "🛠️ Applying sysctl security settings..."
cat <<EOF >> /etc/sysctl.conf
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
sysctl -p

# Show open ports
echo "🔍 Current open ports:"
ss -tulnp | grep LISTEN

# Done
echo "✅ VPS setup complete!"
echo "🚀 You can now log in as $USERNAME via SSH on port $SSH_PORT."
echo "🔒 Remember to monitor your VPS and keep it updated regularly."
echo "🔄 Rebooting in 10 seconds..."
sleep 10
reboot