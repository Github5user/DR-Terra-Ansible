# Azure Provider Variables

variable "azure_subscription_id" {
  type = string
  description = "Azure Subscription ID"
  sensitive = true
}

variable "azure_client_id" {
  type = string
  description = "Azure Client ID"
  sensitive = true
}

variable "azure_client_secret" {
  type =  string
  description = "Azure Client Secret"
  sensitive = true
}

variable "azure_tenant_id" {
  type = string
  description = "Azure Tenant ID"
  sensitive = true
}

variable "azure_tenant_location" {
  description = "Der Azure-Standort, an dem alle Ressourcen erstellt werden."
  type        = string
}

variable "windows_user" {
  type =  string
  description = "Benutzernamen der Windows-Rechner"
  sensitive = true
}

variable "windows_password" {
  type =  string
  description = "Kennwort der Windows-Rechner"
  sensitive = true
}

variable "ansible_user" {
  type =  string
  description = "Benutzernamen der Linux Rechner - Ansible Controller"
  sensitive = true
}

variable "ansible_password" {
  type =  string
  description = "Kennwort der Linux Rechner - Ansible Controller"
  sensitive = true
}

variable "azure_dc_server01" {
  description = "Der Name vom DC01 Server"
  type        = string
}

variable "azure_pki_server01" {
  description = "Der Name vom PKI01 Server"
  type        = string
}

variable "azure_web_server01" {
  description = "Der Name vom Web01 Server"
  type        = string
}

variable "azure_file_server01" {
  description = "Der Name vom File01 Server"
  type        = string
}

variable "azure_ansible-controller" {
  description = "Der Name vom Ansible Controller"
  type        = string
}

variable "azure_rds_server01" {
  description = "Der Name vom Terminal Server - RDS01"
  type        = string
}