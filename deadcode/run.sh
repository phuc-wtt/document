#!/bin/bash

Lines=$(find . -type f -name '*.?s*' | sed 's/^\.//g')

for Line in $Lines
do
  grep 'export default' ".$Line" | grep -oE -m1 '[A-Z]\w*[a-z]' | tail -1 >> result.txt ;
  sed -i "$ s|$|:$Line|" result.txt
done

