;**************************************
;moistomg_all.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;******************************************************
;
;******************************************************

  labels = (/"pg2","pg3", \
             "~F33~D~F21~t~B~phys~N~ = 1800 s * 30 / N~B~e~N~", \
             "~F33~D~F21~t~B~phys~N~ = 1800 s"/)

  fname1 = (/"physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X1-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X134-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X2-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X267-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X4-offset"/)
  fdate1 = ".cam.h1.*"

  fname2 = (/"physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X1-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X134-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X2-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X267-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X4-offset"/)
  fdate2 = ".cam.h1.*"

  xname1 = (/"physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181103_X1-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181104_X134-dt1800-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181104_X2-dt1800-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181104_X267-dt1800-offset", \
	     "physgrid_180607_FKESSLERbubble_ne30pg2_ne30pg2_mg17_181104_X4-dt1800-offset"/)
  xdate1 = ".cam.h1.*"

  xname2 = (/"physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181103_X1-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181104_X134-dt1800-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181104_X2-dt1800-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181104_X267-dt1800-offset", \
             "physgrid_180607_FKESSLERbubble_ne30pg3_ne30pg3_mg17_181104_X4-dt1800-offset"/)
  xdate2 = ".cam.h1.*"

  VAR = "OMEGA"

  pltTitle = "FKESSLER"
  pltName = "temp"
  nfiles = dimsizes(fname1)

  min1 = new ( (/nfiles/), float)
  min2 = new ( (/nfiles/), float)
  xmin1 = new ( (/nfiles/), float)
  xmin2 = new ( (/nfiles/), float)

  dx = 1. * ( (/1.,3./4.,1./2.,3./8.,1./4./) )
  dx_a = fspan(0.01,3.,300)

  writencdf = False
  fname_out = "physgrid_180607_FKESSLERbubbles.nc"
  varnams = (/"MIN1","MIN2","XMIN1","XMIN2","DX"/)

  loadncdf = True
  fname_in = fname_out
  varnams = varnams

  secpday = 60.*60.*24

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltName)               ; open workstation
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
  plot = new(1,graphic)

  res                      = True         ; plot modifications desired
  res@gsnMaximize      = False
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame

  res@xyLineThicknessF  = 3
  res@xyDashPattern  = 0                         ; Make curves all solid
  res@xyMarkLineMode = "Markers"               ; Markers *and* lines
  res@xyMarkerSizeF = 0.020
  res@xyMarkerThicknessF = 5

  res@tmBorderThicknessF = 4 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@tiXAxisFontHeightF = 0.014
  res@tiYAxisFontHeightF = 0.014
  res@tmXBLabelFontHeightF = 0.014
  res@tmYLLabelFontHeightF = 0.014

  res@vpWidthF            = 0.5           ; change aspect ratio of plot
  res@vpHeightF           = 0.5

  res@tmXUseBottom    = False
  res@tmXTLabelsOn = True
  res@tmXTOn = True
  res@tmXTMode        = "Explicit"
  res@tmXTValues      = dx
  res@tmXTLabels      = (/"ne30","ne40","ne60","ne80","ne120"/)
  res@tmXBMode        = "Explicit"
  res@tmXBValues      = dx
  res@tmXBLabels      = (/"350","262.5","175","131.25","87.5"/)
  res@tmXTLabelFontHeightF = res@tmXBLabelFontHeightF

if (.not.loadncdf) then

 do n = 0,nfiles-1

   print("begin case " + n)

   files = systemfunc ("ls " + "/glade/scratch/aherring/" + fname1(n) + "/run/" + fname1(n) + fdate1)
   f  = addfiles (files,"r")
   ListSetType(f,"cat")

   print("  load fname1 vars")
   x1d = ndtooned(f[:]->$VAR$)

   ;find min value
   ind1 = minind(x1d)
   min1(n) = x1d(ind1)

   print("  min1 " + min1(n) + " Pa/s")
   tmp =min1(n)*secpday/100.
   print("  min1 " + tmp + " hPa/day")

   delete(f)
   delete(files)
   delete(x1d)

   files = systemfunc ("ls " + "/glade/scratch/aherring/" + fname2(n) + "/run/" + fname2(n) + fdate2)
   f  = addfiles (files,"r")
   ListSetType(f,"cat")

   print("  load fname2 vars")

   x1d = ndtooned(f[:]->$VAR$)
   ind1 = minind(x1d)
   min2(n) = x1d(ind1)

   print("  min2 " + min2(n) + " Pa/s")
   tmp =min2(n)*secpday/100.
   print("  min2 " + tmp + " hPa/day")

   delete(f)
   delete(files)
   delete(x1d)

   files = systemfunc ("ls " + "/glade/scratch/aherring/" + xname1(n) + "/run/" + xname1(n) + xdate1)
   f  = addfiles (files,"r")
   ListSetType(f,"cat")

   print("  load xname1 vars")

   x1d = ndtooned(f[:]->$VAR$)
   ind1 = minind(x1d)
   xmin1(n) = x1d(ind1)

   print("  xmin1 " + xmin1(n) + " Pa/s")
   tmp =xmin1(n)*secpday/100.
   print("  xmin1 " + tmp + " hPa/day")

   delete(f)
   delete(files)
   delete(x1d)

   files = systemfunc ("ls " + "/glade/scratch/aherring/" + xname2(n) + "/run/" + xname2(n) + xdate2)
   f  = addfiles (files,"r")
   ListSetType(f,"cat")

   print("  load xname2 vars")

   x1d = ndtooned(f[:]->$VAR$)
   ind1 = minind(x1d)
   xmin2(n) = x1d(ind1)

   print("  xmin2 " + xmin2(n) + " Pa/s")
   tmp =xmin2(n)*secpday/100.
   print("  xmin2 " + tmp + " hPa/day")

   delete(f)
   delete(files)
   delete(x1d)


   print("Done with case " + n)

 end do

