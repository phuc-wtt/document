#!/bin/bash

deadimg_run() {

#	Get all svg, png in src/static/icon, src/static/img exclude js files
img_src='./static/icon
./static/img'

all_img=$(
while IFS= read -r line
do
	find "$line" -type f \( -name '*.png' -o -name '*.svg' \) |
		sed "s/^\.//g" | sed "s/.*\///g"
done <<< $img_src
)
#echo "$all_img"


#	For each result find in entire project for its name	
using_img=$(
while IFS= read -r line
do
	grep -ro "$line" ./ --exclude-dir node_modules --exclude-dir .next --exclude-dir out --exclude-dir .git | sed "s/.*://g"
done <<< $all_img
)
#echo "$using_img" 

sorted_using_img=$( echo "$using_img" | sort -u )

echo "$sorted_using_img"

}

deadimg_run
