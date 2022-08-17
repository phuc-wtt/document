#!/bin/bash

links=$(find . -type f -name '*.?s*' | sed 's/^\.//g')
component_name_regex='( |\()[A-Z]\w*'
bracket_regex='export default (\{|\[)'
result='result.txt'

for link in $links
do
  matched_line_number=$( grep -n 'export default' ".$link" | grep -oE '^[0-9][0-9]*' );
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


# SECOND TRY - TAIL -1
