module "ansible_vm" {
  source = "../modules/ubuntu_vm"

  vm_name              = "ansible-01"
  vm_description       = "Ansible VM"
  vm_cores             = 2
  vm_memory            = 2048
  vm_tags              = "ansible,prod"
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

module "web_vm" {
  source = "../modules/ubuntu_vm"

  vm_name              = "web-01"
  vm_description       = "Web Server VM"
  vm_cores             = 1
  vm_memory            = 1024
  vm_tags              = "web,prod"
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
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
    }
  ]
}

module "db_vm" {
  source = "../modules/ubuntu_vm"

  vm_name              = "db-01"
  vm_description       = "Database VM"
  vm_cores             = 1
  vm_memory            = 2048
  vm_tags              = "database,prod"
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

module "lb_vm" {
  source = "../modules/ubuntu_vm"
  count = 1
  vm_name              = "lb-01"
  vm_description       = "Load Balancer VM"
  vm_cores             = 1
  vm_memory            = 1024
  vm_tags              = "loadbalancer,haproxy,prod"
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
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
    }
  ]
}

module "monitor_vm" {
  source = "../modules/ubuntu_vm"

  vm_name = "monitor-01"
  vm_description = "Monitoring VM"
  vm_cores = 1
  vm_memory = 1024
  vm_tags = "monitoring,prometheus,grafana"
  proxmox_host = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"

  vm_disks = [
    {
      slot = "virtio0"
      size = "32G"
      storage = "data-hdd"
      type = "disk"
    }
  ]
  vm_networks = [
    {
      id = 0
      model = "virtio"
      bridge = "vmbr0"
    }
  ]
}
