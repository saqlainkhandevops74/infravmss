variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "vnet_name"           { type = string }
variable "vnet_address_space"  { type = list(string) }

variable "subnet_config" {
  type        = map(string)
  description = "Map of subnet names to address prefixes"
}