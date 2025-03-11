# Terraform AWS Lambda Module for Cognito Password Expiry

## Overview
This Terraform module creates AWS Lambda functions to enforce Cognito users to update their passwords every **60 days**. It is designed to integrate with existing Cognito setups.

## Features
- Creates **two AWS Lambda functions**:
  1. **Pre-Authentication Lambda**: Blocks login if the `custom:lastpasswordupdate` attribute is **older than 60 days**.
  2. **Post-Confirmation Lambda**: Updates `custom:lastpasswordupdate` after a password reset.
- Each Lambda has:
  - A **dedicated IAM role** with least-privilege permissions.
  - A **dedicated IAM policy** based on a template.
  - A **CloudWatch log group** (`/lambda/<lambda-name>`) for logging.

## Usage

### **Example Configuration**
```hcl
module "cognito_password_expiry" {
  source = "github.com/your-username/terraform-aws-cognito-password-expiry"

  lambda_functions = [
    { name = "pre-auth-lambda", zip_path = "pre-auth.zip" },
    { name = "post-confirm-lambda", zip_path = "post-confirm.zip" }
  ]
}
```

### **Lambda Code Requirements**
- The **Pre-Authentication Lambda** should:
  - Read `custom:lastpasswordupdate` from Cognito.
  - Block login if **60+ days have passed**.
- The **Post-Confirmation Lambda** should:
  - Update `custom:lastpasswordupdate` to the current timestamp.

## Outputs

| Name             | Description |
|-----------------|-------------|
| `lambda_arns`   | ARN of the Lambda functions |
| `role_arns`     | ARN of the IAM roles |
| `policy_arns`   | ARN of the IAM policies |
| `log_group_arns` | ARN of the CloudWatch log groups |

## Integration with Cognito
To configure **Cognito Triggers**, update your existing Cognito Terraform configuration:

```hcl
resource "aws_cognito_user_pool" "example" {
  lambda_config {
    pre_authentication  = module.cognito_password_expiry.lambda_arns["pre-auth-lambda"]
    post_confirmation   = module.cognito_password_expiry.lambda_arns["post-confirm-lambda"]
  }
}
```

## License
MIT License. Contributions welcome!
