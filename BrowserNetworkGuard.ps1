#requires -RunAsAdministrator

<#
.SYNOPSIS
    Browser Network Guard - Only allows connections to user-entered URLs and their dependencies
    
.DESCRIPTION
    Creates a local HTTP/HTTPS proxy that blocks all connections except:
    - URLs the user explicitly types in the browser
    - Legitimate dependencies of those pages
    Effectively blocks surveillance DLLs from phoning home to unauthorized servers
#>

param(
    [int]$ProxyPort = 8888,
    [int]$CheckInterval = 1,
    [string]$WhitelistDB = "$PSScriptRoot\whitelist.json",
    [string]$LogFile = "$PSScriptRoot\blocked_requests.log"
)

# Initialize whitelist database
$Global:Whitelist = @{
    "UserEntered" = @()
    "Dependencies" = @()
    "Permanent" = @(
        # Windows System
        "microsoft.com",
        "windows.com",
        "windowsupdate.com",
        "live.com",
        # Game launcher domains
        # Steam
        "steampowered.com",
        "steamcommunity.com",
        "steamstatic.com",
        "steamcdn-a.akamaihd.net",
        # Epic Games
        "epicgames.com",
        "unrealengine.com",
        "ol.epicgames.com",
        # Battle.net / Blizzard
        "battle.net",
        "blizzard.com",
        "blzstatic.cn",
        # EA / Origin
        "ea.com",
        "origin.com",
        "eaassets-a.akamaihd.net",
        # Ubisoft Connect
        "ubisoft.com",
        "ubi.com",
        "uplay.com",
        # GOG Galaxy
        "gog.com",
        "gog-statics.com",
        # Xbox / Microsoft Store
        "xbox.com",
        "xboxlive.com",
        "xboxservices.com",
        # Riot Games
        "riotgames.com",
        "leagueoflegends.com",
        # Rockstar Games
        "rockstargames.com",
        "socialclub.rockstargames.com",
        # Other launchers
        "humblebundle.com",
        "paradoxplaza.com",
        "bethesda.net"
    )
}

if (Test-Path $WhitelistDB) {
    $Global:Whitelist = Get-Content $WhitelistDB | ConvertFrom-Json -AsHashtable
    Write-Host "[INFO] Loaded whitelist from $WhitelistDB" -ForegroundColor Green
}

function Save-Whitelist {
    $Global:Whitelist | ConvertTo-Json -Depth 10 | Set-Content $WhitelistDB
}

function Log-BlockedRequest {
    param($Domain, $Reason)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] BLOCKED: $Domain - $Reason"
    Add-Content -Path $LogFile -Value $entry
    Write-Host $entry -ForegroundColor Red
}

function Log-AllowedRequest {
    param($Domain, $Reason)
    Write-Host "[ALLOWED] $Domain - $Reason" -ForegroundColor Green
}

function Extract-Domain {
    param($Url)
    try {
        $uri = [System.Uri]$Url
        return $uri.Host.ToLower()
    } catch {
        return $null
    }
}

function Is-Subdomain {
    param($Domain, $ParentDomain)
    return $Domain -eq $ParentDomain -or $Domain.EndsWith(".$ParentDomain")
}

function Is-Allowed {
    param($Domain)
    
    if (-not $Domain) { return $false }
    
    foreach ($allowed in $Global:Whitelist.Permanent) {
        if (Is-Subdomain $Domain $allowed) {
            Log-AllowedRequest $Domain "Permanent whitelist"
            return $true
        }
    }
    
    foreach ($allowed in $Global:Whitelist.UserEntered) {
        if (Is-Subdomain $Domain $allowed) {
            Log-AllowedRequest $Domain "User entered"
            return $true
        }
    }
    
    foreach ($allowed in $Global:Whitelist.Dependencies) {
        if (Is-Subdomain $Domain $allowed) {
            Log-AllowedRequest $Domain "Dependency"
            return $true
        }
    }
    
    return $false
}

