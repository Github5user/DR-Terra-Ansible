########## SERVER ###########

# NIC erstellen - Verzeichnisdienstserver (Domain Controller)
resource "azurerm_network_interface" "NIC_dc_server01" {
  # name = "DC01-nic"
  name = "${var.azure_dc_server01}-nic"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  # dns_servers = ["172.16.3.100", "8.8.8.8"]

  ip_configuration {
    name = "Default"
    subnet_id = azurerm_subnet.SUBNET_VNET-DomainController.id
    private_ip_address_allocation = "Static"
    private_ip_address = "172.16.3.100"
  }

  # Meta Tag
  tags = {
  owner = "Meta Tag Terraform"
  }
}


# Virtuelle Maschine erstellen - Domain Controller
resource "azurerm_windows_virtual_machine" "VM_dc_server01" {
  name = "${var.azure_dc_server01}-vm-w22srv"
  computer_name = "${var.azure_dc_server01}"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  size = "Standard_B2s"

  # admin_username = "adminuser"
  # admin_password = "Password12345!"
  admin_username = var.windows_user
  admin_password = var.windows_password
  network_interface_ids = [azurerm_network_interface.NIC_dc_server01.id,]

  source_image_reference {
    # https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage

    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    name = "${var.azure_dc_server01}-OsDisk"
  }

  # Meta Tag
  tags = {
    owner = "Meta Tag Terraform"
  }
}

resource "azurerm_virtual_machine_extension" "VM_dc_server01_enableWinRM" {
    name = "servers_setup"
    virtual_machine_id = azurerm_windows_virtual_machine.VM_dc_server01.id
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"

    protected_settings = <<SETTINGS
        {
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.setup.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File setup.ps1"
        }
        SETTINGS
}


# NIC erstellen - Zertifikatsserver (PKI / ADCS Server)
resource "azurerm_network_interface" "NIC_pki_server01" {
  # name = "PKI01-nic"
  name = "${var.azure_pki_server01}-nic"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  # dns_servers = ["172.16.3.100", "8.8.8.8"]

  ip_configuration {
    name = "Default"
    subnet_id = azurerm_subnet.SUBNET_VNET-DomainController.id
    private_ip_address_allocation = "Static"
    private_ip_address = "172.16.3.110"
  }

  # Meta Tag
  tags = {
  owner = "Meta Tag Terraform"
  }
}


# Virtuelle Maschine erstellen - Zertifikatsserver (PKI / ADCS Server)
resource "azurerm_windows_virtual_machine" "VM_pki_server01" {
  name = "${var.azure_pki_server01}-vm-w22srv"
  computer_name = "${var.azure_pki_server01}"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  size = "Standard_B2s"

  admin_username = var.windows_user
  admin_password = var.windows_password
  network_interface_ids = [azurerm_network_interface.NIC_pki_server01.id,]

  source_image_reference {
    # https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage

    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    name = "${var.azure_pki_server01}-OsDisk"
  }

  # Meta Tag
  tags = {
    owner = "Meta Tag Terraform"
  }
}

resource "azurerm_virtual_machine_extension" "VM_pki_server01_enableWinRM" {
    name = "servers_setup"
    virtual_machine_id = azurerm_windows_virtual_machine.VM_pki_server01.id
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"

    protected_settings = <<SETTINGS
        {
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.setup.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File setup.ps1"
        }
        SETTINGS
}


# NIC erstellen - Webserver
resource "azurerm_network_interface" "NIC_web_server01" {
  # name = "Web01-nic"
  name = "${var.azure_web_server01}-nic"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  dns_servers = ["172.16.3.100", "8.8.8.8"]

  ip_configuration {
    name = "Default"
    subnet_id = azurerm_subnet.SUBNET_VNET-Web-Server.id
    private_ip_address_allocation = "Static"
    private_ip_address = "172.16.4.100"
  }

  # Meta Tag
  tags = {
    owner = "Meta Tag Terraform"
  }
}


# Virtuelle Maschine erstellen - Web Server
resource "azurerm_windows_virtual_machine" "VM_web_server01" {
  name = "${var.azure_web_server01}-vm-w22srv"
  computer_name = "${var.azure_web_server01}"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  size = "Standard_B2s"

  # admin_username = "adminuser"
  # admin_password = "Password12345!"
    admin_username = var.windows_user
  admin_password = var.windows_password

  network_interface_ids = [azurerm_network_interface.NIC_web_server01.id,]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    name = "${var.azure_web_server01}-OsDisk"
  }
}

resource "azurerm_virtual_machine_extension" "VM_web_server01_enableWinRM" {
    name = "servers_setup"
    virtual_machine_id = azurerm_windows_virtual_machine.VM_web_server01.id
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"

    protected_settings = <<SETTINGS
        {
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.setup.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File setup.ps1"
        }
        SETTINGS
}


# NIC erstellen - Dateiserver (File Server)
resource "azurerm_network_interface" "NIC_file_server01" {
  # name = "File01-nic"
  name = "${var.azure_file_server01}-nic"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  dns_servers = ["172.16.3.100", "8.8.8.8"]

  ip_configuration {
    name = "Default"
    subnet_id = azurerm_subnet.SUBNET_VNET-File-Server.id
    private_ip_address_allocation = "Static"
    private_ip_address = "172.16.5.100"
  }
  
  # Meta Tag
  tags = {
    owner = "Meta Tag Terraform"
  }
}


# Virtuelle Maschine erstellen - Dateiserver (File Server)
resource "azurerm_windows_virtual_machine" "VM_file_server01" {
  name = "${var.azure_file_server01}-w22srv"
  computer_name = "${var.azure_file_server01}"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  size = "Standard_B2s"

  # admin_username = "adminuser"
  # admin_password = "Password12345!"
  admin_username = var.windows_user
  admin_password = var.windows_password

  network_interface_ids = [azurerm_network_interface.NIC_file_server01.id,]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2022-Datacenter"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    name = "${var.azure_file_server01}-w22srv-OsDisk"
  }
}

resource "azurerm_virtual_machine_extension" "VM_file_server01_enableWinRM" {
    name = "servers_setup"
    virtual_machine_id = azurerm_windows_virtual_machine.VM_file_server01.id
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.10"

    protected_settings = <<SETTINGS
        {
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.setup.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File setup.ps1"
        }
        SETTINGS
}