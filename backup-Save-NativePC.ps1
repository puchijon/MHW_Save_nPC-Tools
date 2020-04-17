<#
    .SYNOPSIS
    Backup save file & nativePC from MHW. Version 1.0.3

    .DESCRIPTION
    Backup "save" file & "nativePC" from "Monster Hunter World" ; "Iceborne" compatible.
    The script backup files from their original location to a specific folder in OneDrive.

    .PARAMETER InputPath
    None.

    .PARAMETER OutputPath
    None.

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    C:\PS> .\backup-Save-NativePC.ps1

    .LINK
    https://github.com/puchijon/backup-MHW_Save_nPC
#>

# Main variable
$date = Get-Date -Format "yyyyMMdd-HHmm"
$originalSave = Get-ChildItem -Path "C:\Program Files (x86)\Steam\steamapps\common\Monster Hunter World\savedata_backup\SAVEDATA1000"
$originalNativePC = "C:\Program Files (x86)\Steam\steamapps\common\Monster Hunter World\nativePC\"
$originalMHWTools = "C:\Games\MHW\MHW tools\"
$nameBackupSave = $originalSave.Name + "-" + $date
$namenPCSave = "nativePC" + "-" + $date + "\"

# Backup path
$backupModPath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\nativePC\$namenPCSave"
$backupModPathFolder = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\nativePC\"
$backupSavePath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\save\$nameBackupSave"
$backupSavePathFolder = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\save\"
$backupMHWTools = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\MHW tools"

# Log files path
$logSavePath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\saveFile.log"
$logModPath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\nativePC.log"
$logFileMHWTools = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\logs_MHWTools.log"


# Fonction de backup Save

function backupSave {
    try {
        Copy-Item -Path $originalSave -Destination $backupSavePath
        "$date : SUCCESS - Save file from MHW '$originalSave' to '$backupSavePath'" | Out-File $logSavePath -Append
    }
    catch {
        "$date : ERROR while backing up the save '$originalSave' from MHW with following errors :" | Out-File $logSavePath -Append
        "$_.Exception.Message" | Out-File $logSavePath -Append
    }
}

function backupNativePC {
    try {
        Get-ChildItem -Path $originalNativePC | Copy-Item -Destination $backupModPath -Recurse
        "$date : SUCCESS - Backup of mods from MHW '$originalNativePC' to '$backupModPath'" | Out-File $logModPath -Append
    }
    catch {
        "$date : ERROR while backing up the mods '$originalNativePC' from MHW with following errors :" | Out-File $logModPath -Append
        "$_.Exception.Message" | Out-File $logModPath -Append
    }
}

function backupMHWTools {
    if (Test-Path $backupMHWTools) {
        try {
            Remove-Item -Path $backupMHWTools -Recurse -Force
            Copy-Item -Path $originalMHWTools -Recurse -Destination $backupMHWTools
            "$date : SUCCESS - Backup of MHWTools from MHW '$originalMHWTools' to '$backupMHWTools'" | Out-File $logFileMHWTools -Append
        }
        catch {
            "$date : ERROR while backing up the folder MHW from '$originalMHWTools' with following errors :" | Out-File $logFileMHWTools -Append
            "$_.Exception.Message" | Out-File $logFileMHWTools -Append
        }
    }
    else {
        New-Item -Path $backupMHWTools -ItemType Directory
        try {
            Copy-Item -Path $originalMHWTools -Recurse -Destination $backupMHWTools
            "$date : SUCCESS - Backup of MHWTools from MHW '$originalMHWTools' to '$backupMHWTools'" | Out-File $logFileMHWTools -Append
        }
        catch {
            "$date : ERROR while backing up the folder MHW from '$originalMHWTools' with following errors :" | Out-File $logFileMHWTools -Append
            "$_.Exception.Message" | Out-File $logFileMHWTools -Append
        }   
    }

}

function purgeBackup {
    $countSave = (Get-ChildItem -Path $backupSavePathFolder -Recurse).count
    $countNativePC = (Get-ChildItem -Path $backupModPathFolder).count
    
    if ($countSave -ge 5) {
        $saveToPurge = Get-ChildItem $backupSavePathFolder -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddHours((-48)))} | Remove-Item -Recurse -Force
        "$date : SUCCESS - Purge of save '$saveToPurge' from '$backupSavePathFolder'" | Out-File $logSavePath -Append
    }
    
    if ($countNativePC -ge 3) {
        $nPCToPurge = Get-ChildItem $backupModPathFolder | Where-Object {($_.LastWriteTime -lt (Get-Date).AddHours((-36)))} | Remove-Item -Recurse -Force
        "$date : SUCCESS - Purge of mods '$nPCToPurge' from '$backupModPathFolder'" | Out-File $logModPath -Append
    }
}

function startBackup {
    Begin {
        purgeBackup
    }
    Process {
        backupSave
        Start-Sleep -Seconds 5
        backupNativePC
        Start-Sleep -Seconds 10
        backupMHWTools
        Start-Sleep -Seconds 5
    }
    End {
        
        $Header = New-BTHeader -Id 1 -Title "Backup automation done"
        New-BurntToastNotification -Text "Files from MHW are backed up" , "View logs for more info" -Header $Header -AppLogo "C:\Users\puchi\OneDrive\Pictures\Logo\pepeOK.jpg"
        
        exit
    }
}

startBackup
    