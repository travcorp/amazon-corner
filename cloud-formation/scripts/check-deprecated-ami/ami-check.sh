#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`
echo $DEPLOY_ROLE_ARN
echo fetching available images...
aws ec2 describe-images --filters "Name=platform, Values=windows" --query 'Images[*].{ID:ImageId}' > all.txt

echo fetching images used by running instances...
aws ec2 describe-instances --query "Reservations[*].Instances[*].[ImageId]" --filters "Name=platform, Values=windows" > inuse.txt 

echo finding deprecated images...
grep -v -f all.txt inuse.txt | sort -u > deprecated.txt

cat deprecated.txt
echo cleaning up...
rm all.txt inuse.txt deprecated.txt