# Windows provided method of installing winget on a sandbox
$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager
Write-Host "Done."

# Install necessary version of AutoHotkey
Write-Host "Installing AutoHotkey"
winget install -v 1.1.37.02 --id=AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements
Write-Host "Done."
