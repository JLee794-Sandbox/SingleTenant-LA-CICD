terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
    azurerm = "~> 3.0"
  }

  # TODO - Managed identity implementation once self-hosted agent is ready
  backend "azurerm" {
    resource_group_name  = "bootstrap"
    storage_account_name = "bootstrapsadev"
    container_name       = "tfstate"
    key                  = "nyp-la-demo/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}