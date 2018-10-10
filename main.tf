provider "azurerm" {
  version = ">=1.16.0"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_postgresql_server" "server" {
  name                = "${var.server_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  sku {
    name = "${var.sku_name}"
    capacity = "${var.sku_capacity}"
    tier = "${var.sku_tier}"
    family = "${var.sku_family}"
  }

  storage_profile {
    storage_mb = "${var.storage_mb}"
    backup_retention_days = "${var.backup_retention_days}"
    geo_redundant_backup = "${var.geo_redundant_backup}"
  }

  administrator_login = "${var.administrator_login}"
  administrator_login_password = "${var.administrator_password}"
  version = "${var.version}"
  ssl_enforcement = "${var.ssl_enforcement}"
}

resource "azurerm_postgresql_database" "test" {
  count = "${length(var.db_names)}"
  name                = "${var.db_names[count.index]}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_postgresql_server.server.name}"
  charset             = "${var.db_charset}"
  collation           = "${var.db_collation}"
}

resource "azurerm_postgresql_firewall_rule" "test" {
  count = "${length(var.firewall_ranges)}"
  name                = "${var.firewall_prefix}${lookup(var.firewall_ranges[count.index], "name", count.index)}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_postgresql_server.server.name}"
  start_ip_address    = "${lookup(var.firewall_ranges[count.index], "start_ip")}"
  end_ip_address      = "${lookup(var.firewall_ranges[count.index], "end_ip")}"
}

resource "azurerm_postgresql_virtual_network_rule" "test" {
  count = "${length(var.vnet_rules)}"
  name                = "${var.vnet_rule_name_prefix}${lookup(var.vnet_rules[count.index], "name", count.index)}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name         = "${azurerm_postgresql_server.server.name}"
  subnet_id           = "${lookup(var.vnet_rules[count.index], "subnet_id")}"
}