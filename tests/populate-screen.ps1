param (
	[int]$iconsTotal = 0,
    [string]$outputListPath = ".\generated_files.txt",
    [string]$desktopPath = [Environment]::GetFolderPath('Desktop'),
	[int]$filesPercent = 95
)

# Define a list of real file extensions
$exts = @(
	".txt", ".csv", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
	".pdf", ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".svg",
	".mp3", ".wav", ".flac", ".mp4", ".avi", ".mkv", ".mov",
	".zip", ".rar", ".7z", ".tar", ".gz",
	".exe", ".msi", ".bat", ".ps1", ".sh", ".py", ".js", ".html", ".css", ".json", ".xml", ".lnk"
)

$generatedFiles = @()

for ($i = 1; $i -le (($iconsTotal -15) * 8); $i++) {
	$filePath = Join-Path -Path "$desktopPath\" -ChildPath ("{0}{1}" -f "test", $i)
	$j = (Get-Random -Minimum 0 -Maximum 100)
	if ($j -lt $filesPercent) {
		$randomExt = Get-Random -InputObject $exts
		$filePath += $randomExt
    	New-item -Path $filePath -ItemType File -Force
	}
	else {
		New-Item -Path $filePath -ItemType Directory -Force 
	}
    "$filePath"
    $generatedFiles += $filePath
}

# Save list to output file
$generatedFiles | Set-Content -Path $outputListPath

