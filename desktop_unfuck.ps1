param (
    [string]$pathToUnfuck = [Environment]::GetFolderPath('Desktop'),
    [string]$configPath = "$PSScriptRoot\settings\dataTypes.ps1"
)

. "$PSScriptRoot\tools\Get-DesktopIconGridFit.ps1"
# Load the config
$config = . $configPath
$suffixes = . "$PSScriptRoot\settings\suffixes.ps1"
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
		if ($dest.Skip) {
			$global:skipped++
			continue
		}
		$destPath = $PathDesc.Path + "\" + $dest.Path + $PathDesc.PathSuffix
		$fileName = Split-Path $file -Leaf
		#Write-Host $fileType
		if (-not (Test-Path $destPath)) { New-Item -Path $destPath -ItemType Directory | Out-Null }
		mv $file.FullName "$destPath\$fileName"
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
if ($skipped -gt 0) {
	Write-Host "Handle recurrency"
}
