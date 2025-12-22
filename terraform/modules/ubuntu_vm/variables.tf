variable "proxmox_host" {
  description = "proxmox host for the VM"
  type        = string
  default     = "RN-PROXMOX01"
}

variable "ubuntu_template_name" {
  description = "Ubuntu template"
  type        = string
  default     = "ubuntu-2404-cloudinit-template"
}

variable "vm_cores" {
  description = "Number of cores for the VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory for the VM in MB"
  type        = number
  default     = 2048
}

variable "vm_tags" {
  description = "Tags for the VM"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "ansible-01"
}

variable "vm_description" {
  description = "Description of the VM"
  type        = string
  default     = "Ansible VM"
}

variable "vm_disks" {
  description = "Disks for the VM"
  type = list(object({
    slot    = string
    size    = string
    storage = string
    type    = string
  }))
  default = [
    {
      slot    = "virtio0"
      size    = "32G"
      storage = "data-hdd"
      type    = "disk"
    }
  ]
}

variable "vm_networks" {
  description = "Network configuration for the VM"
  type = list(object({
    id     = number
    model  = string
    bridge = string
  }))
  default = [
    {
      id     = 0
      model  = "virtio"
      bridge = "vmbr0"
    }
  ]
}

variable "ssh_public_key" {
    description = "ssh key for cloudinit user access"
    type = string
}

variable "cloudinit_username" {
    description = "cloudinit user username"
    type = string
}

variable "cloudinit_password" {
    description = "cloudinit user password"
    type = string
    sensitive = true
}

variable "scsihw" {
  description = "SCSI hardware type in Proxmox"
  type = string
  default = "virtio-scsi-pci"
}

variable "boot_order" {
  description = "Disk boot order"
  type = string
  default = "order=virtio0"
}

variable "hotplug" {
  description = "hotplug config"
  type = string
  default = "disk,network,usb"
}

variable "bios_type" {
  description = "BIOS type for VMs"
  type = string
  default = "ovmf"
}

variable "machine_type" {
  description = "Proxmox machine type"
  type = string
  default = "q35"
}

variable "ciupgrade" {
  description = "sets the ciupgrade flag"
  type = bool
  default = true
}

variable "cicustom_string" {
  description = "cicustom string"
  type = string
  default = "vendor=local:snippets/vendor.yaml"
}

variable "ci_ipconfig0" {
  description = "cloudinit ipconfig0 configuration"
  type = string
  default = "ip=dhcp"
}

variable "skip_ipv6" {
  description = "cloudinit - choose whether to skip ipv6"
  type = bool
  default = true
}

variable "cloudinit_nameservers" {
  description = "DNS servers used by cloudinit - space seperated list in string format"
  type = string
  default = "1.1.1.1 8.8.8.8"
}

variable "serial_id" {
  description = "ID of virtual serial port"
  type = number
  default = 0
}

variable "cloudinit_diskconfig" {
  description = "Defines the cloudinit disk config"
  type = object({
    slot = string
    storage = string
    type = string
  })
  default = {
    slot = "scsi1"
    storage = "data-hdd"
    type = "cloudinit"
  }  
}

variable "full_clone" {
  description = "Specify full clone of the template"
  type = bool
  default = true
}

variable "qemu_agent" {
  description = "Choose whether to install the qemu guest agent"
  type = number
  default = 1
}

variable "sockets" {
  description = "specify number of CPU sockets"
  type = number
  default = 1
}