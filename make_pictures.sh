#!/bin/bash
set -u -e

# put logo if corresponding command is provided
#cd $scriptdir/delme || exit 234

#Acquire and polt

picture_dir=$OUTPUT_DIR/webloads

bash fetch_pollen_fc.sh

nproc=`nproc`

ncfile=$OUTPUT_DIR/${fcdate}/silamFC-$fcdate.nc
#picture_dir=$OUTPUT_DIR/webloads/${fcdate}
picture_dir=$OUTPUT_DIR/webloads
mkdir -p ${picture_dir}
for taxon in alder birch grass mugwort olive ragweed; do
    echo "$gradsnc -blc \'run draw_pollen.gs ${ncfile} ${fcdate} ${taxon} ${picture_dir}/${taxon} cams\'"
done | xargs -P $nproc -IXXX sh -c "XXX"

if [  -z ${PUTLOGOCMD+x}  ]; then
   echo PUTLOGOCMD is not set
else
   echo Putting logos
   ls ${picture_dir}/ | xargs  -I XXX -P $nproc ${PUTLOGOCMD} XXX XXX  
   echo compressing pics
   ls ${picture_dir}/  | xargs  -I XXX -P $nproc convert XXX PNG8:XXX
fi
#echo waiting..
#wait



echo Done with logos!
[ -n "$outsuff" ] && exit 0 #No publish for modified runs


    keepdays=7
    pushd $picture_dir/..
    for d in `find . -type d -name '20??????'|sort|head -n -$keepdays`; do
       echo removing $d
       rm -rf $d
    done
    ii=0
    for d in `find . -type d -name '20??????'|sort -r`; do
       linkname=`printf  %03d $ii`
       rm -f $linkname
       echo ln -s  $d $linkname
       ln -sf  $d $linkname
       ii=`expr $ii + 1`  
    done

    #deploy animation if not yet...
    rsync -av $scriptdir/www/*.html $scriptdir/www/logos .
    if [ !  -d Napit ]; then
     tar -xvf  $scriptdir/www/Napit.tar
    fi

    popd


if $publish; then
    fmi_data_path=$some_location_for_the_website_directory
    echo Syncing $OUTPUT_DIR/webloads to $fmi_data_path
#    mkdir -p $fmi_data_path
    rsync -a --delete  $OUTPUT_DIR/webloads/* $fmi_data_path/
fi
exit 0

