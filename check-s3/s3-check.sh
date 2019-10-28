#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

echo setting region...
export AWS_DEFAULT_REGION=$REGION

echo fetching s3 buckets and latest object...

for BUCKET in `aws --profile $AWS_PROFILE s3 ls | cut -d' ' -f 3 | head -n6` ;
do
	echo checking $BUCKET...
	
	LAST_MOD=$(aws s3api list-objects-v2 --query 'Contents[?LastModified<=`2018-12-31`][LastModified, Key] | sort_by(@,&[0]) | [0] | [0]' --profile dev --output json --bucket $BUCKET 2>/dev/null)
	
	aws s3api list-objects-v2 --query 'Contents[?LastModified<=`2018-12-31`][LastModified, Key] | sort_by(@,&[0]) | [0] | [0]' --profile dev --output json --bucket $BUCKET
	echo checked bucket $BUCKET returned ----- $LAST_MOD >> debug.txt
	echo this is lastmod: $LAST_MOD

	if [[ $LAST_MOD == "null" ]]; then
		OUTPUT="no old files" 
	elif [[ $LAST_MOD == "" ]]; then
		OUTPUT="empty"
		echo $BUCKET $OUTPUT >> dirty-old-buckets.txt
	else
		echo $BUCKET $LAST_MOD >> dirty-old-buckets.txt
		OUTPUT=$LAST_MOD
	fi
	
	echo checked bucket $BUCKET and found $OUTPUT >> output.txt

done

echo formatting output...
cat dirty-old-buckets.txt | column -t > old-buckets.txt

echo moving artifacts...
cp old-buckets.txt output.txt debug.txt /build

echo Done