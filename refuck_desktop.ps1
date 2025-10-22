# Define the prefix to match
$prefix = "test_"  # <-- change this to your folder prefix

# Define the two target desktop locations
$desktops = @(
    [Environment]::GetFolderPath("Desktop"),
    "$env:PUBLIC\Desktop"
)

foreach ($desktop in $desktops) {
    Write-Host "`nChecking: $desktop" -ForegroundColor Cyan

    # Get all directories in this desktop that start with the prefix
    $dirs = Get-ChildItem -Path $desktop -Directory -Filter "$prefix*"

    foreach ($dir in $dirs) {
        Write-Host " Unloading contents from: $($dir.FullName)" -ForegroundColor Yellow

        # Move all files and folders inside the prefixed directory up to the desktop
        Get-ChildItem -Path $dir.FullName -Force | ForEach-Object {
            $destination = Join-Path -Path $desktop -ChildPath $_.Name

            # If destination already exists, make a unique name
            $counter = 1
            $newDestination = $destination
            while (Test-Path $newDestination) {
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                $ext = [System.IO.Path]::GetExtension($_.Name)
                $newDestination = Join-Path $desktop "$baseName($counter)$ext"
                $counter++
            }

            Move-Item -Path $_.FullName -Destination $newDestination -Force
        }

        # Optionally remove the now-empty folder
        Remove-Item -Path $dir.FullName -Force -Recurse
        Write-Host "  → Removed empty folder: $($dir.Name)" -ForegroundColor DarkGray
    }
}

Write-Host "`nDone unloading all prefixed directories!" -ForegroundColor Green

