variable "lambda_functions" {
  description = "List of Lambda function names and their respective ZIP file paths."
  type = list(object({
    name      = string
    zip_path  = string
  }))
}