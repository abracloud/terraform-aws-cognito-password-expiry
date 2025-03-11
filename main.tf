resource "aws_iam_role" "lambda_role" {
  for_each = { for idx, lambda in var.lambda_functions : lambda.name => lambda }
  
  name = "${each.value.name}-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  for_each = { for idx, lambda in var.lambda_functions : lambda.name => lambda }
  
  name        = "${each.value.name}-policy"
  description = "IAM policy for ${each.value.name}"
  policy      = templatefile("./policy-template.json", {})
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  for_each = aws_iam_role.lambda_role
  
  role       = each.value.name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

resource "aws_lambda_function" "lambda" {
  for_each = { for idx, lambda in var.lambda_functions : lambda.name => lambda }
  
  function_name    = each.value.name
  role            = aws_iam_role.lambda_role[each.key].arn
  handler         = "index.handler"
  runtime         = "nodejs20.x"
  filename        = each.value.zip_path
  source_code_hash = filebase64sha256(each.value.zip_path)

  depends_on = [aws_iam_role.lambda_role]
  
  logging_config {
    log_format = "Text"
    log_group = aws_cloudwatch_log_group.lambda_log_group[each.key].name
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = aws_lambda_function.lambda
  
  name              = "/lambda/${each.value.function_name}"
  retention_in_days = 7
}

