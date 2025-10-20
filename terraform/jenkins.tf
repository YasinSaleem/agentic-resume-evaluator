# Separate Jenkins infrastructure (optional)
# Move Jenkins server to separate Terraform state for extra safety

# Uncomment and use this if you want complete separation:
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "jenkins/terraform.tfstate"  # Different state file
#     region = "eu-north-1"
#   }
# }