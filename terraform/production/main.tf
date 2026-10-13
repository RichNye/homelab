module "vm" {
  source   = "../modules/ubuntu_vm"
  for_each = var.vm_list

  vm_name        = each.key
  vm_description = each.value.vm_description
  vm_cores       = each.value.vm_cores
  vm_memory      = each.value.vm_memory
  vm_tags        = join(",", each.value.vm_tags)
  vm_disks       = each.value.vm_disks

  ssh_public_key     = var.ssh_public_key
  cloudinit_username = var.cloudinit_username
  cloudinit_password = var.cloudinit_password
}