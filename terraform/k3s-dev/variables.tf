variable "ssh_public_key" {
    description = "ssh key for all production VMs"
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