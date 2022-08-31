function silamaor(args)
# Drawing the SILAM output 
# USAGE:  silamaor ctlFName AnalString taxon OutputFile

InputNC   = subwrd(args,1)
fcdate = subwrd(args,2)
taxon      = subwrd(args,3)
OutputPref =  subwrd(args,4)
mpdset = subwrd(args,5)

'reinit'



#some colors
'set rgb 22 254 254 254'
'set rgb 21 190 190 190'
'set rgb 20 220 220 220'
'set rgb 23 0 205 254'
'set rgb 24 0 220 0'
'set rgb 25 120 120 120'
'set rgb 26 60 60 60'
'set rgb 27 30 30 30'
#greens
'set rgb 31 50 254 50'
'set rgb 32 0 220 0'
'set rgb 33 0 190 0'
'set rgb 34 0 160 0'
'set rgb 35 0 130 0'
'set rgb 36 0 110 0'
'set rgb 37 0 90 50'
#oranges
'set rgb 41 254 200 0'
'set rgb 42 254 170 0'
'set rgb 43 254 140 0'
'set rgb 44 254 110 0'
'set rgb 45 254 80 0'
'set rgb 46 254 50 0'
'set rgb 47 254 0 0'
#light blue
'set rgb 50 150 240 200' 

say "mpdset:" mpdset
bigmapcmd=''
smallmapcmd=''
if (strlen(mpdset) >0)
   say "Setting:" mpdset
   'set mpdset 'mpdset
*        set mpt type color style thickness   
* coaslines+lakes+islands
   'set mpt 1 1 1 0.5'
* grid dashed
   'set mpt 2 1 5 0.5'
** Inland borders thick dark green
*   'set rgb  250  0  50  0'
*   'set mpt 3 15 1 2'
*   'set mpt 3 250 1 2'
* Inland borders thick dashed
   'set mpt 3 1 3 2'
* rivers -- blue 
   'set rgb  250 140 140 230'
*   'set mpt 4 4 1 0.5'
   bigmapcmd='set mpt 4 250 1 0.5'
   smallmapcmd='set mpt 4 off'
endif

#
# Variables, all possible
#
#
# Specifics of the taxa
#
if (taxon = "alder")
    ccols_cnc = "0 20 3 10 7 12 8 2 6 9"
    clevs_cnc = "0.1 1 5 10 25 50 100 500 1000"
    vCnc = 'cnc_pollen_alde'
else
  if (taxon = "birch")
    ccols_cnc = "0 20 3 10 7 12 8 2 6 9"
    clevs_cnc = "1 5 10 25 50 100 500 1000 5000"
    vCnc = 'cnc_pollen_birc'
  else
    if (taxon = "grass")
      ccols_cnc = "0 20 3 10 7 12 8 2 6 9"
      clevs_cnc = "1 5 10 25 50 100 500 1000 5000"
      vCnc = 'cnc_pollen_gras'
    else
      if (taxon = "mugwort")
        ccols_cnc = '0 20 3 10 7 12 8 2 6 9'
        clevs_cnc = '0.1 1 5 10 25 50 100 500 1000'
        vCnc = 'cnc_pollen_mugw'
      else
        if (taxon = "olive")
          ccols_cnc = "0 20 3 10 7 12 8 2 6 9"
          clevs_cnc = "0.1 1 5 10 25 50 100 500 1000"
          vCnc = 'cnc_pollen_oliv'
        else
          if (taxon = "ragweed")
            ccols_cnc = "0 20 3 10 7 12 8 2 6 9"
            clevs_cnc = "0.1 1 5 10 25 50 100 500 1000"
            vCnc = 'cnc_pollen_ragw'
          else
            say 'Wrong taxon ' taxon
            'quit'
          endif
        endif
      endif
    endif
  endif
endif

say InputNC
'sdfopen  'InputNC

*'set gxout grfill'
'set gxout shaded'
*'set mpdset lowhir'
*'set mpdset world_map'
*'set mproj nps'
'set z 1'
'set xlab off'
'set ylab off'


'q file'
sizeLine = sublin(result,5)
timeSize = subwrd(sizeLine,12)

tStep=1
 
while (tStep <= timeSize)  
  'c'
  'set t 'tStep
  'query dims'
  rec5 = sublin(result,5)
  DateTime = subwrd(rec5,6)

#------------------------------- Concentration
#
  'set ccols 'ccols_cnc
  'set clevs 'clevs_cnc
  'set grads off'
  'set frame off'
  bigmapcmd

  'd 'vCnc
  'draw title SILAM model forecast: 'taxon' pollen\ (#/m3) 'DateTime
  'cbar'

  outf=OutputPref'_'math_format('%03.0f',tStep-1)'.png'
  'printim 'outf' x850 y655 white'
  say outf ' Done.'

  tStep = tStep+1
*  break
endwhile
'quit'

