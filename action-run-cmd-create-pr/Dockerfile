FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git curl jq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]