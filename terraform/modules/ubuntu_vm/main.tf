terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc10" # or whatever version you're using
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
  bios        = var.bios_type
  machine     = var.machine_type
  vm_state = "running"
  
  startup_shutdown {
    order = -1
    shutdown_timeout = -1
    startup_delay = -1
  }

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

  # must be declared before the cloudinit disk to stop apply commands
  # attempting to swap them.
  dynamic "disk" {
    for_each = var.vm_disks
    content {
      format  = "raw"
      slot    = disk.value.slot
      size    = disk.value.size
      storage = disk.value.storage
      type    = disk.value.type
    }
  }

  # create the data disks first, then add cloudinit to next available scsi slot.
  # fixes an issue where 'terraform apply' commands tried to always swap the data/ci disks.
  disk {
    slot    = "scsi${length(var.vm_disks)}"
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
