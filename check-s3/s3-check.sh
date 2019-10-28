#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

echo setting region...
export AWS_DEFAULT_REGION=$REGION

echo fetching s3 buckets and latest object...

for BUCKET in `aws --profile $AWS_PROFILE s3 ls | cut -d' ' -f 3` ;
do
	echo checking $BUCKET...
	
	# Check for files newer than 2018-12-31
	LAST_MOD=$(aws s3api list-objects-v2 --query 'Contents[?LastModified>=`2018-12-31`][LastModified, Key] | sort_by(@,&[0]) | [-1] | [0]' --profile $AWS_PROFILE --output json --bucket $BUCKET 2>/dev/null)
	
	if [[ $LAST_MOD == "null" ]]; then
		OUTPUT="OLD"
		echo $BUCKET $OUTPUT >> dirty-old-buckets.txt
	elif [[ $LAST_MOD == "" ]]; then
		OUTPUT="empty"
		echo $BUCKET $OUTPUT >> dirty-old-buckets.txt
	else
		OUTPUT="recent file $LAST_MOD"
	fi
	
	echo checked bucket $BUCKET and found $OUTPUT >> output.txt

done

echo formatting output...
cat dirty-old-buckets.txt | column -t > old-buckets.txt

echo moving artifacts...
cp old-buckets.txt output.txt /build

echo Done