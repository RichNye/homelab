output "vm_ipv4" {
    description = "IPv4 address of VM"
    value = proxmox_vm_qemu.ubuntu_vm.default_ipv4_address
}
