output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.fapp.default_hostname
  description = "Deployed function app hostname"
}

output "sas_url_query_string" {
  value = data.azurerm_storage_account_blob_container_sas.storage_sas.sas
  sensitive = true
}