#!/bin/bash

# Script to download silam European pollen runs from FMI SILAM thredds setup
# Also remaps grid, and removes confusing attributes originating from thredds
# (c)opyleft Roux aka Rostislav DOT Kouznetsov AT fmi.fi 

# Enjoy!


set -u 
set -e
ncks=ncks

basedate=${fcdate}

mkdir -p $OUTPUT_DIR/${fcdate}
cd $OUTPUT_DIR/${fcdate}
outf="silamFC-$basedate.nc"

varlist="cnc_POLLEN_ALDER_m22,cnc_POLLEN_BIRCH_m22,cnc_POLLEN_GRASS_m32,cnc_POLLEN_MUGWORT_m18,cnc_POLLEN_OLIVE_m28,cnc_POLLEN_RAGWEED_m18"

#bbox="-d lon,32.1,43. -d lat,50.2,62.1"


# mseake lates
run=`date -u -d $basedate +"%FT00:00:00Z"`
startdate=`date -u -d $basedate +"%FT01:00:00Z"`
enddate=`date -u -d "120 hours $basedate" +"%FT00:00:00Z"`
version="v5_8_2"
URL="https://silam.fmi.fi/thredds/ncss/silam_europe_pollen_${version}/runs/silam_europe_pollen_${version}_RUN_${run}"
##https://silam.fmi.fi/thredds/ncss/silam_europe_pollen_v5_8_1/runs/silam_europe_pollen_v5_8_1_RUN_2022-07-10T00:00:00Z?var=cnc_POLLEN_ALDER_m22&var=cnc_POLLEN_BIRCH_m22&var=cnc_POLLEN_GRASS_m32&var=cnc_POLLEN_MUGWORT_m18&var=cnc_POLLEN_OLIVE_m28&var=cnc_POLLEN_RAGWEED_m18&horizStride=1&time_start=2022-07-10T01%3A00%3A00Z&time_end=2022-07-15T00%3A00%3A00Z&timeStride=1&vertCoord=1&accept=netcdf



## The command that fails, but leaves trace in threds logs, so I could grep your request from there

if [ ! -f $outf ]; then
  subset="&maxy=0&minx=12&maxx=28&miny=-15"
  wget --no-check-certificate "$URL?var=${varlist}${subset}&horizStride=1&time_start=${startdate}&time_end=${enddate}&timeStride=1&vertCoord=1&accept=netcdf4&email=$email" -O ${outf}-tmp.nc

  # Some attributes are just bulky, coordinates, pole_lat, and  pole_lon confuse python reader and cdo
  attcmd="-a _CoordinateModelRunDate,global,c,c,$run -a history,global,d,,, -a History,global,d,,, -a history_of_appended_files,global,d,,, -a SIMULATION_START_DATE,global,c,c,$run, -a coordinates,,d,,, -a pole_lat,global,d,,, -a pole_lon,global,d,,, " 
  ncatted -h  $attcmd ${outf}-tmp.nc
  cdo -f nc4 -z zip1 --no_history remapbil,${scriptdir}/UKR-rll.grid ${outf}-tmp.nc ${outf}-tmp2.nc 
  mv ${outf}-tmp2.nc ${outf}
  rm  ${outf}-tmp.nc
fi


