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
	$output = @()
	# Get screen bounds
	$screens = [System.Windows.Forms.Screen]::AllScreens
	foreach ($screen in $screens) {
		$usableWidth = $screen.WorkingArea.Width
		$usableHeight = $screen.WorkingArea.Height

		# Get icon spacing from registry
		$metrics = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name IconSpacing, IconVerticalSpacing, BorderWidth
		$iconSize = (Get-ItemProperty -path HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop -name IconSize).IconSize
		$iconWidth = [math]::Max(([math]::Abs($metrics.IconSpacing) / [math]::Abs($metrics.BorderWidth)), $iconSize)
		$iconHeight = [math]::Max(([math]::Abs($metrics.IconVerticalSpacing) / [math]::Abs($metrics.BorderWidth)), $iconSize)

		# Compute fit
    	$columns = [math]::Floor($usableWidth / $iconWidth)
		$rows = [math]::Floor($usableHeight / $iconHeight)
    	$totalIcons = $columns * $rows

    	# Return result as object
		$output += [PSCustomObject]@{
			Width = $usableWidth
        	Height = $usableHeight
        	IconWidth = [math]::Floor($iconWidth)
        	IconHeight = [math]::Floor($iconHeight)
        	Columns = $columns
			Rows = $rows
        	TotalIcons = $totalIcons
    	}
	}
	return $output
}
