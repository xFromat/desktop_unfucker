param (
    [int]$iconsTotal = 0,
    [string]$outputListPath = ".\generated_files.txt",
    [string]$desktopPath = [Environment]::GetFolderPath('Desktop')
)

$exts =  @(".png", ".txt", ".lnk", ".pdf")
$generatedFiles = @()

for ($i = 1; $i -le (($iconsTotal - 2)*3); $i++) {
    $randomExt = Get-Random -InputObject $exts  
    $filePath = Join-Path -Path "$desktopPath\" -ChildPath ("{0}{1}{2}" -f "test", $i, $randomExt)

    "$filePath"

    New-item -Path $filePath -ItemType File -Force

    $generatedFiles += $filePath
}

# Save list to output file
$generatedFiles | Set-Content -Path $outputListPath
