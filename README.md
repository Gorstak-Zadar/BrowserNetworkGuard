# 🛡️ BrowserNetworkGuard

> PowerShell **local proxy** that blocks all network connections except user-entered URLs and their dependencies — protecting against telemetry and unauthorized phone-homes.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔒 **Whitelist Model** | Only URLs the user types + their dependencies are allowed |
| 📦 **Proxy** | Local HTTP/HTTPS proxy (default port 8888) |
| 🎮 **Game Launchers** | Pre-whitelisted: Steam, Epic, Battle.net, EA, Ubisoft, GOG, Xbox, Riot |
| 📋 **Logging** | Logs blocked requests to `blocked_requests.log` |
| 🚫 **Telemetry Blocking** | Blocks surveillance DLLs and unauthorized servers |

---

## 📋 Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 10/11 |
| **PowerShell** | 5.1+ |
| **Privileges** | Administrator |

---

## 🚀 Usage

```powershell
# Default (port 8888)
.\BrowserNetworkGuard.ps1

# Custom port and interval
.\BrowserNetworkGuard.ps1 -ProxyPort 9999 -CheckInterval 2
```

---

## ⚙️ Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-ProxyPort` | 8888 | Local proxy listen port |
| `-CheckInterval` | 1 | Check interval in seconds |
| `-WhitelistDB` | `whitelist.json` | Whitelist database path |
| `-LogFile` | `blocked_requests.log` | Blocked request log path |

---

## 🔧 Configuration

Configure your browser to use `127.0.0.1:8888` (or your port) as the HTTP/HTTPS proxy.

---

<p align="center">
  <sub>🛡️ Gorstak Security Tooling</sub>
</p>
