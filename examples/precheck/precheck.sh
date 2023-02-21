#!/usr/bin/ksh
# Copyrights Reserved, (C) 2010 by Kosala Atapattu <kosala@kosala.net>

DIR_PATH=`dirname $0`
HOST_NAME=`uname -n | sed 's/\n//`

# Modify the config/globals file for your settings
. $DIR_PATH/config
. $DIR_PATH/globals

# All the internal functions goes here

out_file="$DIR_PATH/out_files/checklist.${HOST_NAME}.$$.csv"

#include the output file header
echo "#,Check Name,Exception,Details,Action Detail" > $out_file

# For all the modules in module.lst....
for mod in `grep -v '^#' $DIR_PATH/modules.lst.2 | sed 's/ /##./g'`; do
	MOD_ID=`echo $mod | cut -d ":" -f 1`
	MOD_NAME=`echo $mod | cut -d ":" -f 2`
	MOD_DESC=`echo $mod | cut -d ":" -f 3 | sed 's/##./ /g'`
	MOD_REC=`echo $mod | cut -d ":" -f 4 | sed 's/##./ /g'`
	EXP_RET=`echo $mod | cut -d ":" -f 5 | sed 's/##./ /g'`

	[ -x $DIR_PATH/modules/$MOD_NAME ] || chmod 755 $DIR_PATH/modules/$MOD_NAME
	echo "checking $MOD_NAME ..."
	out=`$DIR_PATH/modules/$MOD_NAME `
	ret_code=$?

	[ "x$EXP_RET" == "x" ] && {
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
			echo "!!! Module $MOD_NAME exited with a incorect return code"
			;;
		esac
	} || {
		case $EXP_RET in 
		pass)
			exp_ret=$pass
			;;
		fail)
			exp_ret=$fail
			;;
		info)
			exp_ret=$info
			;;
		erro)	
			exp_ret=$erro
			;;
		apps)
			exp_ret=$apps
			;;
		*)
			echo "!!!Error in modules.lst file. [$EXP_RET]!!!"
			exit 255
			;;
		esac

		[ $exp_ret == $ret_code ] && {
			exception=None 
			mod_rec="-"
		} || {
			mod_rec=$MOD_REC
			case $ret_code in
			$pass|$fail)
				exception=Exception
				;;
			$apps)
				exception=Apps_Task
				;;
			*)
				exception=Module_Error
				;;
			esac
		}
	}

	echo "$MOD_ID,\"$MOD_DESC\",$exception,\"$out\",\"$mod_rec\"" >> $out_file
done

#uuencode $out_file ${HOST_NAME}.csv | mail -s "Check List ${HOST_NAME}" $1 
#[ -f $DIR_PATH/out_file/${HOST_NAME}.mup ] && {
#	uuencode $DIR_PATH/${HOST_NAME}.mup ${HOST_NAME}.mup | mail -s "Invscout Microcode Upload file ${HOST_NAME}" $1 
#}
