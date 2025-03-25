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