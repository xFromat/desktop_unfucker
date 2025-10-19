param (
	[string]$filesListDeletion = ".\generated_files.txt"
)

# Path to the saved list
$fileList = Get-Content -Path $filesListDeletion

foreach ($file in $fileList) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Force
        Write-Host "Deleted: $file"
    } else {
        Write-Host "Not found: $file"
    }
}

