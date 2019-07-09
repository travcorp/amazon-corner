#! /bin/bash
AWS_PROFILE=`. /aws-assume-role.sh $DEPLOY_ROLE_ARN`

cd build

echo setting region...
aws configure set region $REGION
export AWS_DEFAULT_REGION=$REGION

echo fetching s3 buckets and latest object

for BUCKET in `aws --profile $AWS_PROFILE s3 ls | cut -d' ' -f 3` ;
do
	echo bucket is $BUCKET

        #aws s3 ls $BUCKET --recursive | sort | tail -n 1 | awk '{print $4}'
        LINE=`aws --profile $AWS_PROFILE s3 ls $BUCKET --recursive | sort | tail -n 1 `

        echo checked bucket $BUCKET and found $LINE >> out

	#break

done

echo Done
cat out

#cat out  | grep checked | sed 's/  / /g' | awk '{print $6, $3 }' | grep 20 | sort  | head -n 30

