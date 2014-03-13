#!/bin/sh
# NBN Re-lapse (As in REcord timeLAPSE)
#
# Requires cURL, FFMPEG and ImageMagick
# Written by Christopher Johnson
#
TITLE="Ladybird Survey of the UK - Harlequin Ladybird"
TAXONKEY="NHMSYS0000712592"
STARTYEAR="2006"
ENDYEAR="2014"
ORGANISATION="4"

STYLED_TITLE="$TITLE ($STARTYEAR - $ENDYEAR)"
MOVIE_LENGTH="20"

curl "https://staging-data.nbn.org.uk/api/organisations/$ORGANISATION/logo" -o "logo.png"
curl "https://staging-gis.nbn.org.uk/SingleSpecies/$TAXONKEY/legend" -o "legend.png"
curl "https://staging-gis.nbn.org.uk/SingleSpecies/$TAXONKEY/map?datasets=GA000312&endyear=[${STARTYEAR}-${ENDYEAR}]" -o "#1.png"

# Use image magic to dissolve between the years
for ((yearA=$STARTYEAR; yearA<$ENDYEAR; yearA++))
do
   let yearB=$yearA+1
   convert ${yearB}.png -fuzz 0 -fill red -opaque yellow ${yearB}-red.png
   convert ${yearA}.png -fuzz 0 -fill red -opaque yellow ${yearA}-red.png
   for frame in {0..99}
   do
      # Format the frame name to 2 sig figs
      frameFromat=`printf "%02d" $frame`
	  
	  rem=$(($yearA % 2))
	  
	  if [ $rem -eq 0 ]
	  then
		  # Fade between the years and then stamp the image with yearA
		  composite -dissolve ${frame} ${yearB}-red.png ${yearA}.png miff:-| \
		  convert miff:- \
			-pointsize 30 \
			-draw "gravity northeast \
				   fill black text 50,50 '${yearA}'" \
			${yearA}${frameFromat}.png
	   else
	      # Fade between the years and then stamp the image with yearA
		  composite -dissolve ${frame} ${yearB}.png ${yearA}-red.png miff:-| \
		  convert miff:- \
			-pointsize 30 \
			-draw "gravity northeast \
				   fill black text 50,50 '${yearA}'" \
			${yearA}${frameFromat}.png
	   fi
   done
done

filter_complex="[0:v]overlay [maps];\
[maps]overlay=10:10 [logo];\
[logo]overlay=(main_w-overlay_w-10):(main_h-overlay_h-10) [nbnpower];\
[nbnpower]overlay=900:700[legend];\
[legend]drawtext=fontfile=arial.ttf:fontsize=24:y=30:x=(main_w/2-text_w/2):text='$STYLED_TITLE'[out]"

ffmpeg -f lavfi -i color=c=white:s=1100x1360 -i logo.png -r 48 -start_number ${STARTYEAR}00 -i %06d.png -i NBNPower.png -i legend.png -filter_complex "$filter_complex" -map "[out]" -t $MOVIE_LENGTH -c:v libx264 -r 24 -pix_fmt yuv420p "$TAXONKEY.mp4"