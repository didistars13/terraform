module "dev" {
  for_each = toset(local.environments)
  source   = "git::https://github.com/didistars13/terraform.git//modules/aws/workload?ref=${var.module_version}"
  env      = each.key
}
