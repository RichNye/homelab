##############
# DESCRIPTION
##############
# Terraform remote state access keys are encrypted using SOPS/age. 
# As a result, a wrapper script is required for all Terraform commands.
# This script will decrypt the remote state secret, export it as a temporary environment variable
# parameters are used to specify the desired Terraform action.

terraformApply=false
terraformPlan=false
terraformRefresh=false
environment="production"

############
# process script parameters
############

for parameter in "$@"
do
  case "${parameter}" in
    apply)
      terraformApply=true
    ;;

    plan)
      terraformPlan=true
    ;;

    refresh)
      terraformRefresh=true
    ;;

    --environment)
      environment=$parameter
    ;;

    *)
      echo "Unknown option: "${parameter}""
      exit 1
    ;;
  esac
done

function get_remote_state_access_key() {
    echo "hello"
    # tweaked from source jfmaes.me/blog/stop-committing-your-secrets-you-know-who-you-are/
    local file="$HOME/homelab/.enc.env"
    local accessKeyName="AWS_ACCESS_KEY_ID"
    local accessSecretName="AWS_SECRET_ACCESS_KEY"

    [ ! -f "${file}" ] && echo "File not found: ${file}" && return 1

    local decrypted
    decrypted="$(sops -d "${file}")" || { echo "Failed to decrypt ${file}"; exit 1; }
    local accessKeyLine accessSecretLine
    accessKeyLine="$(awk -F= -v k="${accessKeyName}" '$1==k' <<< "${decrypted}")"
    accessSecretLine="$(awk -F= -v k="${accessSecretName}" '$1==k' <<< "${decrypted}")"

    if [ -z "${accessKeyLine}" ]; then
        echo "Access key not found in ${file}, exiting..."
        exit 1
    fi

    if [ -z "${accessSecretLine}" ]; then
        echo "Access secret not found in ${file}, exiting..."
        exit 1
    fi

    export "${accessKeyLine}"
    export "${accessSecretLine}"
}

function get_proxmox_api_key() {
    # tweaked from source jfmaes.me/blog/stop-committing-your-secrets-you-know-who-you-are/
    local file="$HOME/homelab/.enc.env"
    local pm_api_key_id="PM_API_TOKEN_ID"
    local pm_api_key="PM_API_TOKEN_SECRET"

    [ ! -f "${file}" ] && echo "File not found: ${file}" && return 1

    local decrypted
    decrypted="$(sops -d "${file}")" || { echo "Failed to decrypt ${file}"; exit 1; }
    local pm_key_id_line pm_api_value_line
    pm_key_id_line="$(awk -F= -v k="${pm_api_key_id}" '$1==k' <<< "${decrypted}")"
    pm_api_value_line="$(awk -F= -v k="${pm_api_key}" '$1==k' <<< "${decrypted}")"

    if [ -z "${pm_key_id_line}" ]; then
        echo "Access key not found in ${file}, exiting..."
        exit 1
    fi

    if [ -z "${pm_api_value_line}" ]; then
        echo "Access secret not found in ${file}, exiting..."
        exit 1
    fi

    export "$pm_key_id_line"
    export "$pm_api_value_line"
}

function set_working_directory() {
    if [ -d "$HOME/homelab/terraform/$environment" ]; then
        echo "setting directory to $environment tf folder..."
        cd $HOME/homelab/terraform/$environment
    else
        echo "folder for environment $environment doesn't exist. Exiting..."
        exit 1
    fi
}

# run init every time given that it's harmless and sets up environment on first run.
# could be improved to detect errors from tf commands that require init and only call when needed.
function terraform_init () {
    terraform init
}

function terraform_plan () {
    if [ "${terraformPlan}" =  true ]; then
        get_proxmox_api_key
        terraform plan
        exit 0
    fi
}

function terraform_apply() {
    if [ "${terraformApply}" = true ]; then
        get_proxmox_api_key
        terraform apply
        exit 0
    fi
}

function terraform_refresh() {
    if [ "${terraformRefresh}" = true ]; then
        terraform refresh
        exit 0
    fi    
}

####################
# MAIN SCRIPT
####################
echo "running script..."
get_remote_state_access_key
set_working_directory
terraform_init
terraform_plan
terraform_apply
terraform_refresh