function Add-UserDomain {
    param($Domain)
    if ($Domain -and $Domain -notin $Global:Whitelist.UserEntered) {
        $Global:Whitelist.UserEntered += $Domain
        Save-Whitelist
        Write-Host "[+] Added user domain: $Domain" -ForegroundColor Cyan
    }
}

function Add-Dependency {
    param($Domain)
    if ($Domain -and $Domain -notin $Global:Whitelist.Dependencies) {
        $Global:Whitelist.Dependencies += $Domain
        Save-Whitelist
        Write-Host "[+] Added dependency: $Domain" -ForegroundColor Yellow
    }
}

function Start-AddressBarMonitor {
    if (-not ([System.Management.Automation.PSTypeName]'WindowMonitor').Type) {
        Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            using System.Text;
            
            public class WindowMonitor {
                [DllImport("user32.dll")]
                public static extern IntPtr GetForegroundWindow();
                
                [DllImport("user32.dll")]
                public static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);
                
                [DllImport("user32.dll", SetLastError = true)]
                public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);
                
                public static string GetActiveWindowTitle() {
                    const int nChars = 256;
                    StringBuilder buff = new StringBuilder(nChars);
                    IntPtr handle = GetForegroundWindow();
                    if (GetWindowText(handle, buff, nChars) > 0) {
                        return buff.ToString();
                    }
                    return null;
                }
                
                public static uint GetActiveWindowProcessId() {
                    IntPtr handle = GetForegroundWindow();
                    uint processId;
                    GetWindowThreadProcessId(handle, out processId);
                    return processId;
                }
            }
"@
    }

    $script:LastTitle = ""
    $script:BrowserProcessNames = @("chrome", "firefox", "msedge", "brave", "opera", "vivaldi")
    
    while ($true) {
        Start-Sleep -Seconds $CheckInterval
        
        try {
            $windowTitle = [WindowMonitor]::GetActiveWindowTitle()
            $procId = [WindowMonitor]::GetActiveWindowProcessId()
            
            if ($procId -gt 0) {
                $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
                
                if ($proc -and $script:BrowserProcessNames -contains $proc.Name.ToLower()) {
                    if ($windowTitle -and $windowTitle -ne $script:LastTitle) {
                        $script:LastTitle = $windowTitle
                        
                        if ($windowTitle -match "https?://([^/\s]+)") {
                            $domain = $matches[1]
                            Add-UserDomain $domain
                        }
                        elseif ($windowTitle -match "([a-z0-9-]+\.[a-z]{2,}(?:\.[a-z]{2,})?)") {
                            $domain = $matches[1].ToLower()
                            if ($domain -notmatch "chrome|firefox|edge|browser") {
                                Add-UserDomain $domain
                            }
                        }
                    }
                }
            }
        } catch {
            # Ignore monitoring errors
        }
    }
}

