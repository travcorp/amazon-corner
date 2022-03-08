#!/bin/bash

usage()
{
    echo "Usage: $0 [options]"
    echo ""
    echo "  -h Display this help"
    echo ""
    echo "  -e The environment i.e dev,qa,uat,prod"
    echo ""
    echo "  -s Stack name"
    echo ""
    echo "  -p Stack parameters in the format ParameterKey=,ParameterValue= ParameterKey=,ParameterValue="
    echo ""
    echo "  -f Provide either path to template file (-f) or template S3 url (-u)"
    echo ""
    echo "  -u Provide either path to template file (-f) or template S3 url (-u)"    
    echo ""
    echo "  -a The assume role arn"
    echo ""
    echo "  -r The AWS region"
    echo ""
    echo "  -t The AWS tags"
    echo ""
    echo "e.g: sh update-stack.sh -e dev -s payment-services-application-latest -f application.yaml -r eu-west-1"
    echo ""
}

display_progress() {
  message=$1
  echo -ne "$message ###               \r"
  sleep 1
  echo -ne "$message ######            \r"
  sleep 1
  echo -ne "$message #########         \r"
  sleep 1
  echo -ne "$message ############      \r"
  sleep 1
  echo -ne "$message ###############   \r"
  sleep 1
  echo -ne "$message ##################\r"
}

get_last_resource_and_status() {
    resource_and_status=`aws --region $region --color on cloudformation describe-stack-events --stack-name $stack --max-items 1 --query 'StackEvents[*].[ResourceType,ResourceStatus]' --output text | head -1`
    echo "$resource_and_status"
}

stack_update_in_progress() {
  last_resource_and_status=$(get_last_resource_and_status)
  last_resource=$(echo $last_resource_and_status | cut -d' ' -f1)
  last_resource_status=$(echo $last_resource_and_status | cut -d' ' -f2)
  result=1
  if [ "$last_resource" = "AWS::CloudFormation::Stack" ];then
     if [ "$last_resource_status" = "UPDATE_COMPLETE" ] || [ "$last_resource_status" = "UPDATE_ROLLBACK_COMPLETE" ];then
        result=0 
     fi
  fi
  echo $result
}

environment=
stack=
stack_parameters=
template_file=
template_url=
assume_role_arn=
region=
tags=

while getopts "e:s:p:f:a:r:u:" arg
do
     case "$arg" in
        h)
            usage
            exit
            ;;
        e)
            environment=$OPTARG
            ;;
        s)
            stack=$OPTARG
            ;;    
        p)
            stack_parameters=$OPTARG
            ;;      
        f)
            template_file=$OPTARG
            ;;    
        u)
            template_url=$OPTARG
            ;;      
        a)
            assume_role_arn=$OPTARG
            ;;
        r)
            region=$OPTARG
            ;;
        t)
            tag=$OPTARG
            ;;
        *)
            echo "ERROR: Unknown parameter '$PARAM'"
            usage
            ;;
    esac
done

if [ "$region" = "" ]; then
   echo "Region must be provided"
   exit 1
fi


if [ "$template_url" = "" ] && [ "$template_file" = "" ]; then
   echo "Either template_url or template_file should be provided"
   exit 1
fi

echo "Updating stack [environment=$environment, region=$region, stack=$stack, stack_parameters=$stack_parameters, tags=$tags, template_file=$template_file, template_url=$template_url, assume_role_arn=$assume_role_arn]"

if [ "$assume_role_arn" != "" ];then
    credentials=$(aws sts assume-role --role-arn $assume_role_arn --role-session-name $stack --duration-seconds 3600 --query '[Credentials.AccessKeyId, Credentials.SecretAccessKey, Credentials.SessionToken]' --output text)
    access_key=$(echo $credentials | cut -d' ' -f1)
    secret_access_key=$(echo $credentials | cut -d' ' -f2)
    session_token=$(echo $credentials | cut -d' ' -f3)
    export AWS_ACCESS_KEY_ID="$access_key"
    export AWS_SECRET_ACCESS_KEY="$secret_access_key"
    export AWS_SESSION_TOKEN="$session_token"
fi

update_start_time=`date +"%Y-%m-%dT%H:%M:%S"`

update_stack_cmd="aws --region $region --color on cloudformation update-stack --stack-name $stack --capabilities CAPABILITY_IAM"

if [ "$template_url" != "" ];then
   update_stack_cmd="$update_stack_cmd --template-url $template_url"
elif [ "$template_file" != "" ];then
  update_stack_cmd="$update_stack_cmd --template-body file://$template_file"
fi

if [ "$stack_parameters" != "" ];then
   update_stack_cmd="$update_stack_cmd --parameters $stack_parameters"
fi

if [ "$tags" != "" ];then
   update_stack_cmd="$update_stack_cmd --tags $tags"
fi

#if [ "$assume_role_arn" != "" ];then
#   update_stack_cmd="$update_stack_cmd --role-arn $assume_role_arn"
#fi

echo "Command is $update_stack_cmd"
update_stack_cmd_out=$($update_stack_cmd 2>&1)

if [ "$(echo $update_stack_cmd_out | grep -o 'StackId')" != "" ];then
   echo "Checking stack status"
   while [  "`stack_update_in_progress`" = "1" ];
   do
      display_progress "Stack update in progress"
   done   
   last_resource_status=$(echo `get_last_resource_and_status` | cut -d' ' -f2)
   if [ "$last_resource_status" = "UPDATE_COMPLETE" ]; then
      echo "                             "
      echo "Stack update completed successfully"
   else 
      echo "Stack update failed"   
      aws --region $region --color on cloudformation describe-stack-events --stack-name $stack --query "StackEvents[?Timestamp>=\`$update_start_time\`].[ResourceType, ResourceStatus, ResourceStatusReason, Timestamp]" --output table
      exit 1
   fi    
elif [ "$(echo $update_stack_cmd_out | grep -o 'No updates are to be performed')" != "" ];then
  echo "Stack is up-to-date. Nothing to update"  
else 
  echo "Stack update failed"  
  echo "$update_stack_cmd_out"
  exit 1
fi

