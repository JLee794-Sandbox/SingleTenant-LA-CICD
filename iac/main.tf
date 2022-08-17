resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name == "" ? "${var.logic_app_name}-rg" : var.resource_group_name
  location = var.location
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "azurerm_service_plan" "this" {
  name                = "${var.logic_app_name}-asp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name = "WS1"
  os_type = "Windows"
}


# Create a vnet resource + subnets for app service and storage account
# Make storage account private, with restricted network access to target vnet
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_storage_account" "this" {
  name                     = substr(var.storage_account_name, 0, 24)
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  access_tier = "Hot"

  network_rules {
    default_action             = "Deny"
    ip_rules = [chomp(data.http.myip.body)]
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]
  }

}

# Creating logic app standard will create a fileshare on the specified storage account
resource "azurerm_logic_app_standard" "this" {
  name                       = var.logic_app_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  storage_account_share_name = var.logic_app_name

  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    EG_TOPIC_NAME = azurerm_eventgrid_topic.this.name
    FN_CONNECTION_NAME = "azfn-py-dyninputs"
    EG_CONNECTION_NAME = azapi_resource.eventgrid_connection.name
    EG_CONNECTION_RUNTIME_URL = jsondecode(azapi_resource.eventgrid_connection.output).properties.connectionRuntimeUrl
    EG_CONNECTION_ID = azapi_resource.eventgrid_connection.id
    EG_API_ID = jsondecode(azapi_resource.eventgrid_connection.output).properties.api.id
    # WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  site_config {
    
    ip_restriction {

      action = "Allow"
      virtual_network_subnet_id = azurerm_subnet.app.id
    }
  }
}

