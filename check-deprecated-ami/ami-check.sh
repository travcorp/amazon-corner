#! /bin/bash
set -e

echo seting user profile...
PROFILE=$(aws sts assume-role --role-arn $DEPLOY_ROLE_ARN --role-session-name CLI-SESSION)
export AWS_ACCESS_KEY_ID=$(echo $PROFILE | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $PROFILE | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $PROFILE | jq .Credentials.SessionToken | xargs)

echo seting region...
export AWS_DEFAULT_REGION=$REGION

cd build

echo fetching available images...
aws ec2 describe-images --query 'Images[*].{ID:ImageId}' --output text > all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Project:Tags[?Key==`Project`].Value | [0],AMI:ImageId, Name:Tags[?Key==`Name`] | [0].Value,Instance:InstanceId, Project:Tags[?Key==`Project`] | [0].Value} | [] | sort_by(@,&to_string(Project))' --filters 'Name=instance-state-name,Values=stopped,running' --output table > inuse.txt

echo finding deprecated images...
grep -v -f all.txt inuse.txt > deprecated.txt
if grep ami-  deprecated.txt ; then
	echo DEPRECATED AMIS FOUND
	exit 1
fi
