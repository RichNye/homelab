#!/usr/bin/bash

encrypted_file="$HOME/homelab/.enc.env"

keys_to_decrypt=(
"PM_API_TOKEN_ID"
"PM_API_TOKEN_SECRET"
"PM_HOSTNAME"
"AWS_ACCESS_KEY_ID"
"AWS_SECRET_ACCESS_KEY"    
)

for key in "${keys_to_decrypt[@]}"
do
    export "$key"=$(sops decrypt --extract "[\""$key"\"]" "$encrypted_file")
done