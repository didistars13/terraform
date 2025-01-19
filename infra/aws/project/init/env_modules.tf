module "workloads" {
  for_each = toset(local.environments)
  source   = "git::https://github.com/didistars13/terraform.git//modules/aws/workload?ref=v1.0.1"
  env      = each.key
}
