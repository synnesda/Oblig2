variable "name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "location" {
  type        = string
  description = "Azure location for the Resource Group"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to the Resource Group"
  default     = {}
}
