# Dieses PowerShell-Skript automatisiert die Bereitstellung und Konfiguration
# von virtuellen Maschinen in der Azure Cloud. Zunächst meldet sich das Skript
# am Azure-Tenant an und setzt die Arbeitsumgebung auf ein bestimmtes
# Azure-Abonnement. Danach liest es eine CSV-Datei, die Informationen zu den
# virtuellen Maschinen enthält, erstellt für jede VM eine Managed Disk aus einer
# VHD-Datei in einem Azure Storage Container und konfiguriert die Netzwerkkarten
# für die VMs in einem definierten virtuellen Netzwerk und Subnetz. Schließlich erstellt
# das Skript die virtuellen Maschinen in Azure, wobei es Netzwerkkarten und
# Managed Disks entsprechend zuordnet und konfiguriert.



# Variablen für das Azure-Abonnement (Subscription) definieren
# Hier muss die Azure-Abonnement (Subscription) angepasst werden
$tenant = "23b4    -da63-4fea-95eb-97b44c78147 "
$subscription = "86   f52-b127-4e63-8ed9-5f7b6cae28da"
#
################################################################

$date = Get-Date -Format "yyyyMMdd"

# Pfad, in das die virtuellen Maschinen exportiert werden
$path = "C:\Export"

$csv = "VMExportList.csv"
# $csvPath = "C:\Export\20240329\VMExportList.csv"
$csvPath = "$path\$date\$csv"

# Definition der Ressourcengruppe und des Standortes in Azure
$ressourcegruppe="RG-AzureNetwork"
$location="westeurope“

# Definition der virutelles Netzwerk in Azure
$vNetz = "vnet-azure"
$addressPrefix = "172.16.0.0/16"

# Definition der virutelles Subnetz in Azure
$subNetz = "server"
$subnetPrefix = "172.16.2.0/24"

# Definition der Speicheraccount, Container und Cloud-Ausprägung in Azure
$storageAccountName = "masterstorage001"
$containerName = Get-Date -Format "yyyyMMdd"
$vmHardwareSize = "Standard_B2s"

# lokalen Hostnamen erheben
$computerName = $env:COMPUTERNAME

# Anmeldung am Azure-Tenant
az login --tenant $tenant


# aktuelle Arbeitsumgebung auf ein bestimmtes Azure-Abonnement (Subscription) setzen
# https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-set
az account set --subscription $subscription

Write-Output ""
Write-Output ""
Write-Output ""
Write-Output "Das Script wird auf den Host $computerName ausgeführt."
Write-Output ""

# CSV-Datei importieren
$vmList = Import-Csv -Path $csvPath -Delimiter ';'

# Managed Disk erstellen
# Für jede virtuellen Maschine in der CSV-Datei
foreach ($vm in $vmList) {
    $vmName = $vm.'VM Name'
    $vhdUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$vmName.vhd"
    
    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Managed Disk erstellen - beginnt"

    # Azure CLI Befehl zum Erstellen der Managed Disk
    # $azCommand = "az disk create --resource-group $ressourcegruppe --name $($vmName)-OsDisk --source $vhdUrl --os-type Windows"
    $azCommand = "az disk create --resource-group $ressourcegruppe --name $($vmName)-OsDisk --source $vhdUrl --os-type Windows | Out-Null"

    # Azure CLI Befehl ausführen
    Invoke-Expression $azCommand

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Managed Disk erstellen - beendet"
}


# Netzwerkkarte erstellen
# Für jede VM in der CSV-Datei
foreach ($vm in $vmList) {
    $nicName = "$($vm.'VM Name')-nic"

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Netzwerkkarte erstellen - beginnt"

    # Azure CLI Befehl zum Erstellen der Netzwerkkarte
    # $azCommand = "az network nic create --resource-group $ressourcegruppe --name $nicName --vnet-name $vNetz --subnet $subNetz --location $location"
    $azCommand = "az network nic create --resource-group $ressourcegruppe --name $nicName --vnet-name $vNetz --subnet $subNetz --location $location | Out-Null"

    # Azure CLI Befehl ausführen
    Invoke-Expression $azCommand

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - Netzwerkkarte erstellen - beendet"
}


# az config set core.display_region_identified=false
# az config set core.no_color=true core.only_show_errors=true


# virtuelle Maschine erstellen
# Für jede VM in der CSV-Datei
foreach ($vm in $vmList) {
    $serverName = $vm.'VM Name'
    $vmName = $vm.'VM Name'
    $nicName = "$($vm.'VM Name')-nic"
    $OsDiskName = "$($vmName)-OsDisk"

    # Azure CLI Befehl zum Erstellen der virtuelle Maschine
    # $azCommand = "az vm create --resource-group $ressourcegruppe --location $location --name $serverName --nics $nicName --attach-os-disk $OsDiskName --size $vmHardwareSize --os-type Windows"
    $azCommand = "az vm create --resource-group $ressourcegruppe --location $location --name $serverName --nics $nicName --attach-os-disk $OsDiskName --size $vmHardwareSize --os-type Windows | Out-Null"

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - virtuelle Maschine erstellen - beginnt"

    # Azure CLI Befehl ausführen
    Invoke-Expression $azCommand

    Write-Output "$(Get-Date -Format 'dd.MM.yyyy')`t$(Get-Date -Format 'HH:mm:ss') - $vmName - virtuelle Maschine erstellen - beendet"
}