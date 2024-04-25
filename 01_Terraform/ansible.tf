########### Ansible Controller ###########

# NIC erstellen - Ansible Controller
resource "azurerm_network_interface" "NIC_ansible-controller" {
  # name = "nic-msrv01"
  name = "${var.azure_ansible-controller}-nic"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location

  ip_configuration {
    name = "Default"
    subnet_id = azurerm_subnet.SUBNET_VNET-DomainController.id
    private_ip_address_allocation = "Static"
    private_ip_address = "172.16.3.221"
  }
}

# Virtuelle Maschine erstellen - Ansible Controller
resource "azurerm_linux_virtual_machine" "VM_ansible-controller" {
  name = "${var.azure_ansible-controller}-vm-linux"
  computer_name = "${var.azure_ansible-controller}"
  resource_group_name = data.azurerm_resource_group.RG.name
  location = data.azurerm_resource_group.RG.location
  size = "Standard_B2s"
  
  admin_username = var.ansible_user
  admin_password = var.ansible_password
  disable_password_authentication = false

  # im Verzeichnis "Scripts" müssen die Datein cloudinit.yml und inventory.yml liegen
  # cloudinit.yml installiert Ansible nach dem Start der virtuellen Maschine
  # inventory.yml definiert die Infrastruktur die konfiguriert wird
  custom_data = filebase64("scripts/cloudinit.yml")
  user_data = filebase64("scripts/inventory.yml")

  network_interface_ids = [azurerm_network_interface.NIC_ansible-controller.id,]

  source_image_reference {
    # https://discourse.ubuntu.com/t/find-ubuntu-images-on-azure/34259/1

    publisher = "Canonical"

    # Ubunut Server 23.10
    offer = "0001-com-ubuntu-server-mantic"
    sku = "23_10-gen2"
    version = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
    name = "${var.azure_ansible-controller}-OsDisk"
  }

  # Meta Tag
  tags = {
    owner = "Meta Tag Terraform"
  }
}