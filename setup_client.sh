#!/bin/bash
# high-level steps:
# check proxmox API env variables exist, connect to proxmox as test
# test connection to Proxmox using ssh key
# install terraform, initialise, output a tf plan
# run tf apply if prompted

PROXMOX_HOST="192.168.178.50"

# check environment variables exist
if [ ! $PM_API_TOKEN_SECRET ]; then
  echo "Proxmox API secret not found, please set!"
  exit 1
fi
if [ ! $PM_API_TOKEN_ID ]; then
  echo "Proxmox API token name not found, please set!"
  exit 1
fi

echo "testing connection to Proxmox host..."
proxmox_response=$(curl -H "Authorization: PVEAPIToken=$PM_API_TOKEN_ID=$PM_API_TOKEN_SECRET" \
    https://$PROXMOX_HOST:8006/api2/json/version --insecure -i -s) 

if [[ $proxmox_response != *"200 OK"* ]]; then
    echo "Proxmox API error - curl output in full:"
    echo "$proxmox_response"
else
    echo "Proxmox host tested successfully!"
fi



