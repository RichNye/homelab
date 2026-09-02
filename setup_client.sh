#!/bin/bash
# high-level steps:
# check proxmox API env variables exist, connect to proxmox as test
# install terraform, initialise, output a tf plan
# run tf apply if prompted

#######################
# Variable declaration
#######################

homelab_repo_url="https://github.com/RichNye/homelab.git"
proxmox_host="192.168.178.50"
proxmox_check=true


#######################
# process the supplied parameters
#######################

for parameter in "$@"
do
  case "$parameter" in
    --no-proxmox-check)
      proxmox_check=false
    ;;

    *)
      echo "Unknown option: $parameter"
      exit 1
    ;;
  esac
done


#######################
# function declaration
#######################
function check_proxmox_connection() {
  # check environment variables exist
  if [ ! "$PM_API_TOKEN_SECRET" ]; then
    echo "Proxmox API secret not found, please set!"
    exit 1
  fi
  if [ ! "$PM_API_TOKEN_ID" ]; then
    echo "Proxmox API token name not found, please set!"
    exit 1
  fi

  echo "testing connection to Proxmox host..."
  proxmox_response=$(curl -H "Authorization: PVEAPIToken=$PM_API_TOKEN_ID=$PM_API_TOKEN_SECRET" \
      https://$proxmox_host:8006/api2/json/version --insecure -i -s) 

  if [[ $proxmox_response != *"200 OK"* ]]; then
      echo "Proxmox API error - curl output in full:"
      echo "$proxmox_response"
      exit 1
  else
      echo "Proxmox host tested successfully!"
  fi
}

# source: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
function install_terraform() {
  # install prereqs
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

  # install Hashicorp GPG key
  wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

  # add Hashicorp repo
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

  # install Terraform
  sudo apt update && sudo apt install -y terraform
}

function install_ansible() {
  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository --yes --update ppa:ansible/ansible
  sudo apt install -y ansible
}


#####################
# Main script
#####################

# check Proxmox connection via environment variables
if [[ "$proxmox_check" = true ]]; then
  check_proxmox_connection
fi


# install Terraform and prereqs
echo "installing terraform..."
if dpkg -s terraform &> /dev/null; then
  echo "terraform installed - skipping install"
else
  echo "terraform not installed - installing..."
  install_terraform
fi  

# install Ansible and prereqs
echo "installing ansible..."
if dpkg -s ansible &> /dev/null; then
  echo "ansible installed - skipping install"
else 
  echo "ansible not installed - installing..."
  install_ansible
fi

# clone github repo
echo "cloning homelab repo..."
if ! dpkg -s git &> /dev/null; then
  echo "git not installed - installing..."
  sudo apt install -y git
else 
  git clone $homelab_repo_url
fi
