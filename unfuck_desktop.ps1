param (
    [string]$pathToUnfuck = [Environment]::GetFolderPath('Desktop'),
    [string]$configPath = "$PSScriptRoot\settings\dataTypes.ps1",
	[bool]$ForceDirs = $false,
	[bool]$ForceApps = $false,
	[int]$executionCounter = 0,
	[string]$PathPrefix = "unfucked_"
)

. "$PSScriptRoot\tools\Get-DesktopIconGridFit.ps1"
# Load the config
$config = . $configPath
$suffixes = . "$PSScriptRoot\settings\suffixes.ps1"

if ($ForceApps) {
	$apps["Skip"] = $false
}

$global:epsilon = 15
$global:skipped = 0

# Public desktop path
[string]$publicPathToUnfuck = [System.IO.Path]::Combine($env:PUBLIC, 'Desktop')

# Function to get MIME type from registry
function Get-MimeType {
    param([string]$filePath)

    $ext = [System.IO.Path]::GetExtension($filePath)
    $mimeType = $null 

    try {
        $regKey = "Registry::HKEY_CLASSES_ROOT\$ext"
        $contentType = (Get-ItemProperty -Path $regKey -Name "Content Type" -ErrorAction SilentlyContinue).'Content Type'
        if ($contentType) {
            $mimeType = $ext
        }
    } catch {}

    return $mimeType
}

function Get-MagicNumberType {
    param([string]$filePath)

    $signatures = @{
        "25504446" = ".pdf"
        "89504E47" = ".png"
        "FFD8FF"   = ".jpg"
        "47494638" = ".gif"
        "504B0304" = ".zip_or_office"  # Needs deeper inspection
        "52617221" = ".rar"
        "7B5C727466" = ".rtf"
        "D0CF11E0" = ".doc"  # Legacy Office format
    }

    $initialType = $null
    try {
        $bytes = Get-Content -Path $filePath -Encoding Byte -TotalCount 8
        $hex = ($bytes | ForEach-Object { $_.ToString("X2") }) -join ""

        foreach ($signature in $signatures.Keys) {
            if ($hex.StartsWith($signature)) {
                $initialType = $signatures[$signature]

                # Special check for Office file inside ZIP
                if ($initialType -eq ".zip_or_office") {
                    Add-Type -AssemblyName System.IO.Compression.FileSystem
                    try {
                        $zip = [System.IO.Compression.ZipFile]::OpenRead($filePath)
                        $entries = $zip.Entries | Select-Object -ExpandProperty FullName
                        $zip.Dispose()

                        if ($entries -match "^word/") { return ".docx" }
                        elseif ($entries -match "^xl/") { return ".xlsx" }
                        elseif ($entries -match "^ppt/") { return ".pptx" }
                        else { return ".zip" }
                    } catch {
                        return ".zip"
                    }
                }

                return $initialType
            }
        }
    } catch {
        return $null
    }

    return $initialType 
}

function Strip-Dot {
	param([System.IO.FileInfo]$ext)
	return $ext.TrimStart(".")
}

function Get-FileType {
    param([System.IO.FileInfo]$file)

    $type = Get-MagicNumberType -filePath $file
    if (![string]::IsNullOrEmpty($type)) { return $type }

    $type = Get-MimeType -filePath $file
    if (![string]::IsNullOrEmpty($type)) { return $type }

    return [System.IO.Path]::GetExtension($file)
}

function Init-CounterObj {
	param([string]$path)
	if ([string]::IsNullOrWhiteSpace($path) -or -not (Test-Path $path)) {
		return [PSCustomObject]@{
			Path = ""
			PathSuffix = ""
			FilesCount = 0
			Files = @()
			DirsCount = 0
			Dirs = @()
		}
	}  
	return [PSCustomObject]@{
		Path = $path
		PathSuffix = if ((Resolve-Path $path).ProviderPath -like "C:\Users\Public\*") { $suffixes["public"] } else { $suffixes["priv"] }
		FilesCount = (Get-ChildItem -Path $path -File).Count
		Files = Get-ChildItem -Path $path -File
		DirsCount = (Get-ChildItem -Path $path -Directory).Count
		Dirs = (Get-ChildItem -Path $path -Directory)
	}
}

