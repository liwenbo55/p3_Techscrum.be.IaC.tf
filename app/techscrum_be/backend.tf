# terraform {
#   backend "s3" {
#     bucket         = "p3-crankbit-backend-terraform.statefile"
#     key            = "backend-terraform.l.tfstate"
#     region         = "ap-southeast-2"
#     dynamodb_table = "crankbit-backend-terraform.state-lock-l"
#     profile        = "credentials_p3_crankbit"
#   }
# }

###################################################################################################

terraform {

  backend "s3" {

  }
}