terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.11" # or whatever version you're using
    }
  }
}

# Module for creating a VM from an ubuntu template in Proxmox with cloud-init support.
resource "proxmox_vm_qemu" "ubuntu_vm" {
  name = var.vm_name
  desc = var.vm_description

  target_node = var.proxmox_host
  clone       = var.ubuntu_template_name
  full_clone  = true
  agent       = 1
  sockets     = 1
  cores       = var.vm_cores
  memory      = var.vm_memory
  scsihw      = "virtio-scsi-pci"
  tags        = var.vm_tags
  boot        = "order=virtio0"
  hotplug     = "disk,network,usb"
  bios        = "ovmf"
  machine     = "q35"

  # cloud-init settings
  ciuser     = "ubuntu"
  cipassword = "ubuntu"
  ciupgrade  = true
  cicustom   = "vendor=local:snippets/vendor.yaml"
  ipconfig0  = "ip=dhcp"
  skip_ipv6  = true
  nameserver = "1.1.1.1 8.8.8.8"
  sshkeys    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq5mZytr/zD0k7QLondl73NZb6J0f1Bds0vDuvMGP9XMOtfu7/pFJ8BxKG6onQPNkkZoRWZHEhCFD9JD3mUu8U4x0No+KNTTtfW6eYT1WbKuZe5H0VZYYWmVPIWJ+R04xSVSeaddtkDLdayYclWM4eG6lToZlvv3APzkoXdPZyf/iLw31LdrTRqUAvgJxgiTuhY1t/xaH2HvH22QurODypM6SX9+EBXRr2EQQD4kJgys/j0CW1X8WF1vKx+wuRxgmb2Cl+88eA02q84rkzdaMGAGWcr9+f0qulfxptMQWw5Krci3rKfKev7qj/zBb2cFm7WOR7tUfETG+1sUv930Nz ubuntu"

  serial {
    id = 0
  }

  dynamic "disk" {
    for_each = var.vm_disks
    content {
      slot    = disk.value.slot
      size    = disk.value.size
      storage = disk.value.storage
      type    = disk.value.type
    }
  }

  # disk outside of the loop to ensure cloudinit always exists where the template needs it.
  disk {
    slot    = "scsi1"
    storage = "data-hdd"
    type    = "cloudinit"
  }

  dynamic "network" {
    for_each = var.vm_networks
    content {
      id     = network.value.id
      model  = network.value.model
      bridge = network.value.bridge
    }
  }
}
