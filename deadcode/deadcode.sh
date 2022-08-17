#!/bin/bash

deadcode_run(){
component_name_regex='( |\()[A-Z]\w*'
bracket_regex='export default (\{|\[)'

# files variable
result='result.txt'
unsorted_comps='unsorted-used-comps.txt'
sorted_used_comps='used-comps.txt'
to_delete_line='to_delete_line.txt'
to_del_line_sorted='to_del_line_sorted.txt'

#*********/ COLLECT USED COMPS /******************
#
used_comps_dir_list='./pages
./components'

used_comps_links=$( 
while IFS= read -r line
do
  find "$line" -type f -name '*.?s*' | sed 's/^\.//g'
done <<< $used_comps_dir_list
)

for used_link in $used_comps_links
do
  grep -oE '<[A-Z]\w*' ".$used_link" | 
    sed "s/<//g" >> "$unsorted_comps"
done

sort "$unsorted_comps" | uniq >> "$sorted_used_comps"
#
#*********/ COLLECT USED COMPS /******************


#*********/ COLLECT DEFINED COMPS /******************
#
defined_comps_dir_list='./components'
defined_comps_links=$( 
while IFS= read -r line
do
  find "$line" -type f -name '*.?s*' | sed 's/^\.//g'
done <<< $defined_comps_dir_list
)

for link in $defined_comps_links
do
  matched_line_number=$( 
  grep -nE '^(e| +e)xport default' ".$link" | 
    grep -oE '^[0-9][0-9]*'
  );
  if [ -z "$matched_line_number" ];
  then
    continue;
  fi
  if (( matched_line_number > 0 ));
  then
    bracket_included=$( grep -oE "$bracket_regex" ".$link" );
    first_try=$( 
      sed -n "$matched_line_number p" ".$link" |
        grep -oE "$component_name_regex" |
        tail -1 |
        sed -E "s/( |\()//g" |
        sed "s|$|\:$link|"
    );

    # If bracket included, skip
    if [ ! -z "$bracket_included" ];
    then
      continue
    fi

    #If first_try is not empty
    if [ ! -z "$first_try" ];
    then
      # Got it at first try, do something next
      echo "$first_try" >> "$result"
    else
      #First try is empty, try the next line
      next_line=$(("$matched_line_number" + 1));
      second_try=$( 
        sed -n "$next_line p" ".$link" |
          grep -oE "$component_name_regex" |
          tail -1 |
          sed -E "s/( |\()//g" |
          sed "s|$|\:$link|"
        );
      if [ ! -z "$second_try" ];
      then
        echo "$second_try" >> "$result"
      fi
    fi
  fi
done
#
#*********/ COLLECT DEFINED COMPS /******************


#*********/ FILTER UNUSED /******************
#
while IFS="" read -r p || [ -n "$p" ]
do
  awk -F: "\$1 ~ /$p/ {print NR}" "$result" >> "$to_delete_line"
done < "$sorted_used_comps"

sort -n "$to_delete_line" | uniq >> "$to_del_line_sorted"
to_del_string=$( awk -F\; 'BEGIN { ORS="d;" }; {print $line}' "$to_del_line_sorted" )
sed -i "$to_del_string" "$result";
#
#*********/ FILTER UNUSED /******************


# Clean up excess files
rm "$unsorted_comps"
rm "$sorted_used_comps"
rm "$to_delete_line"
rm "$to_del_line_sorted"

}

deadcode_run



# CASES TO COVER
# ParticlesSchoolPride: export default class Par.. extends React {
# UseKeyPress: import UseKeyPress; ..UseKeyPress(
