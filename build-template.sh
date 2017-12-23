#!/bin/bash

TEMPLATE="$1"
PARAMS="$2"
IN_TEMPLATE="$TEMPLATE.template.in.json"
OUT_TEMPLATE="$TEMPLATE.template.temp.json"
LINE=`cat $IN_TEMPLATE | grep -n '"params":"here"' |  sed 's/://' | awk '{print $1}'`

head -n$((LINE-1)) $IN_TEMPLATE > $OUT_TEMPLATE
cat $PARAMS >> $OUT_TEMPLATE
tail -n+7 $IN_TEMPLATE >> $OUT_TEMPLATE

