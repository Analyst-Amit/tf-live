terraform {
  source = "../../tf-modules/aws" # Points to the directory where your Terraform code is located

  after_hook "cleanup_cache" {
    commands     = ["apply"]
    execute      = ["rm", "-rf", ".terragrunt-cache"]
    working_dir  = get_parent_terragrunt_dir()
    run_on_error = false
  }

  after_hook "cleanup_lock" {
    commands     = ["apply"]
    execute      = ["rm", ".terraform.lock.hcl"]
    working_dir  = get_parent_terragrunt_dir()
    run_on_error = false
  }  
}


remote_state {
  backend = "s3"

  config = {
    encrypt                     = true
    bucket                      = "terraform-backend-files-${get_env("AWS_ACCOUNT_ID")}"
    key                         = "aws_module/state_files/${path_relative_to_include()}/terraform.tfstate"
    region                      = "us-east-1"
    dynamodb_table              = "tfstate-lock-v3"
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {

  AWS_ACCOUNT_ID  = get_env("AWS_ACCOUNT_ID")

}

#TODO: Create a bucket in s3 to store data files utilizing the repo name.
#TODO: Create a bucket in S3 to store output files.