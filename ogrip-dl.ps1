# ogrip-dl
# Created by Madison L.H. Wass <github.com/madisoninspace>

# Variables
$baseUrl = "https://gis1.oit.ohio.gov/ZIPARCHIVES_III/ELEVATION/3DEP/LIDAR/"
$lidarDirectory = "lidar"
$tsvFilePath = "ogrip.tsv"

# Parse TSV File
$ids = Get-Content -Path $tsvFilePath
$ids = $ids | ForEach-Object { $_.Split("`t")[0] }

# Check if the lidar directory exists. If not, create it. 
# If it already exists, empty it.
if (!(Test-Path -Path "lidar")) {
    New-Item -ItemType Directory -Path "lidar"
} else {
    if ((Get-ChildItem -Path "lidar").Count -gt 0) {
        Remove-Item -Path "lidar\*" -Recurse
    }
}

# Ask the user for the county code. These are three letters.
# If the code is Columbus, allow it.
$countyCode = Read-Host -Prompt "Please enter the county code:"
if ($countyCode == "Columbus" || $countyCode -match '^\w{3}$') {
    foreach ($id in $ids) {
        Invoke-WebRequest -Uri "$baseUrl/$countyCode/$id.zip" -OutFile "$id.zip"
    }

    if ((Get-ChildItem -Path "$lidarDirectory").Count -gt 0) {
        $zipFiles = Get-ChildItem -Path "$lidarDirectory\*.zip"
        foreach ($zipFile in $zipFiles) {
            Expand-Archive -Path $zipFile.FullName -DestinationPath "$lidarDirectory" -Force
        }

        Remove-Item -Path "lidar\*.zip" -Force
    }
} else {
    Write-Host "Invalid county code."
    Exit 1
}