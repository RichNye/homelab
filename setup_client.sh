#!/usr/bin/env bash

#################################
# DESCRIPTION
#################################

# This script runs interactively as part of homelab setup.
# Configures a Linux host as a homelab control node.
# The control node is expected to run Terraform and Ansible code that configures MealPlanner infrastructure and website.
# It will also function as a GitHub Actions self-hosted runner for CI/CD.

# high-level steps:
# check proxmox API env variables exist, connect to proxmox as test
# install terraform, ansible, git, and clone the homelab repo

# Prereqs before running:
# 1. environment vars: PM_API_TOKEN_ID and PM_API_TOKEN_SECRET (from Proxmox)
# 2. PM_HOSTNAME (either resolvable DNS name or Proxmox host IP
# 3. be in a position to create a new self-hosted runner in the GUI.

# typically catch errors with conditionals but this is a safety net. 
# empty variables shouldn't cause failure here - the script will handle them or the commands will fail with an exit code.
set -eo pipefail

#######################
# Variable declaration
#######################

proxmox_check=true
clone_repo=true

readonly homelab_repo_url="https://github.com/RichNye/homelab.git"
readonly runner_user="selfhosted-runner"

#######################
# process the supplied parameters
#######################

for parameter in "$@"
do
  case "${parameter}" in
    --skip-proxmox-check)
      proxmox_check=false
    ;;

    --skip-repo-clone)
      clone_repo=false
    ;;

    *)
      echo "Unknown option: "${parameter}""
      exit 1
    ;;
  esac
done

#######################
# function declaration
#######################
function check_proxmox_connection() {
  # check environment variables exist
  if [ ! "${PM_API_TOKEN_SECRET}" ]; then
    echo "Proxmox API secret not found, please set!"
    exit 1
  fi
  if [ ! "${PM_API_TOKEN_ID}" ]; then
    echo "Proxmox API token name not found, please set!"
    exit 1
  fi
  if [ ! "${PM_HOSTNAME}" ]; then
    echo "Proxmox hostname not found, please set!"
    exit 1
  fi

  echo "testing connection to Proxmox host..."
  # insecure flag used because the homelab doesn't have a cert configured for proxmox.
  proxmox_response=$(curl -H "Authorization: PVEAPIToken=${PM_API_TOKEN_ID}=${PM_API_TOKEN_SECRET}" \
  "https://${PM_HOSTNAME}:8006/api2/json/version" --insecure -i -s)

  # need to revisit this and try to look at the response code in a better way
  if [[ "${proxmox_response}" != *"200 OK"* ]]; then
      echo "Proxmox API error - curl output in full:"
      echo "${proxmox_response}"
      exit 1
  else
      echo "Proxmox host tested successfully!"
  fi
}

# source: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
function install_terraform() {
  if dpkg -s terraform &> /dev/null; then
    echo "terraform installed - skipping install"
  else
    echo "terraform not installed - installing..."
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
  fi  
}

function install_ansible() {
  if dpkg -s ansible &> /dev/null; then
    echo "ansible installed - skipping install"
  else 
    echo "ansible not installed - installing..."
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible    
  fi
}

function create_runner_user() {
  if id "${runner_user}" &>/dev/null; then
    echo "user already exists"
  else
    echo "creating self-hosted runner user..."
    sudo useradd -m -s /bin/bash "${runner_user}"
    # prompt for the password until a more secure and automated way of capturing it is scripted
    echo "enter new user password: "
    sudo passwd "${runner_user}"
  fi
}

function create_selfhosted_runner() {
  local runner_dir="/opt/actions-runner"

  sudo mkdir -p "${runner_dir}"; sudo chown "${runner_user}" "${runner_dir}"

  cd "${runner_dir}"
  pwd
  echo "downloading runner package"
  sudo -u "${runner_user}" bash -c "curl -o actions-runner-linux-x64-2.337.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.337.0/actions-runner-linux-x64-2.337.0.tar.gz"
  sudo -u "${runner_user}" bash -c "tar xzf ./actions-runner-linux-x64-2.337.0.tar.gz"
  
  # prompt for the runner token because runner setup is GUI-driven currently. Simple copy and paste of the token works here.
  read -p "please enter the runner token: " runner_token
  sudo -u "${runner_user}" bash -c "./config.sh --url https://github.com/RichNye/MealPlannerFrontend --token ${runner_token}"
  sudo "${runner_dir}"/svc.sh install "${runner_user}"
}

function run_terraform_plan() {

}

#####################
# Main script
#####################

# check Proxmox connection via environment variables
if [[ "${proxmox_check}" = true ]]; then
  check_proxmox_connection
fi

# install Terraform and prereqs
install_terraform

# install Ansible and prereqs
install_ansible

# check for git and clone git repo if not skipped
if ! dpkg -s git &> /dev/null; then
  echo "git not installed - installing..."
  sudo apt install -y git
fi
if [[ "${clone_repo}" = true ]]; then
  echo "cloning homelab repo..."
  git clone "${homelab_repo_url}"
fi

# configure self-hosted runner (currently GitHub but may be GitLab in future)
create_runner_user
create_selfhosted_runner

