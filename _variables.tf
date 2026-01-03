variable "name" {
  description = "The name of the secret"
  type        = string
}

variable "description" {
  description = "The description of the secret to show inside of AWS console"
  type        = string
  default     = ""
}

variable "recovery_window_in_days" {
  description = "The window before the secret is deleted"
  type        = number
  default     = 7 # default is to allow restoring deleted secrets for 7 days before they are lost

  validation {
    condition     = var.recovery_window_in_days >= 7 && var.recovery_window_in_days <= 30
    error_message = "recovery_window_in_days must be between 7 and 30."
  }
}

variable "policy" {
  description = "The policy to apply in addition to the management of the secrets which is done by this module"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "The Key to secure the secrets (optional - uses AWS managed key if not provided)"
  type        = string
  default     = null
}

variable "infrastructure_role_name" {
  description = "The name of the IAM role that can manage secrets (used in resource policy)"
  type        = string
  default     = "InfrastructureDeployer"
}