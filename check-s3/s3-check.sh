#! /bin/bash
# AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`
AWS_PROFILE=dev

# echo setting region...
# export AWS_DEFAULT_REGION=$REGION

echo fetching s3 buckets and latest object...

for BUCKET in `aws --profile $AWS_PROFILE s3 ls | cut -d' ' -f 3` ;
do
	echo checking $BUCKET...

	LAST_MOD=$(aws s3api list-objects-v2 --bucket $BUCKET --query 'Contents[?LastModified<=`2018-12-31`][LastModified, Key] | sort_by(@,&[0]) | [0]' --profile dev --output text)

        #aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'
        # LINE=`aws --profile $AWS_PROFILE s3 ls $BUCKET --recursive | sort | tail -n 1 `
	if [[ $LAST_MOD == "None" ]]; then
		RESULT="no old files" 
	elif [[ $LAST_MOD == "" ]]; then
		RESULT="empty bucket"
	fi
	
	echo checked bucket $BUCKET and found $RESULT >> output.log

	echo $BUCKET $LAST_MOD >> buckets.old
done

# echo Done

# cat out  | grep checked | sed 's/  / /g' | awk '{print $6, $3 }' | grep 20 | sort  | head -n 50 > oldestBuckets.txt
