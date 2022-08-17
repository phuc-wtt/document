comps="./components/result.txt"
used_comps="./pages/used-comps.txt"

while IFS="" read -r p || [ -n "$p" ]
do
  sed -i "/$p/d" "$comps"
done < "$used_comps"
