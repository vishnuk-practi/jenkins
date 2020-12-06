#Build web nodes

#Fetch the Cloudinit (userdate) file

data "template_file" "web" {
  template = file("${path.module}/Templates/cloudnint-web.tpl")
}

resource "azurerm_virtual_machine" "web" {
  count                 = var.web_node_count
  name                  = "${var.prefix}-web-${count.index}"
  location              = azurerm_resource_group.myapp.location
  resource_group_name   = azurerm_resource_group.myapp.name
  network_interface_ids = [element(azurerm_network_interface.web.*.id, count.index)]
  vm_size               = var.web_vm_size
  depends_on            = [azurerm_virtual_machine.jenkins]
  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-web-${count.index}-web-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-web-${count.index}"
    admin_username = var.username
    custom_data    = data.template_file.web.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = data.template_file.key_data.rendered
      path     = var.destination_ssh_key_path
    }
  }


}

