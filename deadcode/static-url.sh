run () {

	regex='https://s3.theasianparent.com/community-theasianparent/'
	regex_escaped="('|\")?https:\/\/s3.theasianparent.com\/community-theasianparent\/"

	files=$( grep -Rl "$regex" --include='*.js' --exclude-dir 'node_modules' --exclude-dir 'build' ./ )

	for val in $files;
	do
		perl -pi -e "s/$regex_escaped/XXXXXXXXXXXXXXXXXXXX/g" "$val"
		#sed -i -E "s/$regex_escaped/$0/g" "$val"
	done

}
run
