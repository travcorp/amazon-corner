#!/bin/bash
set -exu

agent_name=`echo "$teamcity_agent_name" | tr '[:upper:]' '[:lower:]'`

if [ -z ${teamcity_agent_name} ]; then
  build_dir=`pwd`
else
  agent_name=`echo "$teamcity_agent_name" | tr '[:upper:]' '[:lower:]'`
  build_dir=/data/teamcity_agents/$agent_name/work/$(basename "$PWD")
fi

docker build -t ami-check ./cloud-formation/scripts/check-deprecated-ami

echo 'running container'
docker run \
	--cap-add SYS_ADMIN \
	-e DEPLOY_ROLE_ARN=$DEPLOY_ROLE_ARN \
	-v $build_dir:/build \
	ami-check

pwd
ls -al $build_dir

if [ -s $build_dir/deprecated.txt ]; then
	echo deprecated amis found
	exit 1
fi
