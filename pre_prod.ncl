;load "/Users/kgriffin/ncl_lib/load.ncl"
load "/home/ksgriffin2/scripts/ncl/lib/load.ncl"

; This will be the generic image-producing script for any dyna-based scripts
; ---------------------
; Idea here is to read from a generic source file and set resources based on
; these source files. Will also plot for a list of regions as defined in
; similarly-formatted source files

; *********
; Command-line arguments from master scripts
; *********
; $1 - prod_file = name of .dyn file (a product)
; $2 - date =  as yymmdd
; $3 - cycle =  as hh
; $4 - fhr =  as fff
; ************************************

begin

  ;prod_file = "precip_850.dyn"
  ;date = 140827
  ;cycle = 12
  ;fhr = 24

  dynamaps_root = "/nialldata/ksgriffin2/dynamaps/"
  data_loc = "/nialldata/ksgriffin2/realtime/data/new_gfs_nc/"

  ; open the file associated with the correct forecast hour
  ; this might need to be other files depending on where other grids are calc/stored
  strfhr = sprinti("%0.3i",fhr)
  strcycle = sprinti("%0.2i",cycle)

  this_fhrlog = dynamaps_root+"flogs/"+date+"_"+strcycle+"_f"+strfhr+".txt"
 
  print(data_loc+"derivedgfs"+date+"_"+strcycle+"_F"+strfhr+".nc")
  file1 = addfile(data_loc+"gfs"+date+"_"+strcycle+"_F"+strfhr+".nc","r")
  file2 = addfile(data_loc+"derivedgfs"+date+"_"+strcycle+"_F"+strfhr+".nc","r")
  ; reading in/initializing product resources
  ;prod = asciiread("surface_temp_mslp.dyn",-1,"string")
  ;prod = asciiread("temp850_hght.dyn",-1,"string")
  ;prod = asciiread("precip_850.dyn",-1,"string")
  ;prod = asciiread(prod_file,-1,"string")
  num_overlays = read_product_file(prod_file,"num_overlays",dynamaps_root) 
  
  plot_name = read_product_file(prod_file,"plot_name",dynamaps_root)
  start_fhr = read_product_file(prod_file,"start_fhr",dynamaps_root)
  end_fhr = read_product_file(prod_file,"end_fhr",dynamaps_root)
  print("prod: "+plot_name+" start: "+start_fhr+" end: "+end_fhr+" fhr: "+fhr)
  if((start_fhr.gt.fhr).or.(end_fhr.lt.fhr))then
    print("Not supposed to make "+plot_name+" at FHR "+strfhr)
    print("PROD-DONE.")
    system("echo Image production of "+plot_name+" at F"+strfhr+" done at `date -u` >> "+this_fhrlog)
    exit()
  end if
  file_type = read_product_file(prod_file,"file_type",dynamaps_root)
  prod = read_product_file(prod_file,"resources",dynamaps_root)
  if(.not.(file_type.eq."ps".or.file_type.eq."eps"))then
    file_type@wkWidth = 2000 
    file_type@wkHeight = 2000
  end if
  num_resources = dimsizes(prod)
  
  if(.not.fileexists(dynamaps_root+date+strcycle)) then
    system("mkdir "+dynamaps_root+date+strcycle)
  end if
  if(.not.fileexists(dynamaps_root+date+strcycle+"/"+plot_name)) then
    system("mkdir "+dynamaps_root+date+strcycle+"/"+plot_name)
  end if
  
  ; processing regions listed in product resource file
  regions_list = read_product_file(prod_file,"regions",dynamaps_root)
  num_regions = dimsizes(regions_list)
  print(regions_list)
  print(num_regions)
  ; do for each region
  do s=0,num_regions-1
    reg_file = regions_list(s)
    reg = asciiread(reg_file,-1,"string")
    reg_name = reg(0)
    num_reg_resources = dimsizes(reg)
  
    outimgname = dynamaps_root+date+strcycle+"/"+plot_name+"/"+plot_name+"_"+reg_name+"_"+date+strcycle+"_"+strfhr

    wks = gsn_open_wks(file_type,outimgname)
    plot = new(num_overlays,graphic)
    field = new(num_overlays,graphic)
    the_map = create_map(wks) 
 
    ; reading in and processing map resources
    mapdef = asciiread(dynamaps_root+read_product_file(prod_file,"bg_map",dynamaps_root)+".dym",-1,"string")
    num_mp_resources = dimsizes(mapdef)
    do m=1,num_mp_resources-1,2
      setval_obj(the_map,mapdef(m),mapdef(m+1))
    end do
    ;end of map resources

    ; setting region resources for the map
    do sss=1,num_reg_resources-1,2
      setval_obj(the_map,reg(sss),reg(sss+1))
    end do
  
    i = 3 ; line counter for the plot resource file
    do g=0,num_overlays-1
      ;read in overlay-specific header
      var_name = str_get_field(prod(i),1,",")
      plot_type = str_get_field(prod(i),2,",")
      var_level = toint(str_get_field(prod(i),3,","))
      var_coord = str_get_field(prod(i),4,",")
      var_multiplier = tofloat(str_get_field(prod(i),5,","))
      var_additive = tofloat(str_get_field(prod(i),6,","))
      print(var_name+" "+var_level+" "+var_coord)
      if(isfilevar(file1,var_name))then
        a = file1
      end if
      if(isfilevar(file2,var_name))then
        a = file2
      end if
      if(plot_type.ne."v") then
        if(var_level.ne.0)then
          data := a->$var_name$(:,{var_level},:,:)
        else
          data := a->$var_name$
        end if
        ;printVarSummary(data)
        newdata = add_cyclic(data)
        data := newdata
        delete(newdata)
        if (var_multiplier.ne.1) then
          data = data * var_multiplier
        end if
        if (var_additive.ne.0) then
          data = data + var_additive
        end if
        print("Plotting "+var_name)
        field(g) = create_field(data(0,:,:))
        plot(g) = create_contour_plot(wks,field(g))
      else
        v_var_name = str_sub_str(var_name,"u","v")
        if(var_level.ne.0)then
          udata := a->$var_name$(:,{var_level},:,:)
          vdata := a->$v_var_name$(:,{var_level},:,:)
        else
          udata := a->$var_name$
          vdata := a->$v_var_name$
        end if
	if (var_multiplier.ne.1) then
	  udata = udata * var_multiplier
          vdata = vdata * var_multiplier
        end if
        if (var_additive.ne.0) then
          udata = udata + var_additive
          vdata = vdata + var_additive
        end if
        print("Plotting "+var_name)
        field(g) = create_vector_field(udata(0,:,:),vdata(0,:,:))
        plot(g) = create_vector_plot(wks,field(g))
      end if
      i=i+1
      do while(prod(i).ne."EOO")
		setval_obj(plot(g),prod(i),prod(i+1))
		i = i+2
      end do
      i = i+1
    end do  
  
    ; overlay each of the plots onto the map made previously
    do n=0,num_overlays-1
      overlay(the_map,plot(n))
    end do
    maximize_output(wks,True)
    ;draw(the_map)
    ;frame(wks)

    plot_density = 100

    delete(wks)
    delete(reg)
    system("convert -trim -bordercolor white -border 5x5 -rotate 270 -density "+plot_density+" "+outimgname+"."+file_type+" "+outimgname+".jpg")
    system("rm -f "+outimgname+"."+file_type)
    print(outimgname+".jpg")
  end do

  ;time for a bit of logging
  print("PROD-DONE.")
  ;system print to fhrlogs here
  system("echo Image production of "+plot_name+" at F"+strfhr+" done at `date -u` >> "+this_fhrlog)


end
