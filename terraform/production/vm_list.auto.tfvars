vm_list = {
  "web-01" = {
    vm_description = "Web Server VM"
    vm_cores       = 1
    vm_memory      = 1024
    vm_tags        = ["web", "prod"]
  }
  "db-01" = {
    vm_description = "Database VM"
    vm_cores       = 1
    vm_memory      = 2048
    vm_tags        = ["database", "prod"]
    vm_disks = [
      { slot = "scsi0", size = "64G", storage = "data-sata", type = "disk" }
    ]
  }
  "lb-01" = {
    vm_description = "Load Balancer VM"
    vm_cores       = 1
    vm_memory      = 1024
    vm_tags        = ["loadbalancer", "haproxy", "prod"]
  }
  "monitor-01" = {
    vm_description = "Monitoring VM"
    vm_cores       = 1
    vm_memory      = 1024
    vm_tags        = ["monitoring", "prometheus", "grafana", "prod"]
  }
}