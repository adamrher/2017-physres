;**************************************
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/aherring/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
;****************************************

  Re = 6.37122e3 ;km
  secpday = 60.*60.*24
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  p0   = 100000.d

  fname = (/"camtrunk_180925_FHS94topo_ne30pg3_ne30pg3_mg17_pe384_181008_C092.kespectra-lev200.nc", \
            "camtrunk_180925_FHS94topo_ne30pg2_ne30pg2_mg17_pe384_181008_C092.kespectra-lev200.nc", \
            "camtrunk_180925_FHS94topo_ne30pg3_ne30pg3_mg17_pe384_181010_C092_hivisc.kespectra-lev200.nc"/)

  label = (/"  ne30pg3", \
	    "  ne30pg2", \
	    "  ne30pg3, ~F33~u~F21~~B~div~N~ = 10*~F33~u~F21~~B~div~N~"/)
	
  nfiles = dimsizes(fname)

  plotnlat = 110
  framenlat = 120
  plvl = 200.d0

  ;;; "SPECBAR","SROTBAR","SDIVBAR"?
  specnams = "SDIVBAR"
  xbarnams = "XBAR"

  xaxis = "spherical wavenumber"
  yaxis = "Kinetic Energy Power, Divergent Modes (m~S~2~N~/s~S~2~N~)"

  pltNam = "temp_spectra"
  colors = (/"black","red","blue"/)

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame

  res@vpWidthF    = 0.52
  res@vpHeightF   = 0.48
  ;res@vpXF                = 0.025
  ;res@vpYF                = 0.85

  res@xyYStyle ="Log"
  res@xyXStyle ="Log"

  res@tmBorderThicknessF = 3 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.
  res@tmXBMinorPerMajor = 8

  res@xyMonoLineThickness = True

  res@trYMinF     = 8.e-6
  res@trYMaxF     = 1.e0
  res@trXMinF                = 1

  res@tmXUseBottom  = False
  res@tmXTLabelsOn  = True       
  res@tmXTOn        = True       
  res@tmXTMode      = "Explicit" 

  L = 2*pi*Re
  dist = (/10000.,1000.,100./)
  distminor = (/40000.,30000.,20000.,9000.,8000.,7000.,6000.,5000.,4000.,3000.,2000.,900.,800.,700.,600.,500.,400.,300.,200./)
  nn = L/dist
  nnminor = L/distminor

  res@tmXTValues    = nn
  res@tmXTLabels    = (/"10~S~4~N~","10~S~3~N~","10~S~2~N~"/)
  res@tmXTMinorValues = nnminor

  ;;add legend
  txres = True
  txres@txFontHeightF = 0.020
  txres@txJust = "CenterLeft"

  plres  = True                  ; polyline mods desired
  plres@gsLineDashPattern  = 0                    ; solid line

  yy = (/ 0.27,0.24,0.21 /)
  xx = (/ 0.22,0.28 /)

do n = 0,nfiles-1

print("Begin case "+n)

   ncdf = addfile(fname(n), "r")
   yvar = ncdf->$specnams$
   xvar = ncdf->$xbarnams$
   nlat = dimsizes(xvar)

   print("Plotting...")
   res@xyLineColors       = colors(n)
   res@trXMaxF            = framenlat

   if (n.eq.0) then
     res@xyLineThicknessF = 10
     plres@gsLineThicknessF  = res@xyLineThicknessF
     res@tiYAxisString          = yaxis
     res@tiXAxisString          = xaxis
     plot  = gsn_csm_xy(wks,xvar(1:plotnlat-1),yvar(1:plotnlat-1),res)
     delete(res@tiYAxisString)
   else 
     res@xyLineThicknessF = 6
     plres@gsLineThicknessF  = res@xyLineThicknessF
     tmp = gsn_csm_xy(wks,xvar(1:plotnlat-1),yvar(1:plotnlat-1),res)
     overlay(plot,tmp)
     delete(tmp)
   end if
   delete([/xvar,yvar,ncdf/])

   plres@gsLineColor       = colors(n)
   gsn_polyline_ndc(wks,xx,(/yy(n),yy(n)/),plres)   
   gsn_text_ndc(wks,label(n),xx(1),yy(n),txres)

print("done with case " + n)

end do ;nfiles

txres@txFontHeightF = 0.030
txres@txJust = "CenterCenter"
gsn_text_ndc(wks,"wavelength (km)",0.59,0.97,txres)
;;drawNDCGrid(wks)

;*****************************************************
; Panel Plot
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStrings = (/round(plvl,3)+" hPa level"/)
  resP@gsnPanelFigureStringsFontHeightF = 0.02
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot
  frame(wks)

end

