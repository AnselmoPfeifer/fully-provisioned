#!/usr/bin/env bash

set -e
BUCKET_NAME='chef-deploy'

echo 'Getting public ssh key from ~/.ssh/id_rsa'
cat ~/.ssh/id_rsa.pub > packer/authorized_keys

# Using the properties file set the variable
function exportVariables() {
    echo 'INFO:Exporting aws credential variables'
    for env in $(cat aws-credentials.properties); do
        export $env
    done
}

# To create the base image
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

# To criate the all aws resources involved in this case.
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

# to execute the chef deploy
function chefDeploy() {
    (
        cd fully-chef/;
        berks install;
        berks update;
        mkdir -p target/cookbooks;
        berks vendor target/cookbooks
        cd target;
        tar cvf cookbooks_master.tar.gz cookbooks
    )
    aws s3 cp resources/master-database.json s3://${BUCKET_NAME}/master-database.json
    aws s3 cp resources/slave-database.json s3://${BUCKET_NAME}/slave-database.json
    aws s3 cp fully-chef/target/cookbooks_master.tar.gz s3://${BUCKET_NAME}/cookbooks/cookbooks_master.tar.gz
}

packerExecution ${1}
terraformExecution ${1}
chefDeploy
