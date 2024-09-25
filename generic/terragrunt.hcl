terraform {
  source = "../../tf-modules/github" # Points to the directory where your Terraform code is located

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
    bucket                      = "terraform-backend-files-215831533232"
    key                         = "github_module/state_files/${path_relative_to_include()}/terraform.tfstate"
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

  GITHUB_TOKEN  = get_env("GITHUB_TOKEN")
  # AZDO_ORG_SERVICE_URL = get_env("AZDO_ORG_SERVICE_URL")
  # AZDO_PERSONAL_ACCESS_TOKEN = get_env("AZDO_PERSONAL_ACCESS_TOKEN")
  

  projects = {
    "new_domino_project" = {
      custom_repo_name        = "mlops-aws-windoutput"
      custom_repo_description = "Project for e2e mlops using terraform, azure pipelines with wind output prediction"
      add_ruleset = true
    }

  }

}