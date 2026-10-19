output "vm_ip" {
    description = "IPv4 address assigned to the VM"
    value = { for vm_name, outputs in module.vm : vm_name => outputs.vm_ipv4 }
}

output "all_vms" {
    value = module.vm
}