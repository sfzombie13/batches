##############################################################################
# Minimal Output Image Resizer Script with Logging and Automatic Log Cleanup
##############################################################################

# ------------------------- CONFIGURATION ------------------------------------
# 1) Where do you want your logs stored?
#    (Put it outside your source folder to avoid confusion.)
$logDirectory = "C:\MyLogs\ImageResizer"  # <-- Adjust as needed

# 2) How many days to keep old logs?
$retentionDays = 7  # <-- Adjust as needed

##############################################################################
# 1. Prompt the user for input (minimal console output)
##############################################################################
$sourceFolder      = Read-Host "Source folder path containing the images"
$destinationFolder = Read-Host "Destination folder path (where resized images go)"
$portraitWidthInches   = [float](Read-Host "Portrait width (inches)")
$portraitHeightInches  = [float](Read-Host "Portrait height (inches)")
$landscapeWidthInches  = [float](Read-Host "Landscape width (inches)")
$landscapeHeightInches = [float](Read-Host "Landscape height (inches)")
$dpi = [int](Read-Host "Desired DPI")

##############################################################################
# 2. Prepare for logging (start transcript)
##############################################################################
# Ensure the log folder exists
if (!(Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}

# Create a timestamped log file in that folder
$timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$logFile   = Join-Path $logDirectory "ImageResizer_$timestamp.log"

# Start logging all console output to this file
Start-Transcript -Path $logFile -Append | Out-Null

Write-Host "Starting image resize script..."
Write-Host "Logs will be saved to: $logFile"

##############################################################################
# 3. Validate user input
##############################################################################
if (-not (Test-Path $sourceFolder)) {
    Write-Host "ERROR: Source folder path is invalid. Exiting."
    # Stop transcript before exit
    Stop-Transcript | Out-Null
    exit
}

# If destination doesn't exist, create it
if (!(Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Prepare subfolders
$portraitFolder  = Join-Path $destinationFolder "Portrait"
$landscapeFolder = Join-Path $destinationFolder "Landscape"
foreach ($sub in @($portraitFolder, $landscapeFolder)) {
    if (!(Test-Path -Path $sub)) {
        New-Item -ItemType Directory -Path $sub | Out-Null
    }
}

# Global choice for overwrite/skip (X, Z, Q)
$script:globalChoice = $null

##############################################################################
# 4. Helper Functions (Minimal Output)
##############################################################################

# Reads EXIF orientation if present.
function Get-OrientationValue {
    param([string]$file)
    try {
        & magick identify -ping -format "%[EXIF:Orientation]" "$file" 2>$null
    } catch { $null }
}

# Decides orientation from EXIF value
function Determine-AspectByOrientation {
    param([string]$orientationValue)
    switch ($orientationValue) {
        '1' { 'landscape' }
        '3' { 'landscape' }
        '6' { 'portrait'  }
        '8' { 'portrait'  }
        default { 'unknown' }
    }
}

# Pixel-based fallback if EXIF is missing/unknown
function Get-FallbackAspect {
    param([string]$file)
    try {
        $dim = & magick identify -ping -format "%w %h" "$file" 2>$null
        if ($dim -match "^(\d+)\s+(\d+)$") {
            $width  = [int]$matches[1]
            $height = [int]$matches[2]
            if    ($width -gt $height) { 'landscape' }
            elseif($width -lt $height) { 'portrait'  }
            else                       { 'landscape' }  # square => landscape
        }
        else { 'landscape' }  # default to landscape if identify fails
    }
    catch {
        'landscape'           # also default to landscape if error
    }
}

# Overwrite/Rename/Skip logic
function Process-Choice {
    param([string]$destinationFile, [string]$choice)
    switch ($choice) {
        'O' { $destinationFile }
        'A' {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($destinationFile)
            $ext  = [System.IO.Path]::GetExtension($destinationFile)
            (Join-Path (Split-Path -Parent $destinationFile) "$base-1$ext")
        }
        'S' { $null }
        default { $null }
    }
}

function Handle-ExistingFile {
    param([string]$destinationFile)
    if ($script:globalChoice -ne $null) {
        return Process-Choice $destinationFile $script:globalChoice
    }
    if (Test-Path $destinationFile) {
        $choice = Read-Host "File exists. (O)verwrite, (A)ppend -1, (S)kip, (X) overwrite all, (Z) append all, (Q) skip all"
        switch ($choice.ToUpper()) {
            'X' { $script:globalChoice = 'O'; return Process-Choice $destinationFile 'O' }
            'Z' { $script:globalChoice = 'A'; return Process-Choice $destinationFile 'A' }
            'Q' { $script:globalChoice = 'S'; return Process-Choice $destinationFile 'S' }
            default { return Process-Choice $destinationFile $choice.ToUpper() }
        }
    } else {
        return $destinationFile
    }
}

##############################################################################
# 5. Core Logic
##############################################################################
Write-Host "Processing images in $sourceFolder..."

# Use wildcard "*"
$extensions = '*.jpg','*.jpeg','*.png','*.bmp','*.gif','*.tif','*.tiff'
$files = Get-ChildItem -Path "$($sourceFolder)\*" -Include $extensions -File

foreach ($file in $files) {
    $sourceFile = $file.FullName

    # 1) EXIF orientation
    $exifVal = Get-OrientationValue -file $sourceFile
    if ($exifVal) {
        $aspect = Determine-AspectByOrientation -orientationValue $exifVal
    } else {
        $aspect = 'unknown'
    }

    # 2) Fallback
    if ($aspect -eq 'unknown') {
        $aspect = Get-FallbackAspect -file $sourceFile
    }

    # 3) Decide portrait or landscape
    switch ($aspect) {
        'portrait' {
            $destFolder = $portraitFolder
            $targetW = $portraitWidthInches * $dpi
            $targetH = $portraitHeightInches * $dpi
        }
        'landscape' {
            $destFolder = $landscapeFolder
            $targetW = $landscapeWidthInches * $dpi
            $targetH = $landscapeHeightInches * $dpi
        }
        default {
            $destFolder = $landscapeFolder  # force landscape
            $targetW = $landscapeWidthInches * $dpi
            $targetH = $landscapeHeightInches * $dpi
        }
    }

    # 4) Final destination
    $destFile = Join-Path $destFolder $file.Name

    # 5) Handle existing file conflicts
    $finalDest = Handle-ExistingFile -destinationFile $destFile
    if ($finalDest) {
        # 6) Resize
        Start-Process -FilePath "magick" -ArgumentList `
            "$sourceFile -auto-orient -resize ${targetW}x${targetH}! -density $dpi `"$finalDest`"" `
            -NoNewWindow -Wait
    }
}

Write-Host "Resizing complete! Images saved in $destinationFolder."

##############################################################################
# 6. Stop the transcript
##############################################################################
Stop-Transcript | Out-Null

##############################################################################
# 7. Automatic Cleanup of Old Logs
##############################################################################
if (Test-Path $logDirectory) {
    # Remove logs older than X days
    $cutoff = (Get-Date).AddDays(-$retentionDays)
    Get-ChildItem -Path $logDirectory -Filter *.log -File | Where-Object {
        $_.LastWriteTime -lt $cutoff
    } | Remove-Item -Force
}


Write-Host "Done."
Read-Host "Press Enter to exit"
