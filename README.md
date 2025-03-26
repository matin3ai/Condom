# VPS Security Hardening Script 🔒

**`Condom.sh`** – A "protection-first" script designed to secure your Linux VPS against common threats. Because even servers deserve safe computing!

---

## 📖 Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#Usage)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## 🛠️ Features
### ✅ **Security & Hardening**
- **User Management:** Creates a secure sudo user with SSH key authentication.
- **SSH Hardening:** Disables root login, enforces key-based authentication, and customizes the SSH port.
- **Firewall Protection:** Configures UFW with strict defaults (allows SSH, HTTP, HTTPS, and Docker ports).
- **System Hardening:**
  - Enables automatic security updates.
  - Implements kernel-level security optimizations.
  - Configures secure DNS (Google DNS by default).
- **Docker Installation:** Installs Docker and Docker Compose with optimized repository mirrors.
- **Region-Specific Enhancements:**
  - Automatically selects the best package mirror based on network conditions.
  - Overrides restrictive DNS settings to improve accessibility.
  - Implements retry logic for failed installations.

---

## ⚓️ Installation

To install and run `Condom.sh`, follow these simple steps:

```bash
# Download the script
wget https://raw.githubusercontent.com/matin3ai/Condom/main/Condom.sh

# Make it executable
chmod +x Condom.sh

# Run as root
sudo ./Condom.sh
```

---

## ⚙️ Configuration

`Condom.sh` allows basic customization through user input. When executed, the script prompts for:
- **New sudo username**
- **SSH port selection** (default: 22)
- **Time zone configuration**

For advanced configurations, you can modify the script variables before execution.

---

## 🔄 Usage

Simply run the script as root:

```bash
sudo ./Condom.sh
```

Once completed, the script:
- Creates a new secure sudo user.
- Hardens SSH and firewall rules.
- Installs essential security tools.
- Sets up Docker and system optimizations.

Your VPS will be secured and optimized for performance!

---

## ✨ Contributing
Contributions are welcome! Feel free to fork the repository, create a new branch, and submit a pull request with your improvements.

---

## ⚠️ Disclaimer
This script is provided "as is" without warranty of any kind. Use at your own risk. Always review the script before execution on a production server.

---

## ⚖️ License
`Condom.sh` is released under the **MIT License**. See the `LICENSE` file for details.

