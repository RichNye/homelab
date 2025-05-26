variable "proxmox_host" {
    description = "proxmox host for the VM"
    type = string
    default = "RN-PROXMOX01"
}

variable "ubuntu_template" {
    description = "Ubuntu template"
    type = string
    default = "ubuntu-2404-cloudinit-template"
}