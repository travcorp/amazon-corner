#! /bin/bash
if [ -z ${teamcity_agent_name} ]; then
  build_dir=`pwd`
else
  agent_name=`echo "$teamcity_agent_name" | tr '[:upper:]' '[:lower:]'`
  build_dir=/data/teamcity_agents/$agent_name/work/$(basename "$PWD")
fi

docker build -t ami-check .

echo 'running container'
docker run \
	-e DEPLOY_ROLE_ARN=$DEPLOY_ROLE_ARN \
	-v /data/teamcity_agents/$agent_name/work/$(basename "$PWD"):/build \
	ami-check 
