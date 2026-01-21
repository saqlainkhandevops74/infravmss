variable "resource_group_name" {}
variable "location"            {}
variable "vmss_name"           {}
variable "sku"                { default = "Standard_B2s" }
variable "instance_count"     { default = 2 }
variable "subnet_id"          {}
variable "ssh_public_key"     {}
variable "app_gateway_backend_pool_ids" {
  type    = list(string)
  default = null # Backend VMSS ke liye ye khali rahega
}

variable "log_analytics_id" {
  type        = string
  description = "ID of the Log Analytics Workspace"
}