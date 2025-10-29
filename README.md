# Desktop unfucker

A PowerShell script to help organize messy desktop files by grouping them into folders.

## Description

This script helps clean up cluttered desktops by automatically categorizing and moving files into organized folders based on their types.

## Requirements

- Windows OS
- PowerShell 5.1 or higher
- Execution policy that allows running scripts or pack it is as a `.bat`

## How to Run

1. Open PowerShell as Administrator
> ℹ️
>
> Administrator is optional<br/> 
> It is needed if you have a lot of stuff in `Public\Desktop`
2. Navigate to the script directory
3. Run the script:

    ```powershell
    .\desktop-unfucker.ps1
    ```

## Features

- Automatically creates category folders with a given prefix (default: **unfucked**)
- Moves files into appropriate folders based on extension
- Preserves original files
- Logs operations for review

## Usage Notes

- The script will organize files from your desktop
- Files are categorized into folders like Documents, Images, Videos, etc.
- Running the script multiple times will not create duplicate folders

## Safety

- The script doesn't delete any files
- Original files are only moved, not modified
- Can be safely interrupted at any time

## License

All code licensed under the MIT License
