FROM ubuntu:16.04

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
		python3 \
		curl
RUN python3 --version

RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN	python3 get-pip.py
RUN export PATH=~/usr/bin:$PATH
RUN	pip install awscli --upgrade

COPY ./s3-check.sh .
ADD https://raw.githubusercontent.com/travcorp/amazon-corner/master/cloud-formation/scripts/aws-assume-role.sh .

RUN chmod +x ./s3-check.sh 
RUN chmod +x ./aws-assume-role.sh 

ENTRYPOINT ["./ami-check.sh"]
