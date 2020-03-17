########################################################
# Backup save file & nativePC                          #
# Author : puchijon                                    #
# Version : 0.1                                        #
########################################################

# Main variable
$date = Get-Date -Format "yyyyMMdd-HHmm"
$originalSave = Get-ChildItem -Path "C:\Program Files (x86)\Steam\steamapps\common\Monster Hunter World\savedata_backup\SAVEDATA1000"
$originalNativePC = "C:\Program Files (x86)\Steam\steamapps\common\Monster Hunter World\nativePC\"
$originalMHWTools = "C:\Games\MHW tools\"
$nameBackup = $originalSave.Name + "-" + $date

# Backup path
$backupModPath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\nativePC\nativePC-$date\"
$backupModPathFolder = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\nativePC\"
$backupSavePath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\save\$nameBackup"
$backupSavePathFolder = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\save\"
$backupMHWTools = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\MHW tools"

# Log files path
$logSavePath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\logs_saveFile.log"
$logModPath = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\nativePC.log"
$logFileMHWTools = "C:\Users\puchi\OneDrive\Documents\_backup\Games\MHW\_logs\logs_MHWTools_$date.log"


# Fonction de backup Save

function backupSave {
    try {
        Copy-Item -Path $originalSave -Destination $backupSavePath
        "$date : SUCCESS - Save file from MHW ""$originalSave"" to ""$backupSavePath""" | Out-File $logSavePath -Append
    }
    catch {
        "$date : ERROR while backing up the save from MHW with following errors :" | Out-File $logSavePath -Append
        "$error[0].exception.gettype().fullname" | Out-File $logSavePath -Append
        "$_.Exception.Message" | Out-File $logSavePath -Append
    }
}

function backupNativePC {
    try {
        Get-ChildItem -Path $originalNativePC | Copy-Item -Destination $backupModPath -Recurse
        "$date : SUCCESS - Backup of mods from MHW ""$originalNativePC"" to ""$backupModPath""" | Out-File $logModPath -Append
    }
    catch {
        "$date : ERROR while backing up the mods from MHW with following errors :" | Out-File $logModPath -Append
        "$error[0].exception.gettype().fullname" | Out-File $logModPath -Append
        "$_.Exception.Message" | Out-File $logModPath -Append
    }
}

function backupMHWTools {
    if (Test-Path $backupMHWTools) {
        try {
            Remove-Item -Path $backupMHWTools -Recurse -Force
            Copy-Item -Path $originalMHWTools -Recurse -Destination $backupMHWTools
            "$date : SUCCESS - Backup of MHWTools from MHW ""$originalMHWTools"" to ""$backupMHWTools""" | Out-File $logFileMHWTools -Append
        }
        catch {
            "$date : ERROR while backing up the folder MHW from $originalMHWTools with following errors :" | Out-File $logFileMHWTools -Append
            "$error[0].exception.gettype().fullname" | Out-File $logFileMHWTools -Append
            "$_.Exception.Message" | Out-File $logFileMHWTools -Append
        }
    }
    else {
        New-Item -Path $backupMHWTools -ItemType Directory
        try {
            Copy-Item -Path $originalMHWTools -Recurse -Destination $backupMHWTools
            "$date : SUCCESS - Backup of MHWTools from MHW ""$originalMHWTools"" to ""$backupMHWTools""" | Out-File $logFileMHWTools -Append
        }
        catch {
            "$date : ERROR while backing up the folder MHW from $originalMHWTools with following errors :" | Out-File $logFileMHWTools -Append
            "$error[0].exception.gettype().fullname" | Out-File $logFileMHWTools -Append
            "$_.Exception.Message" | Out-File $logFileMHWTools -Append
        }   
    }

}

function purge {
    $countSave = (Get-ChildItem -Path $backupSavePathFolder -Recurse).count
    if ($countSave -ge 5) {
        $global:purgeSaveName = Get-ChildItem $backupSavePathFolder -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddHours((-41)))} | Remove-Item -Recurse -Force
    }
    $countNativePC = (Get-ChildItem -Path $backupModPathFolder).count
    if ($countNativePC -ge 3) {
        $global:purgeModName = Get-ChildItem $backupModPathFolder | Where-Object {($_.LastWriteTime -lt (Get-Date).AddHours((-45)))} | Remove-Item -Recurse -Force
    }
}

try {
    purge
        "$date : SUCCESS - Purge of mods from ""$backupModPathFolder""" | Out-File $logModPath -Append
        "$date : INFO - $purgeModName from ""$backupModPathFolder""" | Out-File $logModPath -Append
        "$date : SUCCESS - Purge of save from ""$backupSavePathFolder""" | Out-File $logSavePath -Append
        "$date : INFO - $purgeSaveName from ""$backupSavePathFolder""" | Out-File $logSavePath -Append
    }
    catch {
    }

backupSave
backupNativePC
backupMHWTools

exit
    