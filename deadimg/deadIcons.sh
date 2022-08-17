#!/bin/bash

deadicon() {

	definedComp=$(
		grep -oP '(?<=component:\s)<\w*(?=\s)' ./components/GeneralComponents/Icons.js
	)
	#echo "$definedComp"
	
	while IFS= read -r line
	do
		exist=''
		exist=$(
			grep -r "$line" ./ --exclude-dir node_modules --exclude-dir out --exclude-dir .next --exclude Icons.js
		)
		if [ -z "$exist" ] # if empty
			then
				echo "$line"
		fi
	done <<< $definedComp

}

deadicon
