load "~ksgriffin2/scripts/ncl/lib/load.ncl"
;load "~kgriffin/ncl_lib/load.ncl"


begin

  dynamaps_root = "/nialldata/ksgriffin2/dynamaps/"

  date_command = "date"

  sleep_interval = 4
  ;phys_max_procs = systemfunc("grep --count processor /proc/cpuinfo")
  machines = get_all_machine_info()  
  max_procs = 0
  do i=0,ListCount(machines)
    max_procs = max_procs + machines[i]@max_procs
  end do

  max_imp = 100
  min_imp = 1

  ;print(user+"@"+address+" has "+active_procs+" of "+max_procs+" active.")
  exit 

  sync_remote_files(dynamaps_root)
  print("Remote file sync complete.")
  init_products(proc_id,dynamaps_root)

  active_logs = new(max_procs,string)

  ;fhr_list=(/0,6,12,18,24/)
;;;;  fhr_list = ispan(0,6,6)
;;;;  prod_list=systemfunc("ls -1 "+dynamaps_root+"*.dyn")
;;;;  ;prod_list=("dt_theta.dyn")
;;;;  num_fhrs = dimsizes(fhr_list)
;;;;  num_prods = dimsizes(prod_list)
;;;;  num_things = num_fhrs*num_prods

;;;;  checklist = new(num_things,logical)
;;;;  prodlist = new(num_things,string)
;;;;  fhrlist = new(num_things,integer)
;;;;  implist = new(num_things,integer)
;;;;  checklist_ind = 0

  active_logs = new(max_procs,string)

  timeUnits = "hours since 1800-01-01 00:00:00.0"
  fcycle = calc_date_gfscycle(timeUnits)
  str_date = cd_string(fcycle,"%y%N%D")
  str_cycle = cd_string(fcycle,"%H")
  ; force the cycle
  ;str_date = "141118"
  ;str_cycle = "18"
  rmcycle = fcycle - (14*24) ; 14 days in  hours
  rmcycle@units = fcycle@units
  rm_date = cd_string(rmcycle,"%y%N%D%H")

  if(proc_id.eq.0) then
    print("Removing "+dynamaps_root+rm_date)
    system("rm -Rf "+dynamaps_root+rm_date)
  end if
;;;;  fhrlogs = "/Users/kgriffin/realtime/flogs/"+str_date+"_"+str_cycle+"_f"+sprinti("%0.3i",fhr_list)+".txt"
  fhrlog_base = dynamaps_root+"flogs/"+str_date+"_"+str_cycle+"_f" ;add number and .txt later

;;;;  do i=0,num_fhrs-1
;;;;    do j=0,num_prods-1
;;;;      idx = (i*num_prods)+j
;;;;      ;print(idx+"")
;;;;      checklist(idx) = False
;;;;      prodlist(idx) = prod_list(j)
;;;;      fhrlist(idx) = fhr_list(i)
;;;;      implist(idx) = 5
;;;;    end do
;;;;  end do

  next_prod = "" ; initialize the next product, will be 0 when list is empty
  num_done = 0 ; number of processors that have nothing left to do
  alldone = False ; whether everything is finished
  imggen_triggered = False

;;;;  do while(any(checklist.eq.False).or.(active_procs.gt.0)) 
;;;;    if((active_procs.lt.max_procs).and.(checklist_ind.lt.num_things)) then
  do while((.not.alldone).or.(active_procs.gt.0))
    if((active_procs.lt.max_procs).and.(next_prod.ne."0")) then
      if(imggen_triggered)then ;only get new product if image gen script was sent out
        this_proc_id = proc_id+"."+min(ind(ismissing(active_logs)))
        next_prod = take_product(this_proc_id,dynamaps_root)
        imggen_triggered = False   ;new product, set back to 'not sent'
      end if
      if(next_prod.eq."0") then ;make this the last time in the loop
        alldone = True
      else ; if there is a legit next product to handle, do it...
      prod_file = parse_product(next_prod,"name")
      fhr = parse_product(next_prod,"fhr") ;get the fhr of the next product
;;;;      ; ugly line below gets the indes of the fhr for the next product
;;;;      ;print(fhr_list+" "+fhrlist(checklist_ind))
;;;;      fhr_ind = ind(fhr_list.eq.fhrlist(checklist_ind))
;;;;      ;print(checklist_ind+" "+fhrlist(checklist_ind)+" "+fhr_ind+" ")
;;;;      ;print(fhrlogs(fhr_ind))
;;;;      fhr_ind = ind(fhr_list.eq.fhr)
      this_fhrlog = fhrlog_base+sprinti("%0.3i",fhr)+".txt"
      trigger_string = "Derived GFS file produced."
      ;log_made = isfilepresent(fhrlogs(fhr_ind))
      log_made = fileexists(this_fhrlog)
      if(log_made) then 
        ncdone = any(isStrSubset(str_join(asciiread(this_fhrlog,-1,"string")," "),trigger_string))
        print("Log file made...") 
      else
        ncdone = False
        print("Log file not yet made.")
      end if

      if(ncdone) then ;CHECK for fhr completed in log
        print("...and trigger string! GO!")
;;;;        prod_file = prodlist(checklist_ind) 
;;;;        fhr = fhrlist(checklist_ind)
        randms = toint(systemfunc(date_command+" -u +%N"))/1000 ;generate a random number
        templogfile = dynamaps_root+"logtemp_"+prod_file+"_"+fhr+"_"+randms+".log"
        prod_mach = get_next_machine(machines)
        ;print(prod_file+" "+fhr)
        ; ** ncl -n works to avoid the (0) in front of each print in the log file.
        ;system("ncl -n "+dynamaps_root+"pre_prod.ncl 'prod_file="+str_get_dq()+prod_file+str_get_dq()+"' date="+str_date+" cycle="+str_cycle+" fhr="+fhr+" > "+templogfile+" &")
        ;system("ssh screen -d -m")
        print("IMAGE PROD NOT SENT, but this is in its place.")
        imggen_triggered = True
        missing_ind := ind(ismissing(active_logs))
        active_logs(missing_ind(0)) = templogfile
;;;;        checklist(checklist_ind) = True
        active_procs = active_procs + 1
;;;;        checklist_ind = checklist_ind + 1
;;;;        print("started running: "+prod_file+" at fhr "+fhr+", now "+active_procs+" active, checklist #"+checklist_ind+" of "+num(.not.checklist))
        print("started running: "+prod_file+" at fhr "+fhr+", now "+active_procs+" active")
      else
        print("Waiting on file for FHR: "+fhr)
      end if ;check for FHR end.
      end if ; for the else on next_prod=0 check.
    else
      print("still running")
    end if
;;;;    if((active_procs.ge.max_procs).or.(checklist_ind.ge.num_things).or.(.not.ncdone)) then
    if((active_procs.ge.max_procs).or.alldone.or.(.not.ncdone))then
      system("sleep "+sleep_interval)
    end if

    active_procs = check_active_logs(active_logs)
    print("After check, "+active_procs+" are active")
    if(any(ismissing(active_logs)))then
      do ii=0,max_procs-1
        if(ismissing(active_logs(ii)))then
          print("Returning "+proc_id+"."+ii)
          ; everything that goes missing has been successfully returned, so ret_code = 0 here
          return_product(proc_id+"."+ii,0,dynamaps_root)
        end if
      end do
    end if
    ;print(active_logs(0)+" "+active_logs(1)+" "+active_logs(2)+" "+active_logs(3))
  end do
  print("All plots completed.")

end
