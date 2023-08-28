variable "repo_name" {
  type    = string
  default = "template_repo"
}

variable "visibility" {
  type    = string
  default = "public"
}

variable "repo_description" {
  type    = string
  default = "Repository created from a public template"
}

variable "template_name" {
  type    = string
  default = "cruddur_aws"
}

variable "owner" {
  type    = string
  default = "sanket-s-thorat"
}

variable "token" {
  type      = string
  sensitive = true
}