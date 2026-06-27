# Define where the drivers will be saved
$ExportFolder = "C:\DriverExport"

# Check if the folder exists, if not, create it
if (!(Test-Path -Path $ExportFolder)) {
    Write-Host "Creating export directory at $ExportFolder..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $ExportFolder | Out-Null
}

# Clear out the folder if it already has old stuff in it
Remove-Item -Path "$ExportFolder\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Scanning and extracting third-party drivers..." -ForegroundColor Yellow
Write-Host "This usually takes 1 to 3 minutes. Please wait..." -ForegroundColor Yellow

# Export the drivers
try {
    Export-WindowsDriver -Online -Destination $ExportFolder | Out-Null
    Write-Host "SUCCESS! Drivers have been exported to: $ExportFolder" -ForegroundColor Green
    Write-Host "You can now copy that folder to a USB flash drive." -ForegroundColor Green
}
catch {
    Write-Host "An error occurred while exporting drivers. Ensure you are running PowerShell as Administrator." -ForegroundColor Red
    Write-Error $_
}