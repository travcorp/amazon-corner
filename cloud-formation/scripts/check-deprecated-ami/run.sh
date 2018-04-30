#!/bin/bash
set -exu

agent_name=`echo "$teamcity_agent_name" | tr '[:upper:]' '[:lower:]'`

echo test this > /data/teamcity_agents/$agent_name/work/$(basename "$PWD")/myfile.txt
echo myfile is ... 
cat /data/teamcity_agents/$agent_name/work/$(basename "$PWD")/myfile.txt


docker build -t ami-check .

echo 'running container'
docker run \
	--cap-add SYS_ADMIN \
	-e DEPLOY_ROLE_ARN=$DEPLOY_ROLE_ARN \
	-v /data/teamcity_agents/$agent_name/work/$(basename "$PWD"):/build \
	ami-check 
