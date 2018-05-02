#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

cd build

echo seting region...
aws configure set region $REGION
export AWS_DEFAULT_REGION=$REGION

echo fetching available images...
aws ec2 describe-images --query 'Images[*].{ID:ImageId}' --output text --profile $AWS_PROFILE > all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --region $REGION --query 'Reservations[*].Instances[*].[ImageId, Tags[?Key==`Project`].Value]' --output text --profile $AWS_PROFILE | paste - - > inuse.txt

echo finding deprecated images...
grep -v -f all.txt inuse.txt | sort -u > deprecated.txt

if [ -s deprecated.txt ]; then
	echo DEPRECATED AMIS FOUND
	exit 1
fi
