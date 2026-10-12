variable "ssh_public_key" {
  description = "ssh key for cloudinit user access"
  type        = string
}

variable "cloudinit_username" {
  description = "cloudinit user username"
  type        = string
}

variable "cloudinit_password" {
  description = "cloudinit user password"
  type        = string
  sensitive   = true
}

variable "vm_list" {
  description = "VMs to create, keyed by VM name."
  type = map(object({
    vm_description = string
    vm_cores       = number
    vm_memory      = number
    vm_tags        = list(string)
    vm_disks = optional(list(object({
      slot    = string
      size    = string
      storage = string
      type    = string
    })))
  }))
}