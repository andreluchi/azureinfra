provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "West US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "my-app-service-plan"
  location            = "West US"
  resource_group_name = azurerm_resource_group.example.name
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "my-application-insights"
  location            = "West US"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_function_app" "example" {
  name                      = "my-function-app"
  location                  = "West US"
  resource_group_name       = azurerm_resource_group.example.name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  runtime                   = "dotnet-isolated"
  os_type                   = "windows" # Or "linux" based on your needs
  version                   = "~3"
  dynamic "identity" {
    type = "SystemAssigned"
  }
  
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
  }
}

resource "azurerm_key_vault" "example" {
  name                        = "my-key-vault"
  location                    = "West US"
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
}

resource "azurerm_sql_server" "example" {
  name                         = "my-sql-server"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = "adminlogin"
  administrator_login_password = "password"
}

output "function_app_endpoint" {
  value = azurerm_function_app.example.default_hostname
}

# Azure DevOps pipeline steps
steps:
- script: |
    terraform init
    terraform plan
    terraform apply -auto-approve
  displayName: 'Run Terraform'
