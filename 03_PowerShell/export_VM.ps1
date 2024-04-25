# Dieses PowerShell-Skript führt einen Export von virtuellen Maschinen auf einem Windows-System 
# durch und konvertiert deren virtuelle Festplatten von VHDX- in VHD-Format. Zunächst
# erstellt das Skript einen Ordner mit dem aktuellen Datum im angegebenen Pfad, falls
# dieser nicht existiert. Anschließend werden alle verfügbaren virtuellen Maschinen
# exportiert und die zugehörigen VHDX-Dateien in VHD-Dateien umgewandelt. Schließlich
# sammelt das Skript Informationen über die exportierten und umgewandelten Dateien
# in einer CSV-Datei.



$date = Get-Date -Format "yyyyMMdd"
$path = "C:\Export"

# Pfad, in das die virtuellen Maschinen exportiert werden
$exportPath = "$path\$date"

# lokalen Hostnamen erheben
$computerName = $env:COMPUTERNAME
Write-Output "Das Script wird auf den Host $computerName ausgeführt."
Write-Output ""

# sicherstellen, dass das Verzeichnis existiert
if (-not (Test-Path -Path $exportPath)) {
    New-Item -ItemType Directory -Path $exportPath
}

# CSV-Datei vorbereiten
$csvPath = Join-Path -Path $exportPath -ChildPath "VMExportList.csv"
$csvData = @("VM Name;Exported VHDX Path;VHD Path")

# VMs abrufen und exportieren
Get-VM | ForEach-Object {
    $vmName = $_.Name
    $vmExportPath = Join-Path -Path $exportPath -ChildPath $vmName
    
    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Export beginnt"

    Export-VM -VM $_ -Path $vmExportPath

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Export beendet"

    # VHDX-Dateien für diese virtuellen Maschine finden
    $vhdxFiles = Get-ChildItem -Path $vmExportPath -Filter *.vhdx -Recurse

    $vhdxPath = $vhdxFiles.FullName
    $vhdPath = $vhdxPath.Substring(0, $vhdxPath.Length - 1)

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Umwandlung von VHDX in VHD beginnt"

    Convert-VHD -Path $vhdxPath -DestinationPath $vhdPath -VHDType Fixed
    # Convert-VHD -Path "C:\Export\Server01\Virtual Hard Disks\Server01.vhdx" -DestinationPath C:\Export\_VHD\Server01.vhd -VHDType Fixed

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Umwandlung von VHDX in VHD beendet"

    foreach ($vhdxFile in $vhdxFiles) {
        # $vhdxPath = $vhdxFile.FullName
        # Zeile für die CSV-Datei vorbereiten
        $csvLine = "$vmName;$vhdxPath;$vhdPath"
        $csvData += $csvLine
    }
}

# CSV-Datei schreiben
# $csvData | Out-File -FilePath $csvPath -Encoding ASCII
$csvData | Out-File -FilePath $csvPath -Encoding UTF8