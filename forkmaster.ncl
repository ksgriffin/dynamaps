load "~ksgriffin2/scripts/ncl/lib/load.ncl"
;load "~kgriffin/ncl_lib/load.ncl"


begin

  dynamaps_root = "/nialldata/ksgriffin2/dynamaps/"

  date_command = "date"

  sleep_interval = 10
  ;phys_max_procs = systemfunc("grep --count processor /proc/cpuinfo")
  max_procs = 2
  active_procs = 0
  max_imp = 100
  min_imp = 1

  ;fhr_list=(/0,6,12,18,24/)
  fhr_list = ispan(6,12,6)
  ;prod_list=systemfunc("ls -1 "+dynamaps_root+"*.dyn")
  ;prod_list=("pv_jet_irrwind.dyn")
  ;prod_list=("pw_hght700.dyn")
  prod_list="precip_cat.dyn_temp"
  num_fhrs = dimsizes(fhr_list)
  num_prods = dimsizes(prod_list)
  num_things = num_fhrs*num_prods

  checklist = new(num_things,logical)
  prodlist = new(num_things,string)
  fhrlist = new(num_things,integer)
  implist = new(num_things,integer)
  checklist_ind = 0

  active_logs = new(max_procs,string)

  timeUnits = "hours since 1800-01-01 00:00:00.0"
  fcycle = calc_date_gfscycle(timeUnits)
  str_date = cd_string(fcycle,"%y%N%D")
  str_cycle = cd_string(fcycle,"%H")
  ; force the cycle
  str_cycle = "12"

  fhrlogs = dynamaps_root+"flogs/"+str_date+"_"+str_cycle+"_f"+sprinti("%0.3i",fhr_list)+".txt"

  print(fhrlogs)

  do i=0,num_fhrs-1
    do j=0,num_prods-1
      idx = (i*num_prods)+j
      ;print(idx+"")
      checklist(idx) = False
      prodlist(idx) = prod_list(j)
      fhrlist(idx) = fhr_list(i)
      implist(idx) = 5
    end do
  end do

  do while(any(checklist.eq.False).or.(active_procs.gt.0)) 
    if((active_procs.lt.max_procs).and.(checklist_ind.lt.num_things)) then
      ; ugly line below gets the indes of the fhr for the next product
      ;print(fhr_list+" "+fhrlist(checklist_ind))
      fhr_ind = ind(fhr_list.eq.fhrlist(checklist_ind))
      ;print(checklist_ind+" "+fhrlist(checklist_ind)+" "+fhr_ind+" ")
      ;print(fhrlogs(fhr_ind))
      trigger_string = "Derived GFS file produced."
      ;log_made = isfilepresent(fhrlogs(fhr_ind))
      log_made = fileexists(fhrlogs(fhr_ind))
      if(log_made) then 
        ncdone = any(isStrSubset(str_join(asciiread(fhrlogs(fhr_ind),-1,"string")," "),trigger_string))
        print("Log file made, no trigger string.") 
      else
        ncdone = False
        print("Log file not yet made.")
      end if

      if(ncdone) then ;CHECK for fhr completed in log
      prod_file = prodlist(checklist_ind) 
      fhr = fhrlist(checklist_ind)
      randms = toint(systemfunc(date_command+" -u +%N"))/1000
      templogfile = dynamaps_root+"pre_prod_log_"+randms+".log"
      ;print(prod_file+" "+fhr)
      ; ** ncl -n works to avoid the (0) in front of each print in the log file.
      print(templogfile+"")
      system("ncl -n "+dynamaps_root+"pre_prod.ncl 'prod_file="+str_get_dq()+prod_file+str_get_dq()+"' date="+str_date+" cycle="+str_cycle+" fhr="+fhr+" > "+templogfile+" &")
      missing_ind := ind(ismissing(active_logs))
      active_logs(missing_ind(0)) = templogfile
      checklist(checklist_ind) = True
      active_procs = active_procs + 1
      checklist_ind = checklist_ind + 1
      print("started running: "+prod_file+" at fhr "+fhr+", now "+active_procs+" active, checklist #"+checklist_ind+" of "+num(.not.checklist))
      else
        print("Waiting on file for FHR: "+fhrlist(checklist_ind))
      end if ;check for FHR end.
    else
      print("still running")
    end if
    if((active_procs.ge.max_procs).or.(checklist_ind.ge.num_things).or.(.not.ncdone)) then
      system("sleep "+sleep_interval)
    end if

    active_procs = check_active_logs(active_logs)
    print("After check, "+active_procs+" are active")
    ;print(active_logs(0)+" "+active_logs(1)+" "+active_logs(2)+" "+active_logs(3))
  end do
  print("All plots completed.")

end
