#!/bin/bash

files=$(find . -type f -name '*.?s*' | sed 's/^\.//g')
result='result.txt'

for link in $files
do
  match_line=$( grep -n "export default" ".$link" | grep -oE "^[0-9]*" )
  next_line=$(( $match_line + 1 ))
  if [ -z "$match_line" ];
    then
      continue
    else
      match_temp=$( awk "NR >= $match_line && NR <= $next_line" ".$link" |
        grep -oE '( |\()[A-Z]\w*' | sed -E 's/( |\()//g')
      echo "$match_temp" >> test.txt

      : '
      match_temp_length=$( echo "$match_temp" | wc -l )

      if (( match_temp_length > 1 ));
      then
        echo "$match_temp" | tail -1 >> result.txt
      else
        echo "$match_temp" >> result.txt
      fi
      '
      

      #echo "$match_temp"
      #echo "---------------------------"

        #awk '{
          #if (FNR == 1) {
            #if ($0 ~ /[A-Z]\w*/)
              #for(i=1;i<=NF;i++){
                #if [ $i =~ [A-Z]\w* ];
                #then
                  #print $i;
                #fi
              #};
            #next;
          #}
          #else 
            #print $1;
        #}'


    #awk "NR >= $match_line && NR <= $next_line {print_result($link,$result)}" ".$link"


    #grep "export default" ".$Line" | grep -oE "[A-Z]\w*[a-z]" | tail -1 >> result.txt ;
    #sed -i "$ s|$|:$Line|" result.txt
  fi
done

                #if [[ $i == $i ]]; then print $i;
