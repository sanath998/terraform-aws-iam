# Create tracking tags from EITS vars module
module "eits_vars" {
 source = ""

 module_repo = "eits-tf-aws-iam"
 tags = var.tags
}

locals {
 # Merge tracking tags and var tags
 tags = merge(var.tags, module.eits_vars.tags)

 # List of Experian PrincipalOrgIDs
 principal_org_ids = [
 "o-33fd8d019b",
 "o-m6fjxrdr7x",
 "o-c7zjgfu8y0",
 "o-yfj05rswby",
 "o-m5tvfoa2j3",
 "o-v4zenr53b5",
 "o-r4orxccey7",
 "o-72fonqzrib",
 "o-rhlgy4h75h",
 "o-sg7wkai3ne",
 "o-mw9tjv7zmd",
 "o-8jhc22ry8c",
 "o-khqbuhx1kx",
 "o-mtyumpp7ml"
 ]
}

data "aws_iam_policy_document" "assume_role_policy" {
 source_policy_documents = [var.assume_role_policy]
 statement {
 sid = "DenyNonProjectAccountAccess"
 effect = "Deny"
 actions = ["sts:AssumeRole"]
 principals {
 type = "AWS"
 identifiers = ["*"]
 }
 condition {
 test = "StringNotEquals"
 variable = "aws:PrincipalOrgID"
 values = local.principal_org_ids
 }
 condition {
 test = "Bool"
 variable = "aws:PrincipalIsAWSService"
 values = ["false"]
 }
 }
}

# IAM role
resource "aws_iam_role" "default" {
 count = var.create_role ? 1 : 0
 name = var.override_role_name ? var.role_name : "BURoleFor${var.role_name}"
 description = var.role_description
 assume_role_policy = var.disable_org_check ? var.assume_role_policy : data.aws_iam_policy_document.assume_role_policy.json
 max_session_duration = var.max_session_duration
 permissions_boundary = var.permissions_boundary
 path = var.path
 tags = merge(local.tags, var.disable_org_check ? {"eitsce:orgcheck" = "disabled"} : {})
}

# IAM Policy document(s)
data "aws_iam_policy_document" "default" {
 count = length(var.policy_documents) > 0 ? 1 : 0
 source_policy_documents = var.policy_documents
}

# IAM Policy
resource "aws_iam_policy" "default" {
 count = length(var.policy_documents) > 0 ? 1 : 0
 name = var.override_policy_name ? var.policy_name : "BUPolicyFor${var.policy_name}"
 description = var.policy_description
 policy = data.aws_iam_policy_document.default[0].json
 path = var.path
 tags = local.tags
}

# IAM Policy attachment to new role for newly created policy
resource "aws_iam_role_policy_attachment" "default" {
 count = length(var.policy_documents) > 0 && var.create_role ? 1 : 0
 role = aws_iam_role.default[0].name
 policy_arn = aws_iam_policy.default[0].arn
}

# IAM Policy attachment for existing policies
resource "aws_iam_role_policy_attachment" "managed" {
 for_each = var.create_role ? var.managed_policy_arns : []
 role = aws_iam_role.default[0].name
 policy_arn = each.key
}

# IAM Instance Profile role
resource "aws_iam_instance_profile" "default" {
 count = var.instance_profile_enabled ? 1 : 0
 name = var.override_role_name ? var.role_name : "BURoleFor${var.role_name}"
 role = aws_iam_role.default[0].name
}