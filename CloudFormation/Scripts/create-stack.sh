#!/bin/bash
s3_key=$s3_key-$(uuidgen)
stack_template_url=https://$s3_bucket_name.s3.amazonaws.com/$s3_key
echo Uploading template file: $stack_template --\> $stack_template_url
aws s3api put-object --bucket $s3_bucket_name --key $s3_key --body $stack_template --region $region --profile $profile \
  || (>&2 echo FAILURE: Could not upload template to S3. See the error above! \
	 && exit 1) \
  || exit 1

if [ -z ${stack_parameters+x} ]
then 
  params=''
  echo No stack parameters
else
  params='--parameters file://'$stack_parameters
  echo Parameter file: $stack_parameters
fi

echo Creating stack $stack_name
stack_id=$(aws cloudformation create-stack --stack-name $stack_name --template-url $stack_template_url --capabilities CAPABILITY_IAM --region $region --profile $profile --output text $params) \
  || (>&2 echo FAILURE: Stack $stack_name failed to create. See the error above! \
	 && exit 1) \
  || exit 1
echo Waiting for stack $stack_name
aws cloudformation wait stack-create-complete --stack-name $stack_id --region $region --profile $profile \
  || (>&2 echo FAILURE: Stack $stack_name failed to create. See the errors below: \
    && >&2 aws cloudformation describe-stack-events --stack-name $stack_id --region $region --profile $profile \
		--query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[ResourceStatus, ResourceType, LogicalResourceId, ResourceStatusReason]' --output text \
    && exit 1) \
  || exit 1
echo SUCCESS: Stack $stack_name has been created