output "function_app_default_hostname" {
  value       = azurerm_linux_function_app.fapp.default_hostname
  description = "Deployed function app hostname"
}
