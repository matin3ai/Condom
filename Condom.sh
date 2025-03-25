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

# Prompt for system timezone (Default: UTC)
read -p "Enter your timezone (e.g., UTC, Asia/Tehran): " TIMEZONE
TIMEZONE=${TIMEZONE:-UTC}

# Function to update DNS settings
change_dns() {
    echo "🌐 Changing DNS servers to Google DNS (8.8.8.8 and 8.8.4.4)..."
    cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
    echo "✅ DNS servers updated."
}

# Function to find and set the best Ubuntu repository mirror
find_best_mirror() {
    echo "🔍 Finding the best repository mirror based on ping..."
    MIRROR=$(curl -s http://mirrors.ubuntu.com/mirrors.txt | xargs -I{} sh -c 'echo `curl -r 0-102400 -s -w %{speed_download} -o /dev/null {}/ls-lR.gz` {}' | sort -g -r | head -1 | awk '{print $2}')
    
    if [[ -z "$MIRROR" ]]; then
        echo "❌ Failed to find a suitable mirror. Using default."
        MIRROR="http://archive.ubuntu.com/ubuntu"
    else
        echo "✅ Best mirror found: $MIRROR"
    fi

    # Update sources.list with the best mirror
    sed -i "s|http://.*.ubuntu.com/ubuntu|$MIRROR|g" /etc/apt/sources.list
    apt update
}

# Function to install Docker
install_docker() {
    echo "🐳 Installing Docker..."
    
    # Remove any old Docker versions
    apt remove -y docker docker-engine docker.io containerd runc
    
    # Install required dependencies
    apt install -y ca-certificates curl gnupg
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # Set up Docker repository and install Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update && apt install -y docker.io docker-ce docker docker-ce-cli containerd.io docker-compose-plugin
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Failed to install Docker. Retrying..."
        apt update && apt install -y docker-ce docker-ce-cli containerd.io docker docker-compose-plugin
    fi
    
    echo "✅ Docker installed successfully."
}

# Function to install essential security tools
install_tools() {
    echo "🛠️ Installing additional tools..."
    TOOLS=("ufw" "fail2ban" "unattended-upgrades" "curl" "git" "htop" "net-tools")
    
    for tool in "${TOOLS[@]}"; do
        echo "Installing $tool..."
        apt install -y "$tool"
        
        if [[ $? -ne 0 ]]; then
            echo "❌ Failed to install $tool. Skipping..."
        fi
    done
    
    echo "✅ Additional tools installed."
}

# Apply DNS and mirror updates
change_dns
find_best_mirror

# Update system and install security packages
echo "🔄 Updating system and installing security packages..."
apt update && apt upgrade -y

if [[ $? -ne 0 ]]; then
    echo "❌ Failed to update system packages. Retrying..."
    apt update && apt upgrade -y
fi

install_tools

# Set system timezone
echo "⏳ Setting timezone to $TIMEZONE..."
timedatectl set-timezone "$TIMEZONE"

# Create a new secure sudo user
if id "$USERNAME" &>/dev/null; then
    echo "✅ User '$USERNAME' already exists."
else
    echo "👤 Creating new sudo user: $USERNAME..."
    adduser --gecos "" "$USERNAME"
    usermod -aG sudo "$USERNAME"
    
    # Secure SSH key-based authentication
    echo "🔑 Copying SSH keys for secure login..."
    mkdir -p /home/$USERNAME/.ssh
    cp ~/.ssh/authorized_keys /home/$USERNAME/.ssh/
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
fi

# Secure SSH configuration
echo "🔐 Securing SSH..."
sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl restart sshd

# Configure UFW Firewall
echo "🛡️ Configuring UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

install_docker

# Add user to the Docker group for Docker access
echo "⚙️ Adding $USERNAME to Docker group..."
usermod -aG docker "$USERNAME"
systemctl enable docker && systemctl start docker

# Display open ports for security review
echo "🔍 Checking open ports..."
ss -tulnp | grep LISTEN

# Enable automatic security updates
echo "📦 Enabling automatic security updates..."
dpkg-reconfigure -plow unattended-upgrades

# Apply system hardening settings
echo "🛠️ Applying system hardening..."
cat <<EOF >> /etc/sysctl.conf
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
sysctl -p

# Final message and reboot
echo "✅ VPS setup complete!"
echo "🚀 You can now log in as $USERNAME using SSH on port $SSH_PORT."
echo "🔍 Check your open ports carefully and disable any unnecessary ones."
echo "🔄 Rebooting in 10 seconds. GOOD LUCK! (MATIN3AI)"
sleep 10
reboot