#!/bin/bash

prefix=`echo $1 |sed 's/\(.*\)\/.*/\1/'`

cat $1 |sed "s/\!\[\](\(.*\))/\!\[\](https\:\/\/github\.com\/jasonGeng88\/blog\/blob\/master\/$prefix\/\1\?raw=true)/g"
