#! /bin/bash
set -e
# AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

echo seting region...
# export AWS_DEFAULT_REGION=$REGION

PROFILE=$(aws sts assume-role --role-arn arn:aws:iam::845786622553:role/deploy_prod_role --role-session-name CLI-SESSION)

export AWS_ACCESS_KEY_ID=$(echo $PROFILE | jq .Credentials.AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(echo $PROFILE | jq .Credentials.SecretAccessKey | xargs)
export AWS_SESSION_TOKEN=$(echo $PROFILE | jq .Credentials.SessionToken | xargs)

cd build

echo fetching available images...
aws ec2 describe-images --query 'Images[*].{ID:ImageId}' --output text --profile $PROFILE > all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Project:Tags[?Key==`Project`].Value | [0],AMI:ImageId, Name:Tags[?Key==`Name`] | [0].Value,Instance:InstanceId, Project:Tags[?Key==`Project`] | [0].Value} | [] | sort_by(@,&to_string(Project))' --output table --profile $PROFILE > inuse.txt

echo finding deprecated images...
grep -v -f all.txt inuse.txt > deprecated.txt
if grep ami-  deprecated.txt ; then
	echo DEPRECATED AMIS FOUND
	exit 1
fi
