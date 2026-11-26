
# Root folder = the folder where this script is located
$RootFolder = $PSScriptRoot

# Define date boundaries
$CreationStart = Get-Date "2026-01-01T00:00:00"
$CreationEnd   = (Get-Date).AddDays(-10)

# Current date and time
$CurrentDate = Get-Date

# Validate date range
if ($CreationEnd -le $CreationStart) {
    Write-Error "Invalid date range. The end date must be after January 1, 2026."
    Read-Host "Press Enter to close"
    exit
}

# Find every file and folder in the root directory and all subdirectories
$Items = @(
    Get-ChildItem -LiteralPath $RootFolder -Force -Recurse
)

# Include the root folder itself
$Items += Get-Item -LiteralPath $RootFolder -Force

# Process folders first, then files
$Items = $Items | Sort-Object {
    if ($_.PSIsContainer) { 0 } else { 1 }
}

foreach ($Item in $Items) {
    try {
        # Generate random creation date and time
        $CreationRangeTicks = [long](
            $CreationEnd.Ticks - $CreationStart.Ticks
        )

        $RandomCreationTicks = Get-Random -Minimum 0 -Maximum $CreationRangeTicks
        $RandomCreationDate = $CreationStart.AddTicks($RandomCreationTicks)

        # Generate random modification date and time
        # Must be between creation date and current date
        $ModificationRangeTicks = [long](
            $CurrentDate.Ticks - $RandomCreationDate.Ticks
        )

        $RandomModificationTicks = Get-Random -Minimum 0 -Maximum $ModificationRangeTicks
        $RandomModificationDate = $RandomCreationDate.AddTicks($RandomModificationTicks)

        # Apply timestamps
        $Item.CreationTime = $RandomCreationDate
        $Item.LastWriteTime = $RandomModificationDate

        Write-Host "Updated: $($Item.FullName)"
        Write-Host "  Created:  $RandomCreationDate"
        Write-Host "  Modified: $RandomModificationDate"
    }
    catch {
        Write-Warning "Failed: $($Item.FullName) - $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Done. Files and folders processed under:"
Write-Host $RootFolder
Write-Host ""
Read-Host "Press Enter to close"