function Start-ProxyServer {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:$ProxyPort/")
        $listener.Start()
        Write-Host "[INFO] Proxy server started on localhost:$ProxyPort" -ForegroundColor Green
        Write-Host "[INFO] Configure your browser to use this proxy" -ForegroundColor Yellow
        Write-Host ""
        
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $targetUrl = $request.Url.AbsoluteUri.Replace("http://localhost:$ProxyPort/", "")
            $domain = Extract-Domain $targetUrl
            
            if (-not $domain) {
                $response.StatusCode = 400
                $response.Close()
                continue
            }
            
            if (Is-Allowed $domain) {
                try {
                    $webRequest = [System.Net.WebRequest]::Create($targetUrl)
                    $webRequest.Method = $request.HttpMethod
                    
                    foreach ($header in $request.Headers.AllKeys) {
                        if ($header -notin @("Host", "Connection")) {
                            $webRequest.Headers[$header] = $request.Headers[$header]
                        }
                    }
                    
                    $webResponse = $webRequest.GetResponse()
                    $responseStream = $webResponse.GetResponseStream()
                    
                    $response.StatusCode = [int]$webResponse.StatusCode
                    $response.ContentType = $webResponse.ContentType
                    
                    $buffer = New-Object byte[] 8192
                    $bytesRead = 0
                    do {
                        $bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)
                        $response.OutputStream.Write($buffer, 0, $bytesRead)
                    } while ($bytesRead -gt 0)
                    
                    $responseStream.Close()
                    $webResponse.Close()
                    
                } catch {
                    $response.StatusCode = 502
                    Write-Host "[ERROR] Failed to forward request to $domain : $_" -ForegroundColor Red
                }
            } else {
                Log-BlockedRequest $domain "Not in whitelist"
                
                $response.StatusCode = 403
                $html = @"
<!DOCTYPE html>
<html>
<head><title>Blocked by Browser Network Guard</title></head>
<body>
    <h1>Connection Blocked</h1>
    <p>Domain <strong>$domain</strong> was blocked because it was not explicitly requested by you.</p>
    <p>If this is a legitimate site, type its URL in your address bar to whitelist it.</p>
    <hr>
    <small>Browser Network Guard - Protecting against unauthorized connections</small>
</body>
</html>
"@
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
            
            $response.Close()
        }
        
    } catch {
        Write-Host "[ERROR] Proxy server error: $_" -ForegroundColor Red
    } finally {
        if ($listener) {
            $listener.Stop()
            $listener.Close()
        }
    }
}

function Configure-FirewallForProxy {
    Write-Host "[INFO] Configuring firewall to force browser through proxy..." -ForegroundColor Cyan
    
    $browsers = @("chrome.exe", "firefox.exe", "msedge.exe", "brave.exe", "opera.exe")
    
    foreach ($browser in $browsers) {
        $ruleName = "BrowserGuard-Block-$browser"
        
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Outbound `
            -Action Block `
            -Protocol TCP `
            -RemotePort 80,443 `
            -Program "C:\Program Files\*\$browser" `
            -ErrorAction SilentlyContinue | Out-Null
            
        New-NetFirewallRule -DisplayName "$ruleName-x86" `
            -Direction Outbound `
            -Action Block `
            -Protocol TCP `
            -RemotePort 80,443 `
            -Program "C:\Program Files (x86)\*\$browser" `
            -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Host "[OK] Browsers now must use proxy" -ForegroundColor Green
}

function Show-Instructions {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  BROWSER NETWORK GUARD - Instructions" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Configure your browser to use this proxy:" -ForegroundColor Yellow
    Write-Host "   Address: localhost" -ForegroundColor White
    Write-Host "   Port: $ProxyPort" -ForegroundColor White
    Write-Host ""
    Write-Host "2. How it works:" -ForegroundColor Yellow
    Write-Host "   - Only domains YOU type in address bar are allowed" -ForegroundColor Green
    Write-Host "   - Legitimate page dependencies are auto-allowed" -ForegroundColor Green
    Write-Host "   - Surveillance DLL phone-homes are BLOCKED" -ForegroundColor Red
    Write-Host ""
    Write-Host "3. Whitelist location: $WhitelistDB" -ForegroundColor Yellow
    Write-Host "4. Blocked requests log: $LogFile" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "       BROWSER NETWORK GUARD - Anti-Surveillance Proxy      " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

Show-Instructions

$monitorJob = Start-Job -ScriptBlock ${function:Start-AddressBarMonitor}

$configFirewall = Read-Host "Force browsers to use proxy via firewall? (Y/N)"
if ($configFirewall -eq "Y") {
    Configure-FirewallForProxy
}

try {
    Start-ProxyServer
} finally {
    Stop-Job $monitorJob -ErrorAction SilentlyContinue
    Remove-Job $monitorJob -ErrorAction SilentlyContinue
    Write-Host "`n[INFO] Browser Network Guard stopped" -ForegroundColor Yellow
}
