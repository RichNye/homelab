#!/bin/bash

repo_root="/home/ubuntu/gitrepos/homelab"
playbook_path="/ansible/playbooks"
inventory_path="/ansible/inventory"

## Gather script arguments
read -r -p "Specify the environment (prod, dev, both): \n"  environment
read -r -p "Specify the server role (lb, web, db, all): \n" role
read -r -p "Specify the GitHub branch name:" branch

echo "Your chosen environment is $environment"
echo "Your chosen server role is $role"
read -r -p "Is this correct? \n" user_confirm

case $user_confirm in
    "n"|"N"|"no"|"No"|"NO")
    echo "Exiting script..."
    exit 1
    ;;

    "y"|"Y"|"yes"|"Yes"|"YES")
    echo "Continuing script..."
    ;;

    *)
    echo "Incorrect input"
esac

cd "$repo_root"

echo "pulling latest updates from GitHub"
git checkout "$branch"