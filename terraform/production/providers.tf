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



