#!/bin/bash
set -exu

agent_name=`echo "$teamcity_agent_name" | tr '[:upper:]' '[:lower:]'`


MOUNTDIR=/data/teamcity_agents/$agent_name/work/check-deprecated-ami

echo myfile is at $MOUNTDIR 
echo this is what is in work...
# ls -l /data/teamcity_agents/$agent_name/work/



echo checking dir exists ... we are at $PWD
ls $MOUNTDIR
echo hello world > $MOUNTDIR/myfile.txt


docker build -t ami-check .

echo 'running container'
docker run \
	--cap-add SYS_ADMIN \
	-e DEPLOY_ROLE_ARN=$DEPLOY_ROLE_ARN \
	-v $MOUNTDIR:/build \
	ami-check 
