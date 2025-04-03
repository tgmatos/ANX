#!/bin/fish
set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH ~/Workspace/git/home/build/shmif/
#Xarcan -redirect -nolisten tcp -nolisten local -displayfd 33 :1 33> xarcan 2> $HOME/xarcan_log

#FUNCIONA
#Xarcan -nolisten tcp -nolisten local -displayfd 33 -exec enlightenment_start 33> xarcan 2> $HOME/xarcan_log

#FUNCIONA
#Xarcan -nolisten tcp -exec enlightenment_start

#FUNCIONA
E_NO_DBUS_SESSION=1 Xarcan -nolisten tcp -exec enlightenment_start
