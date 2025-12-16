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
  full_clone  = var.full_clone
  agent       = var.qemu_agent
  sockets     = var.sockets
  cores       = var.vm_cores
  memory      = var.vm_memory
  scsihw      = var.scsihw
  tags        = var.vm_tags
  boot        = var.boot_order
  hotplug     = var.hotplug
  bios        = var.bios_type # not hardcoded because I value experimentation here
  machine     = var.machine_type # same rationale as BIOS.

  # cloud-init settings
  ciuser     = var.cloudinit_username
  cipassword = var.cloudinit_password
  ciupgrade  = var.ciupgrade
  cicustom   = var.cicustom_string
  ipconfig0  = var.ci_ipconfig0
  skip_ipv6  = var.skip_ipv6
  nameserver = var.cloudinit_nameservers
  sshkeys    = var.ssh_public_key

  serial {
    id = var.serial_id
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
    slot    = var.cloudinit_diskconfig.slot
    storage = var.cloudinit_diskconfig.storage
    type    = var.cloudinit_diskconfig.type
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
