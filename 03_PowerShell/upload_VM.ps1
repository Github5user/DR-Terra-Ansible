# Dieses PowerShell-Skript automatisiert die Einrichtung und Konfiguration
# von Infrastrukturressourcen in Azure zur Vorbereitung der Migration von
# virtuellen Maschinen. Zunächst prüft das Skript die Existenz und erstellt
# bei Bedarf eine Ressourcengruppe, ein virtuelles Netzwerk mit Subnetzen und
# einen Storage Account. Anschließend lädt es VHD-Dateien, die Informationen
# zu virtuellen Maschinen enthalten, aus einem lokalen Pfad in einen Azure
# Blob Storage Container hoch, um sie später zur VM-Erstellung in Azure zu verwenden.


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


# Anmeldung am Azure-Tenant
az login --tenant $tenant


# aktuelle Arbeitsumgebung auf ein bestimmtes Azure-Abonnement (Subscription) setzen
# https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-set
az account set --subscription $subscription


# Ausgabe und Fehler für das Protokoll der Durchlaufzeit unterdrücken
az config set core.display_region_identified=false
az config set core.no_color=true core.only_show_errors=true


# Prüfen, ob die Ressourcengruppe bereits existiert; falls nicht, Ressourcengruppe erstellen
$groupExists = az group exists --name $ressourcegruppe
if ($groupExists -eq 'false') {
    az group create --name $ressourcegruppe --location $location
} else {
}


# Prüfen, ob das virtuelle Netzwerk bereits existiert; falls nicht, erstellen
$vNetExists = az network vnet list --resource-group $ressourcegruppe --query "[?name == '$vNetz'].name" | ConvertFrom-Json
# Erstellung des virtuellen Netzwerks, wenn es noch nicht existiert
if ($vNetExists.Count -eq 0) {
    # Erstellung des virtuellen Netzwerks
    az network vnet create --name $vNetz --resource-group $ressourcegruppe --location $location --address-prefix $addressPrefix
    Write-Host "Virtuelles Netzwerk '$vNetz' wurde in Ressourcengruppe '$ressourcegruppe' und Region '$location' mit dem Adresspräfix '$addressPrefix' erstellt."
} else {
    Write-Host "Virtuelles Netzwerk '$vNetz' existiert bereits in der Ressourcengruppe '$ressourcegruppe'."
}


# Prüfen, ob das Subnetz bereits existiert; falls nicht, erstellen
$subNetExists = az network vnet subnet list --resource-group $ressourcegruppe --vnet-name $vNetz --query "[?name == '$subNetz'].name" | ConvertFrom-Json
# Erstellung des Subnetzes, wenn es noch nicht existiert
if ($subNetExists.Count -eq 0) {
    # Erstellung des Subnetz
    az network vnet subnet create --name $subNetz --resource-group $ressourcegruppe --vnet-name $vNetz --address-prefix $subnetPrefix
    Write-Host "Subnetz '$subNetz' wurde im virtuellen Netzwerk '$vNetz' der Ressourcengruppe '$ressourcegruppe' mit dem Adresspräfix '$subnetPrefix' erstellt."
} else {
    Write-Host "Subnetz '$subNetz' existiert bereits im virtuellen Netzwerk '$vNetz' der Ressourcengruppe '$ressourcegruppe'."
}


# Prüfen, ob der Storage Account bereits existiert; falls nicht, erstellen
$accountCheck = az storage account check-name --name $storageAccountName --query 'nameAvailable' | ConvertFrom-Json
if ($accountCheck -eq $true) {
    # az storage account create --name $storageAccountName --resource-group $ressourcegruppe --location $location --sku Standard_LRS --kind StorageV2 --auth-mode login
    az storage account create --name $storageAccountName --resource-group $ressourcegruppe --location $location --sku Standard_LRS --kind StorageV2
}


# Prüfen, ob der Container bereits existiert; falls nicht, erstellen
$containerExists = az storage container list --account-name $storageAccountName --query "[?name=='$containerName']" --auth-mode login | ConvertFrom-Json
if ($containerExists.Length -eq 0) {
    az storage container create --name $containerName --account-name $storageAccountName --auth-mode login
}


# CSV-Datei importieren
$vmList = Import-Csv -Path $csvPath -Delimiter ';'

# VHD-Datei in den Container des Storage Accounts hochladen
# Für jede Zeile in der CSV-Datei
foreach ($vm in $vmList) {
    # Azure CLI Befehl zum Hochladen der VHD

    # Dateien uploaden
    # https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-upsload
    $azCommand = "az storage blob upload --account-name $storageAccountName --container-name $containerName --name `"$($vm.'VM Name').vhd`" --file `"$($vm.'VHD Path')`" --overwrite"
    Invoke-Expression $azCommand
}