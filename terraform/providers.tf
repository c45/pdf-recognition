terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "bestrongtfsate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"

    sas_token = "sp=racwdli&st=2023-09-21T08:14:21Z&se=2023-10-21T16:14:21Z&sv=2022-11-02&sr=c&sig=A8KI9IMKhLGDUm28v0zOgFbber8Aa%2BMKJ%2FxOD0KxxW8%3D"
  }

}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}