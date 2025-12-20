module "k3s-control" {
  count  = 1
  source = "../modules/ubuntu_vm"

  vm_name              = "k3s-control-0${count.index + 1}"
  vm_description       = "k3s control plane"
  vm_cores             = 1
  vm_memory            = 2048
  vm_tags              = "k3s,control-plane"
  proxmox_host         = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"
  ssh_public_key       = var.ssh_public_key
  cloudinit_username   = var.cloudinit_username
  cloudinit_password   = var.cloudinit_password

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

module "k3s-worker" {
  count  = 2
  source = "../modules/ubuntu_vm"

  vm_name              = "k3s-worker-0${count.index + 1}"
  vm_description       = "k3s worker node"
  vm_cores             = 1
  vm_memory            = 2048
  vm_tags              = "k3s,worker-node"
  proxmox_host         = "RN-PROXMOX01"
  ubuntu_template_name = "ubuntu-2404-cloudinit-template"
  ssh_public_key       = var.ssh_public_key
  cloudinit_username   = var.cloudinit_username
  cloudinit_password   = var.cloudinit_password

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