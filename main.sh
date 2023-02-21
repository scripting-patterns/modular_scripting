#!/bin/bash

DIR_PATH=$(dirname $0)
HOST_NAME=$(uname -n | sed 's/\n//')

# Modify the config/globals file for your settings
. $DIR_PATH/config
. $DIR_PATH/globals

# All the internal functions goes here

out_file="$DIR_PATH/checklist.${HOST_NAME}.$$.csv"

#include the output file header
echo "ID,Check Name,Output,Status" > $out_file

# For all the modules in module.lst....
for mod in `grep -v '^#' $DIR_PATH/modules.lst | sed 's/ /##./g'`; do
	MOD_ID=$(echo $mod | cut -d ":" -f 1)
	MOD_NAME=$(echo $mod | cut -d ":" -f 2 | sed 's/##./ /g')
	MOD_DESC=$(echo $mod | cut -d ":" -f 3 | sed 's/##./ /g')

	[ -x $DIR_PATH/modules/$MOD_ID ] || { 
		chmod 755 $DIR_PATH/modules/$MOD_ID
	}
	echo "checking $MOD_ID ..."
	out=$($DIR_PATH/modules/$MOD_ID)
	ret_code=$?

	case $ret_code in 
	$pass)
		exception=None
		;;
	$fail)
		exception=Exception
		;;
	$info)
		exception=Info
		;;
	*)
		exception=Error
		echo "!!! Module $MOD_ID exited with a incorect return code"
		;;
	esac

	echo "$MOD_ID,\"$MOD_NAME\",\"$out\",\"$exception\"" >> $out_file
done

