#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`
# AWS_PROFILE=dev

cd build

echo seting region...
# aws configure set region $REGION
export AWS_DEFAULT_REGION=$REGION

echo fetching available images...
aws ec2 describe-images --query 'Images[*].{ID:ImageId}' --output text --profile $AWS_PROFILE > all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Project:Tags[?Key==`Project`].Value | [0],AMI:ImageId, Name:Tags[?Key==`Name`].Value | [0],Instance:InstanceId, Project:Tags[?Key==`Project`].Value | [0]}' --output table --profile $AWS_PROFILE > inuse.txt

echo finding deprecated images...
grep -v -f all.txt inuse.txt > deprecated.txt
(head -n 5 deprecated.txt && tail -n +6 deprecated.txt | sort -rk3) > d.txt

# if [ -s deprecated.txt ]; then
# 	echo DEPRECATED AMIS FOUND
# 	exit 1
# fi
