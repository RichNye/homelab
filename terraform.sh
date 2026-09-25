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

function set_working_directory() {
    if [ -d "$HOME/homelab/terraform/$environment" ]; then
        echo "setting directory to $environment tf folder..."
        cd $HOME/homelab/terraform/$environment
    else
        echo "folder for environment $environment doesn't exist. Exiting..."
        exit 1
    fi
}

function terraform_plan () {
    if [ "${terraformPlan}" = true ]; then
        terraform plan
        exit 0
    fi
}

function terraform_apply() {
    if [ "${terraformApply}" = true ]; then
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
terraform_plan
terraform_apply
terraform_refresh
