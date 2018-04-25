FROM ubuntu:16.04

RUN apt-get update && \
	apt-get install -y \
		python3 \
	&& rm -rf /var/lib/apt/lists/* \
	curl -O https://bootstrap.pypa.io/get-pip.py \
	&& python get-pip.py --user \
	pip install awscli --upgrade --user

COPY ./ami-check.sh .

ENTRYPOINT ["./ami-check.sh"]
