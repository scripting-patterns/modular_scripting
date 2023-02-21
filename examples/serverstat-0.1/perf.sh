#!/bin/sh
# Copyrights Reserved, (C) 2008 by Kosala Atapattu <kosala@kosala.net>

DIR_PATH=`dirname $0`
HOST_NAME=`hostname`

# Modify the config file for your settings
. $DIR_PATH/config

# For all the modules in module.lst....
for mod in `grep -v '^#' $DIR_PATH/modules.lst`; do
	DATE=`date +%s`
	echo $mod
	MOD_NAME=`echo $mod | awk -F ":" '{print $1}'`
	echo "Mod name: $MOD_NAME"
	RRD_FILE=${HOST_NAME}_`echo $mod | awk -F ":" '{print $2}'`
	echo "RRD File : $RRD_FILE"
	. $DIR_PATH/modules/$MOD_NAME
	VAL=`$MOD_NAME`
	COUNT=0
	while [ : ] ; do
		perl -e "use IO::Socket::INET; \$s = IO::Socket::INET->new (PeerAddr => \"$RRD_SERVER\", PeerPort => $RRD_PORT, Proto => \"tcp\"); \$s->send (\"update $RRD_FILE $DATE:$VAL\", 1024);" && break
		COUNT=`expr $COUNT + 1`
		[ $COUNT == 5 ] && break
		sleep 5
	done
done
