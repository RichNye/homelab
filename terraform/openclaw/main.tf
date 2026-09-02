module "web_vm_dev" {
  source = "../modules/ubuntu_vm"

  vm_name              = "openclaw-01"
  vm_description       = "Openclaw"
  vm_cores             = 2
  vm_memory            = 2048
  vm_tags              = "openclaw"
  proxmox_host         = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"
  ssh_public_key       = var.ssh_public_key
  cloudinit_username   = var.cloudinit_username
  cloudinit_password   = var.cloudinit_password

  vm_disks = [
    {
      slot    = "virtio0"
      size    = "60G"
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

