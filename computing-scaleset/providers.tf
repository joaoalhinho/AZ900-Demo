terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.95.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "2f2cd6a9-7498-4a87-b968-6be5306f74d9"
  tenant_id       = "451579a9-edca-480d-8ef3-3caafecb7a0e"
  client_id       = "9af1b8dd-c241-4005-ae46-9494f3801dab"
  client_secret   = "4qK8Q~m.As2w6nej6sqQ2U3lgu~oYF6imhuFnbT6"
}