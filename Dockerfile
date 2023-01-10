FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends wget nco cdo grads

COPY . ./SILAM

WORKDIR ./SILAM
#uncomment below for debug purposues

#RUN ["bash", "solution.sh"]

#copies the dir to local machine, removed to when container runs
#COPY ./output-UKR-pollen/webloads ./output-UKR-pollen/


#docker run {cotainerid} solution.sh && docker cp {containerid}:/SILAM/output-UKR-pollen/webloads ./output-UKR-pollen/

