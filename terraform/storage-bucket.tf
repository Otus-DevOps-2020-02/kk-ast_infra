provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.3.1"

  # Имя поменяйте на другое
  name = "storage-bucket-kk-ast"
}

output storage-bucket_url {
  value = module.storage-bucket.url
}
