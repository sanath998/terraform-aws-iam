### IAM ROLE ###

variable "create_role" {
 description = "Set to True to create IAM role (Default: true)"
 type = string
 default = true
}

variable "instance_profile_enabled" {
 description = "Create EC2 Instance Profile for the role (Default: false)"
 type = bool
 default = false
}

variable "managed_policy_arns" {
 description = "List of managed policies to attach to created role"
 type = set(string)
 default = []
}

variable "override_role_name" {
 description = "Set to TRUE to override the role name. By default, 'BURoleFor' is added as a prefix as per https://pages.experian.com/display/SC/Cloud+Naming+Conventions+or+Constructs"
 type = bool
 default = false
}

variable "path" {
 description = "Path to the role and policy. See [IAM Identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html) for more information. (Default: '/')"
 type = string
 default = "/"
}

variable "role_name" {
 description = "Name of the IAM role (mandatory)"
 type = string

 validation {
 condition = length(var.role_name) > 0
 error_message = "The IAM role name is mandatory!"
 }
}

### IAM POLICY ###

variable "assume_role_policy" {
 description = "JSON IAM policy for assume role (mandatory)"
 type = string

 validation {
 condition = length(var.assume_role_policy) > 0
 error_message = "An IAM assume role policy must be present!"
 }
}

variable "max_session_duration" {
 description = "The maximum session duration (in seconds) for the role. Can have a value from 1 hour (3600 seconds) to 12 hours (43200 seconds)"
 type = number
 default = 3600

 validation {
 condition = tobool(var.max_session_duration >= 3600 && var.max_session_duration <= 43200) == true
 error_message = "The value need to be betwee 3600 and 43200"
 }
}

variable "override_policy_name" {
 description = "Set to TRUE to override the policy name. By default, 'BUPolicyFor' is added as a prefix as per https://pages.experian.com/display/SC/Cloud+Naming+Conventions+or+Constructs"
 type = bool
 default = false
}

variable "permissions_boundary" {
 description = "ARN of the policy that is used to set the permissions boundary for the role"
 type = string
 default = ""
}

variable "policy_description" {
 description = "The description of the IAM policy that is visible in the IAM policy manager (required if policy_documents is not empty)"
 type = string
 default = ""
}

variable "policy_documents" {
 description = "List of JSON IAM policy documents"
 type = list(string)
 default = []
}

variable "policy_name" {
 description = "The name of the IAM policy that is visible in the IAM policy manager (required if policy_documents is not empty)"
 type = string
 default = ""
}

variable "role_description" {
 description = "The description of the IAM role that is visible in the IAM role manager"
 type = string
 default = ""
}

# TAGS #

variable "tags" {
 type = map(string)
 default = {}
 description = "Tags for AWS Resources. See https://pages.experian.com/pages/viewpage.action?pageId=400041906 for all available tags. 'CostString', 'AppID' and 'Environment' are required"

}

variable "disable_org_check" {
 type = bool
 default = false
 description = "Set this to true to disable the Deny permission in the trust policy which stops services from outside the Experian Organization from assuming the role"
}