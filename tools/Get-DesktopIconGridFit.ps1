function Get-DesktopIconGridFit {
    <#
    .SYNOPSIS
        Calculates how many desktop icons can fit on the virtual desktop (all screens).

    .OUTPUTS
        [PSCustomObject] with:
            - TotalWidth: Total virtual desktop width (pixels)
            - MaxHeight: Max height of any connected monitor (pixels)
            - IconWidth: Icon grid width (pixels)
            - IconHeight: Icon grid height (pixels)
            - IconsPerRow: Number of icons that fit per row
            - IconsPerColumn: Number of icons that fit per column
            - TotalIcons: Total icons that can fit
    #>

    Add-Type -AssemblyName System.Windows.Forms

    # Get screen bounds
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $totalWidth = 0
    $maxHeight = 0
    foreach ($screen in $screens) {
        $totalWidth += $screen.Bounds.Width
        if ($screen.Bounds.Height -gt $maxHeight) {
            $maxHeight = $screen.Bounds.Height
        }
    }

    # Get icon spacing from registry
    $metrics = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name IconSpacing, IconVerticalSpacing
    $iconWidth = [math]::Abs($metrics.IconSpacing) / 15
    $iconHeight = [math]::Abs($metrics.IconVerticalSpacing) / 15

    # Compute fit
    $iconsPerRow = [math]::Floor($totalWidth / $iconWidth)
    $iconsPerColumn = [math]::Floor($maxHeight / $iconHeight)
    $totalIcons = $iconsPerRow * $iconsPerColumn

    # Return result as object
    [PSCustomObject]@{
        TotalWidth      = $totalWidth
        MaxHeight       = $maxHeight
        IconWidth       = [math]::Round($iconWidth, 2)
        IconHeight      = [math]::Round($iconHeight, 2)
        IconsPerRow     = $iconsPerRow
        IconsPerColumn  = $iconsPerColumn
        TotalIcons      = $totalIcons
    }
}
