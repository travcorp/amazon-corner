#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

echo seting region...
aws configure set region eu-west-1
export AWS_DEFAULT_REGION=us-west-1

echo fetching available images...
aws ec2 describe-images --filters "Name=platform, Values=windows" --query 'Images[*].{ID:ImageId}' --output text --profile $AWS_PROFILE > all.txt
cat all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --query "Reservations[*].Instances[*].[ImageId]" --filters "Name=platform, Values=windows" --output text --profile $AWS_PROFILE > inuse.txt 

echo finding deprecated images...
grep -v -f all.txt inuse.txt | sort -u > deprecated.txt

cat deprecated.txt
echo cleaning up...
rm all.txt inuse.txt deprecated.txt