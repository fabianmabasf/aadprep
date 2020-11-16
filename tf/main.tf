locals {
  resource_group_name = "${var.name_prefix}rg"
  cluster_name = "${var.name_prefix}aks"
  cluster_dns_prefix = "${var.name_prefix}aks"
}

resource "azurerm_resource_group" "aks_rg" {
  name     = local.resource_group_name
  location = var.location
}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  version_prefix = "1.18"
}

resource "azurerm_kubernetes_cluster" "aks_simple" {
  name                = local.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = local.cluster_dns_prefix
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name            = "default"
    node_count      = var.agent_count
    vm_size         = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}