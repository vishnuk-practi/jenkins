
resource "azurerm_virtual_network" "myapp" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name
  tags                = var.tags
}

resource "azurerm_subnet" "jenkins" {
  name                 = "jenkins"
  resource_group_name  = azurerm_resource_group.myapp.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.myapp.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes       = ["10.0.1.0/24"]
}




resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = azurerm_resource_group.myapp.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes       = ["10.0.3.0/24"]
}

# NIC and IPs for jenkins Node
resource "azurerm_public_ip" "jenkins" {
  name                = "${var.prefix}-jenkins-pip"
  resource_group_name = azurerm_resource_group.myapp.name
  location            = azurerm_resource_group.myapp.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}


resource "azurerm_network_interface" "jenkins" {
  name                = "${var.prefix}-nic-jenkins"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.jenkins.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins.id
  }
}


# Nic and IP for Jenkins on Centos

resource "azurerm_public_ip" "cenkins" {
  name                = "${var.prefix}-cenkins-pip"
  resource_group_name = azurerm_resource_group.myapp.name
  location            = azurerm_resource_group.myapp.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}


resource "azurerm_network_interface" "cenkins" {
  name                = "${var.prefix}-nic-cenkins"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.jenkins.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.cenkins.id
  }
}


# NIC For Windows 

resource "azurerm_subnet" "win" {
  name                 = "win"
  resource_group_name  = azurerm_resource_group.myapp.name
  virtual_network_name = azurerm_virtual_network.myapp.name
  address_prefixes       = ["10.0.4.0/24"]
}


resource "azurerm_network_interface" "win" {
  count = var.win_node_count
  name                = "${var.prefix}-nic-win-${count.index}"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = azurerm_subnet.win.id
    private_ip_address_allocation = "dynamic"
    
  }
}


# NIC and IPs for db Nodes


resource "azurerm_network_interface" "db" {
  count               = var.db_node_count
  name                = "${var.prefix}-nic-db-${count.index}"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name

  ip_configuration {
    name                          = "configuration-${count.index}"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
  }
}


# NICs for Web servers


resource "azurerm_network_interface" "web" {
  count               = var.web_node_count
  name                = "${var.prefix}-nic-web-${count.index}"
  location            = azurerm_resource_group.myapp.location
  resource_group_name = azurerm_resource_group.myapp.name

  ip_configuration {
    name                          = "configuration-${count.index}"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    
  }
} 