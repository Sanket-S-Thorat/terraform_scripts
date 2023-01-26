variable "dns_name" {
  description = "the common name for the cert"
  default = "myLink.com"
}

variable "validity" {
  default = 12
}