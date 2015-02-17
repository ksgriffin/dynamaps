#!/bin/tcsh

#kill anything still running at this time - your 6 hours are up!
kill `ps -ef | grep paramaster.ncl | grep -v grep | awk '{print $2}'`

exit(0)
