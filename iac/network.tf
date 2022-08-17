resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.logic_app_name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "storage-snet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "appsvc-snet"
    address_prefix = "10.0.2.0/24"
  }
}

