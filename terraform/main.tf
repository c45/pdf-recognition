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
}


resource "azurerm_storage_container" "scontainer" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.saccount.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = "jsondata"
  storage_account_name   = azurerm_storage_account.saccount.name
  storage_container_name = azurerm_storage_container.scontainer.name
  type                   = "Block"

}

data "azurerm_storage_account_blob_container_sas" "storage_sas" {
  connection_string = azurerm_storage_account.saccount.primary_blob_connection_string
  container_name    = azurerm_storage_container.scontainer.name

  https_only = false

  start  = "2023-09-21"
  expiry = "2018-10-21"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

resource "azurerm_storage_share" "sshare" {
  name                 = "bestrongshare"
  storage_account_name = azurerm_storage_account.saccount.name
  quota                = 50
}

resource "azurerm_storage_share_file" "sfile" {
  name             = "pdf"
  storage_share_id = azurerm_storage_share.sshare.id
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
    "WEBSITE_RUN_FROM_PACKAGE" = ""
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "ENDPOINT"                 = azurerm_cognitive_account.caccount.endpoint
    "KEY"                      = azurerm_cognitive_account.caccount.primary_access_key
  }

  site_config {
    # linux_fx_version = "python|3.10"
  }
}

resource "azurerm_cognitive_account" "caccount" {
  name                = "cognitive-account"
  location            = azurerm_resource_group.rgroup.location
  resource_group_name = azurerm_resource_group.rgroup.name
  kind                = "FormRecognizer"

  sku_name = "S0"
}