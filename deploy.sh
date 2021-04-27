#!/bin/bash

set -e

# Print help text and exit.
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<HELP
Usage: deploy --tf-organization <your-tf-cloud-organization> --tf-action <tf-action>

Args:
  - tf-organization: The name of your Terraform cloud organization. This overrides the TF_ORGANIZATION environment variable value when set
  - tf-action: The name of the Terraform CLI action to run (plan, apply, destroy, etc.)

Examples:
  - deploy
  - deploy --tf-organization alternative-tf-org-name --tf-action destroy
HELP
  exit 1
fi

# If this isn't a "help" command, get inputs
tf_organization=${TF_ORGANIZATION:-cory-huebner-training}
tf_action="apply"

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param=$(echo "${1/--/}" | tr '-' '_')
        declare $param="$2"
   fi

  shift
done

echo "TF organization used: $tf_organization"
echo "TF action: $tf_action"

# Deploy infrastructure
cd terraform
terraform init -backend-config="organization=$tf_organization"
terraform fmt
terraform $tf_action
cf_stack_name=$(terraform output -raw cloud_formation_stack_name)
artifacts_bucket=$(terraform output -raw artifacts_bucket)
cd -

# Deploy Lambda
cd src
sam deploy --stack-name $cf_stack_name \
  --s3-bucket $artifacts_bucket \
  --template pull-from-s3-template.yml \
  --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
  --no-fail-on-empty-changeset
cd -