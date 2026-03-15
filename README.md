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

---

## Disclaimer

**NO WARRANTY.** THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

**Limitation of Liability.** IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
