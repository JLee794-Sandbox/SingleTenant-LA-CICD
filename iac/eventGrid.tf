data "azurerm_client_config" "current" {}

resource "azurerm_eventgrid_topic" "this" {
  name                = "${var.logic_app_name}-topic"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  
  public_network_access_enabled = true
}


# Assign permissions to the logic app managed identity
resource "azurerm_role_assignment" "event_grid_contrib" {
  scope              = azurerm_eventgrid_topic.this.id
  role_definition_name = "EventGrid Contributor"
  principal_id       = azurerm_logic_app_standard.this.identity.0.principal_id
}

resource "azapi_resource" "eventgrid_connection" {
  type = "Microsoft.Web/connections@2016-06-01"

  schema_validation_enabled = false

  name = "azureEventGridPublish"
  parent_id = azurerm_resource_group.this.id
  body = jsonencode({
    kind: "V2"
    location: azurerm_resource_group.this.location
    properties: {
      displayName: "${var.logic_app_name} - Event Grid Connection",
      parameterValues: {
        endpoint = azurerm_eventgrid_topic.this.endpoint
        api_key = azurerm_eventgrid_topic.this.primary_access_key
      }
      api: {
        name: "${var.logic_app_name}-mapi",
        displayName: "${var.logic_app_name} - Event Grid Managed API",
        id: "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Web/locations/${var.location}/managedApis/azureEventGridPublish"
        type: "Microsoft.Web/locations/managedApis"
      }
    }
  })
  response_export_values = ["properties.connectionRuntimeUrl", "properties.api.id"]
}

resource "azapi_resource" "eventgrid_connection_access_policy" {
  type = "Microsoft.Web/connections/accessPolicies@2016-06-01"

  schema_validation_enabled = false

  name = "azureEventGridPublish-MSI-AccessPolicy"
  parent_id =azapi_resource.eventgrid_connection.id

  body = jsonencode({
    properties: {
      principal: {
         type: "ActiveDirectory",
         identity: {
            objectId: azurerm_logic_app_standard.this.identity.0.principal_id,
            tenantId: data.azurerm_client_config.current.tenant_id
         }
      }
    }
  })
}