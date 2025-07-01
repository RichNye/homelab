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

