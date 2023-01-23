#To make container produce you images run the comand below changin the host directory to needed
#docker run -it -v /var/data:/output-UKR-pollen/webloads silam bash solution.sh

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends wget nco cdo grads

COPY . ./SILAM

WORKDIR ./SILAM




