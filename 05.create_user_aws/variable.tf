variable "region" {
  type        = string
  description = "Region of deployment"
}

variable "access_key" {
  type        = string
  description = "AWS Access Key"
  sensitive   = true
}

variable "secret_key" {
  type        = string
  description = "AWS Secret Key"
  sensitive   = true
}

variable "user_name" {
  type        = string
  description = "Name of the user is to be created"
}

variable "user_path" {
  type        = string
  description = "Path to where the user is to be created"
}

variable "role_name" {
  type        = string
  description = "Name of the role is to be created"
}

variable "role_path" {
  type        = string
  description = "Path to where the role is to be created"
}

variable "policy_name" {
  type        = string
  description = "Name of the policy to be created"
}

variable "action_for_role_allow" {
  type        = list(string)
  description = "All actions to be allowed by role for e.g. : 'ec2:Describe' "
  default     = ["*"]
}

variable "allowing_resources" {
  type        = list(string)
  description = "AWS Secret Key"
  default     = ["*"]

}

variable "action_for_role_deny" {
  type        = list(string)
  description = "All actions to be denied by role for e.g. : 'ec2:Describe' "
  default     = []
}

variable "denying_resources" {
  type        = list(string)
  description = "All actions to be denied by role for e.g. : 'ec2:Describe' "
  default     = []
}

