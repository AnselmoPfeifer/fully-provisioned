#!/usr/bin/env bash

set -e

echo 'Getting public ssh key from ~/.ssh/id_rsa'
cat ~/.ssh/id_rsa.pub > packer/authorized_keys

function exportVariables() {
    echo 'INFO:Exporting aws credential variables'
    for env in $(cat aws-credentials.properties); do
        export $env
    done
}

function packerExecution() {
    exportVariables ${1}
    echo 'INFO: Replacing the packer template'
    python replace_packer.py

    if [ ${1} == 'test' ]; then
        echo 'INFO: Validating the packer template'
        packer validate 'packer/template.json'

    elif [ ${1} == 'deploy' ]; then
        echo 'INFO: Deploying a new AWS AMI with packer'
        packer build -force -color=false 'packer/template.json'
        AMI_ID=$(aws ec2 describe-images --region ${AWS_DEFAULT_REGION}  --filters "Name=tag-key,Values=Name,Name=tag-value,Values=Image-${AWS_LABEL}" --query 'Images[*].{id:ImageId}' | jq .[].id | cut -f2 -d'"')

        cat << EOF >>  'aws-credentials.properties'
AWS_AMI_ID=${AMI_ID}
EOF
        echo "The new image id: ${AWS_AMI_ID}"

        else
            echo 'ERROR: Invalid parameter, try to use, test/deploy'
            exit 1
    fi
}

function terraformExecution() {
    echo 'INFO:Starting replace envs on terraform variables'
    exportVariables ${1}
    local tfOptions="-var access_key=${AWS_ACCESS_KEY_ID} -var secret_key=${AWS_SECRET_ACCESS_KEY}"

    cat terraform/variables-template.tpl \
        | sed "s/<AWS_DEFAULT_REGION>/${AWS_DEFAULT_REGION}/g" \
        | sed "s/<AWS_AMI_ID>/${AWS_AMI_ID}/g" \
        | sed "s/<AWS_LABEL>/${AWS_LABEL}/g"  \
        | sed "s/<AWS_S3_BUCKET>/${AWS_S3_BUCKET}/g"  \
        > terraform/variables.tf

    if [ ${1} == 'test' ]; then
        (cd terraform;
            terraform init ${tfOptions}
            terraform plan  ${tfOptions})

     elif [ ${1} == 'deploy' ]; then
         (cd terraform;
            terraform init ${tfOptions}
            terraform plan  ${tfOptions}
            terraform apply ${tfOptions} -auto-approve)

     else
        echo 'ERROR: Invalid parameter, try to use, test/deploy'
        exit 1
    fi
}

packerExecution ${1}
terraformExecution ${1}