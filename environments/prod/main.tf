terraform {
  required_version = ">= 1.7"
  required_providers {
    azurerm = { source = "hashicorp/azurerm"; version = "~> 3.100" }
    azuread = { source = "hashicorp/azuread"; version = "~> 2.50" }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "prod/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = var.project_name
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-prod"
  location = var.location
  tags     = local.tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "${var.project_name}-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnets = {
    servers = { address_prefix = "10.0.1.0/24" }
    bastion = { address_prefix = "10.0.255.0/27" }
  }
  tags = local.tags
}

module "web_server" {
  source              = "../../modules/vm-windows"
  vm_name             = "vm-web-prod-01"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["servers"]
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  vm_size             = "Standard_D4s_v5"
  windows_sku         = "2022-datacenter-azure-edition"
  tags                = local.tags
}
