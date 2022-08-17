pages=$( find . -type f -name '*.?s*' | sed 's/^\.//g' )
unsorted_comps='unsorted-used-comps.txt'
sorted_comps='used-comps.txt'


for page in $pages
do
  grep -oE '<[A-Z]\w*' ".$page" | grep -oE '[A-Z]\w*' >> "$unsorted_comps" ;
done

sort "$unsorted_comps" | uniq -u >> "$sorted_comps"
rm "$unsorted_comps"
