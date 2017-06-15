# create-stack.sh

A compact CLI script for provisioning infrastructure with CloudFormation stacks.

- Uploads a CloudFormation template to S3
- Creates a stack with the uploaded template
- Uses stack parameters from a JSON file

### Example usage in Bash:
```
stack_name=test-vpc \
region=eu-west-1 \
profile=ttc-dev \
stack_template=vpc.yml \
s3_bucket_name=ttc-releases-aws-dev \
s3_key=myproject/mystack \
stack_parameters=params.json \
./create-stack.sh
```
### JSON parameter file example:
Parameter JSON file should be formatted as per [AWS CLI documentation](http://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html):
```
[
  {
    "ParameterKey": "Project",
    "ParameterValue": "TestVPC"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "Dev"
  }
]
```