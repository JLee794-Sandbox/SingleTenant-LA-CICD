variable "location" {
  description = "(Required) The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Resource Group."
  type        = map(string)
  default     = {}
}


variable "logic_app_name" {
  description = "(Required) Specifies the name of the Logic App."
  type        = string
}

variable "storage_account_name" {
  description = "(Required) Specifies the name of the Storage Account to create."
  type        = string
}

variable "resource_group_name" {
  description = "(Optional) Provide name of Resource Group to create."
  type        = string
  default = ""
}
