# output "properties_connectionRuntimeUrl" {
#   value = jsondecode(azapi_resource.eventgrid_connection.output).properties.connectionRuntimeUrl
# }

output "name" {
  value = azurerm_logic_app_standard.this.name
}

output "resource_group_name" {
  value = azurerm_logic_app_standard.this.resource_group_name
}

output "azapi_resource_eg_conn" {
  value = jsondecode(azapi_resource.eventgrid_connection.output)
}