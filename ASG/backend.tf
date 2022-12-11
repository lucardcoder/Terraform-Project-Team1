terraform {
  backend "s3" {
    bucket         = "tfstate-****"          #your bucket name. ex : tfstate-{account_id}
    dynamodb_table = "tfstate-team1"           #your dynamodb table name
    key            = "tfstate-team1/dev/ASG" 
    region         = "us-east-1"
    encrypt        = true
  }
}

