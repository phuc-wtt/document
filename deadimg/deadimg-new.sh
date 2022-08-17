#!/bin/bash

deadimg_run() {

#	Get all svg, png in src/static/icon, src/static/img exclude js files
img_src='./static/icon'

all_img_link=$(
while IFS= read -r line
do
	find "$line" -type f \( -name '*.png' -o -name '*.svg' \)
done <<< $img_src
)

all_img=$(
	echo "$all_img_link" | sed "s/^\.//g" | sed "s/.*\///g"
)

#	For each result find in entire project for its name	
using_img=$(
while IFS= read -r line
do
	grep -ro "$line" ./ --exclude-dir node_modules --exclude-dir .next --exclude-dir out --exclude-dir .git | sed "s/.*://g"
done <<< $all_img
)


sorted_using_img=$( echo "$using_img" | sort -u )

echo "$all_img" >> all_img.txt


while IFS= read -r line
do
	sed -i "/$line/d" all_img.txt
done <<< $sorted_using_img


echo "$all_img" >> nagative-result.txt
echo "$all_img_link" >> result.txt

while IFS= read -r line
do
	sed -i "/$line/d" nagative-result.txt
done < all_img.txt


while IFS= read -r line
do
	sed -i "/$line/d" result.txt
done < nagative-result.txt

#	Tidy up
rm all_img.txt
rm nagative-result.txt
	
}

deadimg_run
