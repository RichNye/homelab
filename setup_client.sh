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
clone_repo=true

runner_user="selfhosted-runner"

#######################
# process the supplied parameters
#######################

for parameter in "$@"
do
  case "$parameter" in
    --skip-proxmox-check)
      proxmox_check=false
    ;;

    --skip-repo-clone)
      clone_repo=false
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

  if [[ "$proxmox_response" != *"200 OK"* ]]; then
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

function create_runner_user() {
  if grep -c "^${"$runner_user"}:" /etc/passwd; then
    echo "user already exists"
  else
    echo "creating self-hosted runner user..."
    sudo useradd -m -s /bin/bash "$runner_user"
    echo "enter new user password: "
    sudo passwd "$runner_user"
  fi
}

function create_selfhosted_runner() {
  local runner_dir="/opt/actions-runner"

  sudo mkdir "$runner_dir"; sudo chown "$runner_user" "$runner_dir"

  cd "$runner_dir"
  pwd
  echo "downloading runner package"
  sudo -u $runner_user bash -c "curl -o actions-runner-linux-x64-2.337.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.337.0/actions-runner-linux-x64-2.337.0.tar.gz"
  sudo -u $runner_user bash -c "tar xzf ./actions-runner-linux-x64-2.337.0.tar.gz"
  
  read -p "please enter the runner token: " runner_token
  sudo -u $runner_user bash -c "./config.sh --url https://github.com/RichNye/MealPlannerFrontend --token "$runner_token""
  sudo "$runner_dir"/svc.sh install $runner_user
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

# check for git and clone git repo if not skipped
if ! dpkg -s git &> /dev/null; then
  echo "git not installed - installing..."
  sudo apt install -y git
fi

if [[ "$clone_repo" = true ]]; then
  echo "cloning homelab repo..."
  git clone "$homelab_repo_url"
fi

# configure self-hosted runner (currently GitHub but may be GitLab in future)
create_runner_user
create_selfhosted_runner

