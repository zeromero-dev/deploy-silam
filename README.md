# SILAM Pollen Model - Ukraine layout
#### To install and run on your machine:
- `git clone git@github.com:zeromero-dev/deploy-silam.git` 
- `cd ./deploy-silam`
- `bash requirements.sh`
- `bash solution.sh`\
After sucessfull run it'll output all images in `/output-UKR-pollen/webloads` and create a folder with **data** file with today's date.

#### To run in docker
- `git clone git@github.com:zeromero-dev/deploy-silam.git`
- `cd ./deploy-silam`
- `docker build . -t "silam"`
- `docker run -it --rm -v ${PWD}:/SILAM silam bash solution.sh`

#### FMI SILAM documentation & data access

| Resource | URL |
|---|---|
| SILAM main site | https://silam.fmi.fi/ |
| Pollen forecasts info | https://silam.fmi.fi/pollen.html |
| THREDDS catalog (all datasets) | https://thredds.silam.fmi.fi/thredds/catalog.html |
| THREDDS NCSS docs (query API) | https://docs.unidata.ucar.edu/tds/current/userguide/ |
| Dataset variable browser (v6_1) | https://thredds.silam.fmi.fi/thredds/ncss/grid/silam_europe_pollen_v6_1/dataset.html |
| OPeNDAP metadata (v6_1) | https://thredds.silam.fmi.fi/thredds/dodsC/silam_europe_pollen_v6_1/silam_europe_pollen_v6_1_best.ncd.das |
| SILAM model source code | https://github.com/fmidev/silam-model |

##### Modified by Roman Holubenko
All credits to [SILAM](https://silam.fmi.fi/)
