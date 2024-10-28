resource "azurerm_virtual_network" "tmp-vn" {
  name                = "template-vn"
  location            = azurerm_resource_group.tmp-rg.location
  resource_group_name = azurerm_resource_group.tmp-rg.name
  address_space       = ["10.10.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "tmp-subnet" {
  name                 = "tmp-subnet"
  resource_group_name  = azurerm_resource_group.tmp-rg.name
  virtual_network_name = azurerm_virtual_network.tmp-vn.name
  address_prefixes     = ["10.10.1.0/24"]


}

resource "azurerm_network_security_rule" "tmp-rule" {
  name                        = "tmp-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tmp-rg.name
  network_security_group_name = azurerm_network_security_group.tmp-sg.name
}

resource "azurerm_subnet_network_security_group_association" "tmp-sga" {
  subnet_id                 = azurerm_subnet.tmp-subnet.id
  network_security_group_id = azurerm_network_security_group.tmp-sg.id
}


resource "azurerm_public_ip" "tmp-ip" {
  name                = "tmp-ip"
  resource_group_name = azurerm_resource_group.tmp-rg.name
  location            = azurerm_resource_group.tmp-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "tmp-nic" {
  name                = "tmp-nic"
  location            = azurerm_resource_group.tmp-rg.location
  resource_group_name = azurerm_resource_group.tmp-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tmp-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tmp-ip.id
  }

  tags = {
    environment = "dev"
  }
}