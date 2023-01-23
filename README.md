# SILAM Pollen Model - Ukraine layout
#### To install and run on your machine:
- `git clone git@github.com:zeromero-dev/deploy-silam.git` 
- `cd ./deploy-silam`
- `bash requirements.sh`
- `bash solution.sh`
After sucessfull run it'll output all images in `/output-UKR-pollen/webloads` and create a folder with **data** file with today's date.

#### To run in docker
- `git clone git@github.com:zeromero-dev/deploy-silam.git`
- `cd ./deploy-silam`
- `docker build . -t "silam"`
- `docker run -it -v /your/directory:/output-UKR-pollen/webloads silam bash solution.sh`

##### Modified by Roman Holubenko
All credits to [SILAM](https://silam.fmi.fi/)
