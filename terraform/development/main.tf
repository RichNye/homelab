module "web_vm_dev" {
  source = "../modules/ubuntu_vm"

  vm_name              = "dev-web-01"
  vm_description       = "Development web server"
  vm_cores             = 1
  vm_memory            = 2048
  vm_tags              = "web,dev,loadbalancer,haproxy"
  proxmox_host         = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"
  vm_disks = [
    {
      slot    = "virtio0"
      size    = "32G"
      storage = "data-hdd"
      type    = "disk"
    }
  ]
  vm_networks = [
    {
      id     = "0"
      model  = "virtio"
      bridge = "vmbr0"
    }
  ]
}

module "db_vm_dev" {
  source = "../modules/ubuntu_vm"

  vm_name              = "dev-db-01"
  vm_description       = "Development database server"
  vm_cores             = 1
  vm_memory            = 2048
  vm_tags              = "database,dev,postgres"
  proxmox_host         = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"
  vm_disks = [
    {
      slot    = "virtio0"
      size    = "64G"
      storage = "data-hdd"
      type    = "disk"
    }
  ]
  vm_networks = [
    {
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
    }
  ]
}

