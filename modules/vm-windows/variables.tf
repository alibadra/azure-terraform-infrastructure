variable "vm_name"             { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "subnet_id"           { type = string }
variable "admin_username"      { type = string }
variable "admin_password"      { type = string; sensitive = true }
variable "vm_size"             { type = string; default = "Standard_D2s_v5" }
variable "os_disk_size_gb"     { type = number; default = 128 }
variable "windows_sku"         { type = string; default = "2022-datacenter-azure-edition" }
variable "hotpatching_enabled" { type = bool;   default = false }
variable "timezone"            { type = string; default = "Romance Standard Time" }
variable "auto_shutdown_time"  { type = string; default = "" }
variable "domain_name"         { type = string; default = "" }
variable "domain_ou_path"      { type = string; default = "" }
variable "domain_join_user"    { type = string; default = "" }
variable "domain_join_password"{ type = string; default = ""; sensitive = true }
variable "tags"                { type = map(string); default = {} }
