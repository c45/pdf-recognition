resource "azurerm_resource_group" "rgroup" {
  name     = "bestrongrgroup"
  location = var.resource_group_location
}


resource "azurerm_storage_account" "saccount" {
  name                     = "bestrongsa"
  resource_group_name      = azurerm_resource_group.rgroup.name
  location                 = azurerm_resource_group.rgroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}


resource "azurerm_storage_container" "scontainer" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.saccount.name
  container_access_type = "private"
}


resource "azurerm_storage_share" "sshare" {
  name                 = "bestrongshare"
  storage_account_name = azurerm_storage_account.saccount.name
  quota                = 50
}


resource "azurerm_storage_share_directory" "sdir" {
  name                 = "documents"
  share_name           = azurerm_storage_share.sshare.name
  storage_account_name = azurerm_storage_account.saccount.name
}


resource "azurerm_service_plan" "splan" {
  name                = "bestrong-service-plan"
  resource_group_name = azurerm_resource_group.rgroup.name
  location            = azurerm_resource_group.rgroup.location
  os_type             = "Linux"
  sku_name            = "Y1"
}


resource "azurerm_linux_function_app" "fapp" {
  name                = "bestrong-linux-function-app"
  resource_group_name = azurerm_resource_group.rgroup.name
  location            = azurerm_resource_group.rgroup.location

  storage_account_name       = azurerm_storage_account.saccount.name
  storage_account_access_key = azurerm_storage_account.saccount.primary_access_key
  service_plan_id            = azurerm_service_plan.splan.id


  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "ENDPOINT"                 = azurerm_cognitive_account.caccount.endpoint
    "KEY"                      = azurerm_cognitive_account.caccount.primary_access_key
    "CONNECTION_STRING"        = azurerm_storage_account.saccount.primary_connection_string
    "SHARE_NAME"               = azurerm_storage_share.sshare.name
    "DIR_PATH"                 = azurerm_storage_share_directory.sdir.name
    "CONTAINER_NAME"           = azurerm_storage_container.scontainer.name
  }

  site_config {}
}


resource "azurerm_cognitive_account" "caccount" {
  name                = "cognitive-account"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name
  kind                = "FormRecognizer"

  sku_name = "S0"
}