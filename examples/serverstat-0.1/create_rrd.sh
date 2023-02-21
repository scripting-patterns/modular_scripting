#!/bin/sh
# Copyrights Reserved, (C) 2008 by Kosala Atapattu <kosala@kosala.net>

DIR_PATH=`dirname $0`
HOST_NAME=`hostname`

# Modify the config file for your settings
. $DIR_PATH/config

# For all the modules in module.lst....
for mod in `grep -v '^#' $DIR_PATH/modules.lst`; do
	MOD_NAME=`echo $mod | awk -F ":" '{print $1}'`
	RRD_FILE=${HOST_NAME}_`echo $mod | awk -F ":" '{print $2}'`
	HEART_BEAT=`expr $INTERVAL \* 2`
	perl -e "use IO::Socket::INET; \$s = IO::Socket::INET->new (PeerAddr => \"$RRD_SERVER\", PeerPort => $RRD_PORT, Proto => \"tcp\"); \$s->send (\"create $RRD_FILE --step $INTERVAL DS:$MOD_NAME:ABSOLUTE:$HEART_BEAT:U:U RRA:AVERAGE:0.5:1:105120\", 1024);"
done
