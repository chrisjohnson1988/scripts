#!/bin/sh
# NBN Re-lapse (As in REcord timeLAPSE)
#
# Requires cURL and FFMPEG
# Written by Christopher Johnson
#
TITLE="Vascular Plants Database"
DATASETKEY="GA000091"
STARTYEAR="1500"
ENDYEAR="2014"
ORGANISATION="3"

STYLED_TITLE="$TITLE ($STARTYEAR - $ENDYEAR)"
MOVIE_LENGTH="24"

curl "https://staging-data.nbn.org.uk/api/organisations/$ORGANISATION/logo" -o "logo.png"
curl "https://staging-gis.nbn.org.uk/DatasetSpeciesDensity/$DATASETKEY/legend" -o "legend.png"
curl "https://staging-gis.nbn.org.uk/DatasetSpeciesDensity/$DATASETKEY/map?endyear=[${STARTYEAR}-${ENDYEAR}]" -o "#1.png"

filter_complex="[0:v]overlay [maps];\
[maps]overlay=10:10 [logo];\
[logo]overlay=(main_w-overlay_w-10):(main_h-overlay_h-10) [nbnpower];\
[nbnpower]overlay=1000:700[legend];\
[legend]drawtext=fontfile=arial.ttf:fontsize=36:y=30:x=(main_w/2-text_w/2):text='$STYLED_TITLE'[out]"

ffmpeg -f lavfi -i color=c=white:s=1100x1360 -r 24 -start_number $STARTYEAR -i %04d.png -i logo.png -i NBNPower.png -i legend.png -filter_complex "$filter_complex" -map "[out]" -t $MOVIE_LENGTH -c:v libx264 -r 24 -pix_fmt yuv420p "$DATASETKEY.mp4"