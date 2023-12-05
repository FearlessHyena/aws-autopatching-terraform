variable "project" {
  description = "The Project name to use for naming and tagging the resources"
}

variable "region" {
  description = "The default region to deploy to"
}

variable "profile" {
  description = "The AWS profile to use for deployment"
}
variable "public_key" {
  description = "The public SSH key to use for the EC2 instance keypair"
}

