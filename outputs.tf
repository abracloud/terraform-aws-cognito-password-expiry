output "lambda_arns" {
  value = { for k, v in aws_lambda_function.lambda : k => v.arn }
}

output "role_arns" {
  value = { for k, v in aws_iam_role.lambda_role : k => v.arn }
}

output "policy_arns" {
  value = { for k, v in aws_iam_policy.lambda_policy : k => v.arn }
}

output "log_group_arns" {
  value = { for k, v in aws_cloudwatch_log_group.lambda_log_group : k => v.arn }
}
