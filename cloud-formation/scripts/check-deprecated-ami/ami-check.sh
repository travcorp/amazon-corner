#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

echo seting region...
aws configure set region eu-west-1
export AWS_DEFAULT_REGION=us-west-1

echo fetching available images...
aws ec2 describe-images --filters "Name=platform, Values=windows" --query 'Images[*].{ID:ImageId}' --output text --profile $AWS_PROFILE > all.txt
# cat all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --region eu-west-1 --query 'Reservations[*].Instances[*].[ImageId, Tags[?Key==`Project`].Value]' --filters "Name=platform, Values=windows" --output text --profile $AWS_PROFILE | paste - - > inuse.txt
cat inuse.txt

echo finding deprecated images...
grep -v -f all.txt inuse.txt | sort -u > deprecated.txt
cat deprecated.txt

ls -l
echo finished...
pwd

echo changing to build dir
cd /build
echo hello > testfile.txt
ls -l