function Is-DirSkippable {
	param([string]$path, [string]$prefix)

	return (Get-ChildItem -Path $path -Directory | Where-Object { $_.Name.StartsWith($prefix) })
}

function Get-UniquePath {
    param (
        [string]$Path,
        [ValidateSet("File", "Directory")]
        [string]$ItemType = "File"
    )

    $directory = Split-Path $Path -Parent
    $originalName = Split-Path $Path -Leaf

    if ($ItemType -eq "File") {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($originalName)
        $ext = [System.IO.Path]::GetExtension($originalName)
    } else {
        $baseName = $originalName
        $ext = ""
    }

    $counter = 1
    $newName = "$baseName$ext"
    $newPath = Join-Path -Path $directory -ChildPath $newName

    while (Test-Path $newPath) {
        $newName = "$baseName($counter)$ext"
        $newPath = Join-Path -Path $directory -ChildPath $newName
        $counter++
    }

    return $newPath
}

function main {
	param(
		[PSCustomObject]$PathDesc
	)
	
	if ([string]::IsNullOrWhiteSpace($PathDesc.Path) -or -not (Test-Path $PathDesc.Path)) {
		return $null
	}

	foreach ($file in $PathDesc.Files) {
		#Write-Host $file.FullName
		$fileType = Get-FileType -file $file
    		if (![string]::IsNullOrEmpty($fileType)) { 
			$fileType = $fileType.TrimStart(".")
		}
		$dest = $config[$fileType]
		if (-not $dest) {
			$dest = $config["default"]
		}
		if ($dest.Skip) {
			$global:skipped++
			continue
		}
		$destPath = $PathDesc.Path + "\" + $dest.Path + $PathDesc.PathSuffix
		$fileName = Split-Path $file -Leaf
		#Write-Host $fileType
		if (-not (Test-Path $destPath)) { New-Item -Path $destPath -ItemType Directory | Out-Null }
		$uniquePath = Get-UniquePath -Path "$destPath\$fileName" -ItemType File
		mv $file.FullName $uniquePath
	}
	if (-not $ForceDirs -and $config["dir"].Skip) { return }
	$dest = $config["dir"]
	$destPath = $PathDesc.Path + "\" + $dest.Path + $PathDesc.PathSuffix
	foreach ($dir in $PathDesc.Dirs) {
		if (Is-DirSkippable $dir $PathPrefix) { continue }
		if (-not (Test-Path $destPath)) { New-Item -Path $destPath -ItemType Directory | Out-Null }
		$dirName = Split-Path $dir -Leaf
		$uniquePath = Get-UniquePath -Path $destPath\$dirName -ItemType Directory
		mv $dir $uniquePath
	}
}
# Total number of icons that can fit in 1 layer on your screen(s)
$desktopSize = Get-DesktopIconGridFit
$desktopSize | Format-Table -AutoSize

$files = Init-CounterObj -path $pathToUnfuck
$publicFiles = Init-CounterObj -path $publicPathToUnfuck

$files | Format-List
$publicFiles | Format-List

main -Path $files
main -Path $publicFiles

Write-Host "$skipped"
$allIcons = -$epsilon
foreach ($screen in $desktopSize) {
	$allIcons += $screen.TotalIcons
}

if ($executionCounter -ge 3) {
	Write-Host "Reccurency limit has been hit, peace out"
	exit 0
}

Write-Host $allIcons

if ($skipped -gt $allIcons) {
	if (-not $ForceDirs) {
		Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -executionCounter $($executionCounter + 1) -ForceDirs `"$true`""
	}
	if (-not $ForceApps) {
		Start-Process -FilePath "powershell" -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -executionCounter $($executionCounter + 1) -ForceApps `"$true`" -ForceDirs `"$true`""
	}
	Write-Host "Handle recurrency"
}
