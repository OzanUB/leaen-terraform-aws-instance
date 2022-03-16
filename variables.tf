variable "public_key" {
  type = string
  default = "deployer-key"
}
variable "key_path"{
  type        = string
  description = "Dir path of private key."
  default     = "~/Oteemo/internal_proj/learn-terraform-aws-instance/secrets/"
}

variable "private_key_name" {
  type        = string
  description = "File path of private key."
  default     = "eg-test-app.pem"
}