<!-- description: Admin PowerShell: HttpListener proxy on localhost + foreground-window hook to grow a domain whitelist; blocks non-listed hosts (see HTTPS limits in README). -->

# 🛡️ BrowserNetworkGuard

> Runs **elevated**: starts an **`HttpListener`** HTTP proxy on **`localhost`** (default **8888**), maintains **`whitelist.json`**, and **monitors the active window title** (Chrome, Edge, Firefox, etc.) to guess which site you typed so its domain can be whitelisted. Domains not on the list (or the built-in “permanent” list) get **403** with a small HTML page.

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

Point the browser’s **HTTP proxy** at `127.0.0.1` and your **`-ProxyPort`**. The script also adds a **Windows Firewall** rule for the proxy port (see `Configure-FirewallForProxy` in the script).

**Limitation:** The forwarder is built around **`HttpListener`** and **`WebRequest`**—it is aimed at **HTTP** traffic through the proxy. **HTTPS** often uses **CONNECT** tunneling; real-world HTTPS support may be incomplete depending on browser and site. Treat this as an experimental guard, not a production MITM appliance.

---

<p align="center">
  <sub>🛡️ Gorstak Security Tooling</sub>
</p>

---

## Disclaimer

**NO WARRANTY.** THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

**Limitation of Liability.** IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

---

## Disclaimer (read this; it matters)

This software and documentation are provided **“as is”**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. **Use at your own risk.**

- Nothing here is professional security, legal, medical, or financial advice.
- The authors and contributors are **not liable** for any direct, indirect, incidental, special, exemplary, or consequential damages (including loss of data, profits, goodwill, or business interruption) arising from use or inability to use this material, **even if advised of the possibility** of such damages.
- You are solely responsible for compliance with laws and policies that apply to you. Do not use these tools to violate privacy, computer misuse laws, or terms of service.
- “Detection,” “monitoring,” and “hardening” features can be wrong (false positives), miss real threats (false negatives), and change system behavior. **Test in a safe environment** before relying on anything important.

If you do not agree, **do not use** this repository.
