locals {
  function_zip_dest = "${path.module}/function.zip"
  function_src_dir = "${path.module}/../function"
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = local.function_src_dir
  output_path = local.function_zip_dest
}


resource "azurerm_storage_container" "fnapp" {
  name                  = "function"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "fnapp" {
  name = local.function_zip_dest
  storage_account_name = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.fnapp.name
  type = "Block"
  source = local.function_zip_dest
}

data "azurerm_storage_account_blob_container_sas" "this" {
  connection_string = azurerm_storage_account.this.primary_connection_string
  container_name    = azurerm_storage_container.fnapp.name

  https_only = true
  
  start = timestamp()
  expiry = timeadd(timestamp(), "3096h")

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}


resource "azurerm_service_plan" "fnapp" {
  name                = "${var.logic_app_name}-fn-asp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name = "S1"
  os_type = "Linux"
}


resource "azurerm_linux_function_app" "this" {
  name                = "${var.logic_app_name}-function"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  service_plan_id            = azurerm_service_plan.fnapp.id


  app_settings = {
    # "WEBSITE_RUN_FROM_PACKAGE"    = "https://${azurerm_storage_account.this.name}.blob.core.windows.net/${azurerm_storage_container.fnapp.name}/${azurerm_storage_blob.fnapp.name}${data.azurerm_storage_account_blob_container_sas.this.sas}",
    "FUNCTIONS_WORKER_RUNTIME" = "python",
    "AzureWebJobsDisableHomepage" = "true",
  }
  site_config {
  }
}

# data "azurerm_function_app_host_keys" "this" {
#   name                = azurerm_linux_function_app.this.name
#   resource_group_name = azurerm_resource_group.this.name
#   depends_on = [
#     azurerm_linux_function_app.this
#   ]
# }