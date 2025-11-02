# environments/staging/backend.tf

terraform {
  backend "s3" {
    bucket       = "luralite-staging" # We'll create this manually first
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}