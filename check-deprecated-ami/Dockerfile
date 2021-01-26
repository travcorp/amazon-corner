FROM alpine:3.13

RUN apk -v --update add \
        python3 \
        py3-pip \
        bash \
        jq \
        && \
    pip install --upgrade awscli && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

COPY ./ami-check.sh .
ADD https://raw.githubusercontent.com/travcorp/amazon-corner/master/cloud-formation/scripts/aws-assume-role.sh .

RUN chmod +x ./ami-check.sh 
RUN chmod +x ./aws-assume-role.sh 

ENTRYPOINT ["./ami-check.sh"]
