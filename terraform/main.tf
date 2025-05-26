module "ubuntu_vm" {
  source = "./modules/ubuntu_vm"

  vm_name              = "ansible-01"
  vm_description       = "Ansible VM"
  vm_cores             = 2
  vm_memory            = 2048
  vm_tags              = "ansible"
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
