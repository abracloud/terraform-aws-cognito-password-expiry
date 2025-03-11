# Terraform AWS Cognito Password Expiry Module

## Overview
This Terraform module creates AWS Lambda functions to enforce Cognito users to update their passwords every **60 days**. It is designed for use with existing Cognito setups managed by other Terraform configurations.

## Features
- Creates **two AWS Lambda functions**:
  1. **Pre-Authentication Lambda**: Checks the `custom:lastpasswordupdate` attribute. If **60+ days have passed**, it prevents login.
  2. **Post-Confirmation Lambda**: Updates `custom:lastpasswordupdate` after a password reset.
- Each Lambda has:
  - A dedicated **IAM role**
  - A dedicated **IAM policy**
  - A **CloudWatch log group** (`/lambda/<lambda-name>`)

## Usage
### Add to your users in Cognito the custom attribute
```custom:lastPasswordUpdate```
The value of the attribute is a number.  
The value is a unixtimestamp number for example: `1738684364`
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
  - Read `custom:lastpasswordupdate`
  - Block login if the timestamp is **older than 60 days**
- The **Post-Confirmation Lambda** should:
  - Update `custom:lastpasswordupdate` to the current Unix timestamp

## Outputs
| Name            | Description |
|----------------|-------------|
| `lambda_arns`  | ARN of the Lambda functions |
| `role_arns`    | ARN of the IAM roles |
| `policy_arns`  | ARN of the IAM policies |
| `log_group_arns` | ARN of the CloudWatch log groups |

## Deployment Instructions
1. Upload your Lambda function ZIP files to an **S3 bucket** or provide local paths.
2. Apply the module:
   ```sh
   terraform init
   terraform apply -auto-approve
   ```
3. Configure **Cognito Triggers** in your existing Cognito Terraform configuration:
   ```hcl
   resource "aws_cognito_user_pool" "example" {
     lambda_config {
       pre_authentication  = module.cognito_password_expiry.lambda_arns["pre-auth-lambda"]
       post_confirmation   = module.cognito_password_expiry.lambda_arns["post-confirm-lambda"]
     }
   }
   ```






## License
MIT License. Feel free to contribute!

