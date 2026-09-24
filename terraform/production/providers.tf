terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc8"
    }
  }
}

provider "proxmox" {
    pm_api_url = "https://192.168.178.50:8006/api2/json"
    pm_tls_insecure = true
}

backend "s3" {
  bucket = "homelab-tfstate"
  key = "/homelab/production.tfstate"
  region = "auto"

  # leverage AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env variables for secure auth

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_s3_checksum            = true
  use_path_style              = true

  endpoints = { s3 = "https://0d8b44a2f39e8ada9add507a23f368ea.r2.cloudflarestorage.com" }  
}


