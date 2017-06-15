#!/bin/bash
echo Deleting stack $stack_name
aws cloudformation delete-stack --stack-name $stack_name --region $region --profile $profile --output text \
  || (>&2 echo FAILURE: Stack $stack_name failed to delete. See the error above! \
         && exit 1) \
  || exit 1
echo Waiting for stack $stack_name
aws cloudformation wait stack-delete-complete --stack-name $stack_name --region $region --profile $profile \
  || (>&2 echo FAILURE: Stack $stack_name failed to delete. See the errors below: \
    && >&2 aws cloudformation describe-stack-events --stack-name $stack_name --region $region --profile $profile --output text \
          --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[ResourceStatus, ResourceType, LogicalResourceId, ResourceStatusReason]' \
    && exit 1) \
  || exit 1
echo SUCCESS: Stack $stack_name has been deleted
