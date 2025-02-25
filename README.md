```markdown
# VPS Security Hardening Script 🔒

**`Condom.sh`** – A "protection-first" script to secure your Linux VPS against common vulnerabilities.  
*Because even servers deserve safe computing!*

---

## 📖 Table of Contents
- [Features](#-features)
- [Installation](#-installation)
- [Customization](#-customization)
- [Usage](#-usage)
- [Contributing](#-contributing)
- [Disclaimer](#-disclaimer)
- [License](#-license)

---

## 🛠️ Features
- **User Management**: Create a secure sudo user with SSH key authentication.
- **SSH Hardening**: Disable root login, enforce key-based authentication, and customize SSH port.
- **Firewall Setup**: Configure UFW with sensible defaults (SSH, HTTP/S, Docker ports).
- **Docker Installation**: Install Docker and Docker Compose with optimized repository mirrors.
- **System Hardening**:
  - Automatic security updates
  - Kernel parameter tuning
  - DNS configuration (Google DNS)
- **Region-Specific Fixes**: Optimized for restricted networks (e.g., Iran) with:
  - Automatic best mirror selection
  - DNS override capabilities
  - Installation retry logic

---

## 📥 Installation
```bash
# Download the script
wget https://raw.githubusercontent.com/yourusername/repo/main/Condom.sh

# Make executable
chmod +x Condom.sh

# Run as root
sudo ./Condom.sh
```

---

## ⚙️ Customization
Configure settings via environment variables (edit script header):
```bash
### -- CONFIGURATION -- ###
USERNAME="sysadmin"       # New sudo user
SSH_PORT="2222"           # Custom SSH port
TIMEZONE="Asia/Tehran"    # Server timezone
DNS_SERVERS="8.8.8.8 8.8.4.4" # DNS override
TOOLS_INSTALL=1           # 1=Install tools, 0=Skip
```

---

## 🚀 Usage
1. **Interactive Setup**:
   ```bash
   sudo ./Condom.sh
   ```
   Follow prompts for user creation and SSH configuration.

2. **Automated Setup** (pre-configured variables):
   ```bash
   sudo USERNAME=admin SSH_PORT=2222 ./Condom.sh
   ```

3. **Post-Installation**:
   - SSH Access: `ssh -p <PORT> <USERNAME>@<SERVER_IP>`
   - Check open ports: `ss -tulnp`
   - Verify Docker: `docker run hello-world`

---

## 🔧 Technical Details
```text
Files Modified:
- /etc/ssh/sshd_config
- /etc/ufw/
- /etc/sysctl.conf
- /etc/resolv.conf (DNS)

Packages Installed:
- ufw, fail2ban, unattended-upgrades
- docker-ce, docker-compose-plugin
- htop, net-tools, curl
```

---

## 🤝 Contributing
**Improvements welcome!**  
1. Fork the repository
2. Create a feature branch: `git checkout -b improve-condom`
3. Commit changes: `git commit -m 'Add security feature X'`
4. Push to branch: `git push origin improve-condom`
5. Open a pull request

---

## ⚠️ Disclaimer
This script:
- Modifies critical system configurations
- Disables root SSH access
- Changes firewall rules

**Always:**
- Test in a non-production environment first
- Backup existing SSH keys
- Monitor server after deployment

---

## 📜 License
MIT License © 2024 [Matin3ai]  
`Condom.sh` is licensed under the MIT License. Use at your own risk.