else
   print("Loading vars from " + fname_in)
   ncdf = addfile(fname_in , "r")
   min1 = ncdf->$varnams(0)$
   min2 = ncdf->$varnams(1)$
   xmin1= ncdf->$varnams(2)$
   xmin2= ncdf->$varnams(3)$
   dx   = ncdf->$varnams(4)$
end if

  res@trYReverse            = True  
  res@trYMaxF                = -3.
  res@trYMinF                = -25.
  res@tiYAxisString          = "Minimum ~F33~w~F21~ (Pa/s)"
  res@trXMaxF                = 1.05
  res@trXMinF                = 0.2
  res@tiXAxisString          = "Bubble Radius (km)"

  res@xyMarker      = 4
  res@xyMarkerColor = "blue"
  plot(0) = gsn_csm_xy(wks,dx,min1,res)

  res@xyMarkerColor = "red"
  dum0 = gsn_csm_xy(wks,dx,min2,res)
  overlay(plot(0),dum0)
  delete(dum0)

  res@xyMarker      = 2
  res@xyMarkerColor = "blue"
  dum0 = gsn_csm_xy(wks,dx,xmin1,res)
  overlay(plot(0),dum0)
  delete(dum0)

  res@xyMarkerColor = "red"
  dum0 = gsn_csm_xy(wks,dx,xmin2,res)
  overlay(plot(0),dum0)
  delete(dum0)

  ;Boussinesq scaling
  res@xyCurveDrawOrder = "PreDraw"
  res@xyMarkLineMode = "Lines"
  res@xyLineColor = "grey"
  res@xyLineThicknessF  = 4

  cnst = min1(0)*dx(0)
  yum0 = gsn_csm_xy(wks,dx_a,cnst/dx_a,res)
  overlay(plot(0),yum0)
  delete(yum0)

  cnst = min2(0)*dx(0)
  yum0 = gsn_csm_xy(wks,dx_a,cnst/dx_a,res)
  overlay(plot(0),yum0)
  delete(yum0)

  if (writencdf) then
    system("/bin/rm -f "+fname_out)
    ncdf = addfile(fname_out , "c")
    ncdf->$varnams(0)$ = min1
    ncdf->$varnams(1)$ = min2
    ncdf->$varnams(2)$ = xmin1
    ncdf->$varnams(3)$ = xmin2
    ncdf->$varnams(4)$ = dx
  end if

;-----------------------------------
;LEGEND
;-----------------------------------
;;drawNDCGrid(wks)

  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.018                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsMarkerIndex      = 4
  res_lines@gsMarkerSizeF = 0.02
  res_lines@gsMarkerThicknessF = 5.

  xx = 0.67
  yy = 0.70
  res_lines@gsMarkerColor      = "blue"
  res_lines@gsMarkerIndex      = 4
  gsn_polymarker_ndc(wks,xx,yy,res_lines)              ; add polyline

  res_lines@gsMarkerIndex      = 2
  gsn_polymarker_ndc(wks,xx-0.03,yy,res_lines)

  xx = 0.56
  gsn_text_ndc(wks,labels(0),xx+0.02,yy,res_text)

  xx = 0.67
  yy = 0.67
  res_lines@gsMarkerColor      = "red"
  res_lines@gsMarkerIndex      = 4
  gsn_polymarker_ndc(wks,xx,yy,res_lines)              ; add polyline

  res_lines@gsMarkerIndex      = 2
  gsn_polymarker_ndc(wks,xx-0.03,yy,res_lines)

  xx = 0.56
  gsn_text_ndc(wks,labels(1),xx+0.02,yy,res_text)

  xx = 0.64
  yy = 0.76
  res_lines@gsMarkerColor      = "black"
  res_lines@gsMarkerIndex      = 4
  gsn_polymarker_ndc(wks,xx,yy,res_lines)

  xx = 0.345
  gsn_text_ndc(wks,labels(2),xx+0.02,yy,res_text)

  xx = 0.64
  yy = 0.73
  res_lines@gsMarkerIndex      = 2
  gsn_polymarker_ndc(wks,xx,yy,res_lines)

  xx = 0.442
  gsn_text_ndc(wks,labels(3),xx+0.02,yy,res_text)

draw(plot)
frame(wks)

end

