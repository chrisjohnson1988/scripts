#!/bin/sh
# NBN Re-lapse (As in REcord timeLAPSE)
#
# Requires cURL and FFMPEG
# Written by Christopher Johnson
#
TITLE="Harlequin Ladybird"
TAXONKEY="NHMSYS0000712592"
STARTYEAR="1999"
ENDYEAR="2014"
ORGANISATION="3"

STYLED_TITLE="$TITLE ($STARTYEAR - $ENDYEAR)"
MOVIE_LENGTH="8"

curl "https://staging-gis.nbn.org.uk/SingleSpecies/$TAXONKEY/legend" -o "legend.png"
curl "https://staging-gis.nbn.org.uk/SingleSpecies/$TAXONKEY/map?endyear=[${STARTYEAR}-${ENDYEAR}]" -o "#1.png"

filter_complex="[0:v]overlay [maps];\
[maps]overlay=(main_w-overlay_w-10):(main_h-overlay_h-10) [nbnpower];\
[nbnpower]overlay=900:700[legend];\
[legend]drawtext=fontfile=arial.ttf:fontsize=36:y=30:x=(main_w/2-text_w/2):text='$STYLED_TITLE'[out]"

ffmpeg -f lavfi -i color=c=white:s=1100x1360 -r 3 -start_number $STARTYEAR -i %04d.png -i NBNPower.png -i legend.png -filter_complex "$filter_complex" -map "[out]" -t $MOVIE_LENGTH -c:v libx264 -r 24 -pix_fmt yuv420p "$TAXONKEY.mp4"