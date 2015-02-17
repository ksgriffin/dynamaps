#!/bin/tcsh

set local_root = /nialldata/ksgriffin2/dynamaps/
set remote_root = ${1}
set remote_user = ${2}
set remote_mach = ${3}
set remote_string = ${remote_user}@${remote_mach}:${remote_root}

ssh ${remote_user}@${remote_mach} "mkdir -p ${remote_root}"
ssh ${remote_user}@${remote_mach} "mkdir -p ${remote_root}/colormaps/"

scp ~ksgriffin2/scripts/ncl/lib/dynamaps.ncl ${remote_string}
scp ${local_root}*.dyr ${remote_string}
scp ${local_root}*.dym ${remote_string}
scp ${local_root}*.dyn ${remote_string}
scp ${local_root}/colormaps/* ${remote_string}/colormaps/
