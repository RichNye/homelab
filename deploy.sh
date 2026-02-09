#!/bin/bash

repo_root="/home/ubuntu/gitrepos/homelab"
playbooks_dir="ansible/playbooks"
inventory_dir="ansible/inventory"

read -r -p "Specify the environment (prod, dev, both): " environment
read -r -p "Specify the server role (lb, web, db, all): " role
read -r -p "Specify the GitHub branch name: " branch

echo "Your chosen environment is $environment"
echo "Your chosen server role is $role"
read -r -p "Is this correct? (y/n): " user_confirm

case "$user_confirm" in
  y|Y|yes|YES)
    echo "Continuing script..."
    ;;
  n|N|no|NO)
    echo "Exiting script..."
    exit 1
    ;;
  *)
    echo "Incorrect input"
    exit 1
    ;;
esac

cd "$repo_root" || exit 1

echo "Pulling latest updates from GitHub..."
git checkout "$branch"

playbook_path="$repo_root/$playbooks_dir/setup_$role.yaml"
inventory_path="$repo_root/$inventory_dir/$environment/inventory.yaml"

if [ ! -f "$playbook_path" ]; then
  echo "Playbook not found. Exiting..."
  exit 1
fi

if [ ! -f "$inventory_path" ]; then
  echo "Inventory not found. Exiting..."
  exit 1
fi

echo "Running playbook..."
ansible-playbook -i "$inventory_path" "$playbook_path" --ask-vault-password --check
