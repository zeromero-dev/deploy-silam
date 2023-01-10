FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends wget nco cdo grads
# RUN apk update && apk add --no-cache wget python3 nco grads

COPY . ./SILAM

WORKDIR ./SILAM

RUN ["bash", "solution.sh"]
