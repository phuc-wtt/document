#!/bin/bash

icon_extract () {
	rm -rf result-icon/
	mkdir result-icon/

	#	Read multi line from user
	echo "List all component's name to exclude it, Ctrl + d to finish inputting:"
	while read line
	do
		to_exclude_comps=("${to_exclude_comps[@]}" $line)
	done

	cp ./Icons.js ./Icons-temp.js

	for i in "${to_exclude_comps[@]}"
	do
		sed -i "/$i/d" ./Icons-temp.js
	done

	export_line=$( awk '/export const / {print FNR}' ./Icons-temp.js )

	echo "$export_line" >> export_line.txt

	line_range=$(
		while IFS= read -r line
		do
			awk "NR>=${line} && /^\)/ {print (${line} + 1), (FNR - 1); exit}" ./Icons-temp.js
		done <<< "$export_line"
	)

	#echo "$line_range"

	while IFS= read -r line
	do
		head_line_num=$( echo "$line" | grep -oE '^[0-9]*' )
		tail_line_num=$( echo "$line" | grep -oE '[0-9]*$' )
		name_line_num=$((head_line_num - 1))
		file_name=$(
			awk "NR==${name_line_num} {print}" ./Icons-temp.js |
				grep -oP '(?<=export\sconst\s)\w*(?=\s=)' |
				sed -E "s/[A-Z]/-\0/g" | sed 's/^-//' |
				sed 's/[A-Z]/\L&/g' | sed 's/$/.svg/'
		)

		svg_body=$(
			awk "NR>=${head_line_num} && NR<=${tail_line_num} {print}" ./Icons-temp.js |
			# delete <title>
			sed '/title/d' |
			#	replace className
			sed -E 's/className=\{.*\}/class="icon-default"/g' |
			#	replace viewBox
			sed -E 's/viewBox=\{`(.*)`}/viewBox="\1"/g' |
			#	replace height
			sed -E 's/height=\{.*\}/height="24"/g' |
			#	replace width
			sed -E 's/width=\{.*\}/width="24"/g' |
			# remove fill
			sed -E '/fill=\{/d' |
			#add fill
			sed 's/<svg/<svg\n    fill="currentColor"/g'
		)

		#echo "$svg_body"
		#echo "$svg_body" >> "result-icon/$file_name"


	done <<< "$line_range"


	###	Replace <svg> to <i> in Icons.js ###
	extracted_comp=$(
		while read line
		do
			#echo "$line"
			awk "NR==$line {print}" ./Icons-temp.js |
				sed 's/^export\sconst\s//g' |
				sed 's/\s.*//g'
		done < export_line.txt
	)

	while IFS= read -r line
	do
		className=$( 
			echo "$line" | sed -E "s/[A-Z]/-\0/g" |
				sed 's/^-//' | sed 's/[A-Z]/\L&/g' |
				sed 's/^/svg-/g'
		)
		tag="<i className={\`${className} ${className}-dims icon-default \${props?.className || ''}\`} style={{width: props?.width || sizeDefault, height: props?.height || sizeDefault}} ></i>"

		target_comp_line=$(grep -n -m 1 "$line" Icons.js | sed 's/:.*//g')
		target_comp_range=$(
			while IFS= read -r line
			do
				awk "NR>=${line} && /^\)/ {print (${line} + 1), (FNR - 1); exit}" ./Icons.js
			done <<< "$target_comp_line"
		)
		target_start_line=$( echo "$target_comp_range" | grep -oE '^[0-9]*' )
		target_end_line=$( echo "$target_comp_range" | grep -oE '[0-9]*$' )

		sed -i "${target_start_line},${target_end_line}d" Icons.js
		sed -i -E "${target_start_line}i ${tag}" Icons.js
	done <<< "$extracted_comp"




	# Tidy up
	rm Icons-temp.js
	rm export_line.txt

	echo "Done!"
}



icon_extract
