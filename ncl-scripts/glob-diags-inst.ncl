;**************************************
;eof_cam.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/glade/p/work/aherring/se_func_lib.ncl"
;**************************************
begin
;****************************************
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  Re = 6371.22
  p0 = 1.d5

  rdir  = "/run/"
  fname = fname1
  fdate = ".cam."+fincl1+"*"

  onemnth = False 
  nstart = 1

  writencdf = True
  fname_out = fname+".globdiags.nc"

  hilat = (/90.d,10.d/)
  lolat = (/-90.d,-10.d/)

  OMG = (/"OMGgl","OMGtr"/)
  OMGU = (/"OMGUgl","OMGUtr"/)
  OMGD = (/"OMGDgl","OMGDtr"/)
  FRACU = (/"FRACUgl","FRACUtr"/)
  FRACD = (/"FRACDgl","FRACDr"/)

;************
;main
;************
 
 ;load all files
 files = systemfunc ("ls " + dir + fname + rdir + fname + fdate)
 nf = dimsizes(files)
 if (onemnth) then
   nfinish = nstart
 else
   nfinish = nf-1
 end if

 print("loading...")
 print(files(nstart:nfinish))

 f  = addfiles (files(nstart:nfinish),"r")
 ListSetType(f,"cat")
 delete(files)

 if (isfilevardim(f[0],"OMEGA","ncol")) then
   print("NETCDF on native grid")
   latlon = False
 else
   print("NETCDF on lat-lon grid")
   latlon = True
 end if

 print("Grab all vars...")
 VAR = f[:]->OMEGA
 VAR = VAR*secpday/100.
 PS  = f[:]->PS
 hyai= f[0]->hyai
 hybi= f[0]->hybi
 lat = f[0]->lat
 lon = f[0]->lon

 if (latlon) then
   AREA = f[0]->w
   rank = 3
 else
   AREA = f[0]->area
   rank = 2
 end if
 delete(f)

 do n = 0,1
 print("Loading region " + lolat(n) + " to " + hilat(n))

   indx = ind(lat.le.hilat(n) .and. lat.ge.lolat(n))
   if (.not.latlon) then
      omg = VAR(:,:,indx)
      ps = PS(:,indx)
      print("Computing pressure field...")
      pint = se_pressure(ps,p0,hyai,hybi,0)
      ilevs = dimsizes(hyai)
      dp = pint(:,1:ilevs-1,:) - pint(:,0:ilevs-2,:)
      delete(pint)
   else
      omg = VAR(:,:,indx,:)
      ps = PS(:,indx,:)
      print("Computing pressure field...")
      dp = dpres_hybrid_ccm(ps,p0,hyai,hybi)
   end if
   tmp = AREA(indx)
   wgt = conform(omg,tmp,2)
   delete(tmp)


   print("Masking vars...")
   omgu = omg
   omgd = omg
   omgu@_FillValue = default_fillvalue("float")
   omgd@_FillValue = default_fillvalue("float")
   omgu = where(omgu.lt.0.,omgu,omgu@_FillValue)
   omgd = where(omgd.gt.0.,omgd,omgd@_FillValue)
   uvals = omgu/omgu
   dvals = omgd/omgd

   print("Computing space-time fraction...")

   if (latlon) then
     garea = dim_sum(dim_sum(dim_sum(dim_sum(wgt*dp))))
     uarea = dim_sum(dim_sum(dim_sum(dim_sum(uvals*dp*wgt))))
     uarea = uarea/garea   
     darea = dim_sum(dim_sum(dim_sum(dim_sum(dvals*dp*wgt))))
     darea = darea/garea
   else
     garea = dim_sum(dim_sum(dim_sum(wgt*dp)))
     uarea = dim_sum(dim_sum(dim_sum(uvals*dp*wgt)))
     uarea = uarea/garea
     darea = dim_sum(dim_sum(dim_sum(dvals*dp*wgt)))
     darea = darea/garea
   end if

   print("Computing global average...")

   vomg = dim_sum_n(omg*dp,1)/dim_sum_n(dp,1)
   vomgu = dim_sum_n(omgu*dp,1)/dim_sum_n(uvals*dp,1)
   vomgd = dim_sum_n(omgd*dp,1)/dim_sum_n(dvals*dp,1)

   tomg = dim_avg_0_lowmem(vomg,rank)
   tomgu = dim_avg_0_lowmem(vomgu,rank)
   tomgd = dim_avg_0_lowmem(vomgd,rank)

   delete(garea)
   if (latlon) then
     garea = dim_sum(dim_sum(wgt(0,0,:,:)))
     gomg = dim_sum(dim_sum(wgt(0,0,:,:)*tomg))
     gomg = gomg/garea
     gomgu = dim_sum(dim_sum(wgt(0,0,:,:)*tomgu))
     gomgu = gomgu/garea
     gomgd = dim_sum(dim_sum(wgt(0,0,:,:)*tomgd))
     gomgd = gomgd/garea
   else
     garea = dim_sum(wgt(0,0,:))
     gomg = dim_sum(wgt(0,0,:)*tomg)
     gomg = gomg/garea
     gomgu = dim_sum(wgt(0,0,:)*tomgu)
     gomgu = gomgu/garea
     gomgd = dim_sum(wgt(0,0,:)*tomgd)
     gomgd = gomgd/garea
   end if

   if (writencdf) then
     if (n.eq.0) then
       system("/bin/rm -f "+fname_out)
       ncdf = addfile(fname_out,"c")
     end if
     ncdf->$OMG(n)$ = gomg
     ncdf->$OMGU(n)$ = gomgu
     ncdf->$OMGD(n)$ = gomgd
     ncdf->$FRACU(n)$ = uarea
     ncdf->$FRACD(n)$ = darea
   end if

  stag = 1. - darea - uarea
  print("  ")
  print("Stats for region " + lolat(n) + " to " + hilat(n))
  print("------------------------------------------------------------------------")
  print("  Mean omega          " + gomg + " (hPa/day)")
  print("  Mean upward omega   " + gomgu + " (hPa/day)")
  print("  Mean downward omega " + gomgd + " (hPa/day)")
  print("  Space-time fraction of upward motion   " + uarea)
  print("  Space-time fraction of downward motion " + darea)
  print("  Space-time fraction of stagnant motion " + stag)
dum = (uarea*gomgu) + (darea*gomgd)
  print("  Check on globav " + dum)
  print("  ")
  delete([/omg,omgu,omgd,vomg,vomgu,vomgd,tomg,tomgu,tomgd,uvals,dvals,ps,dp,wgt,indx/])

end do 

end



