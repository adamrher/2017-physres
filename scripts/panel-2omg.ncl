;**************************************
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************
;****************************************

  Re = 6.37122e3 ;km
  secpday = 60.*60.*24
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  p0   = 100000.d

  dirlo = "1case/"
  fnamlo = (/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_181106_dt2700.pdf-omg.nc", \
	     "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.pdf-omg.nc"/)

  dirhi = "ne120/"
  fnamhi = (/"physgrid_180607_QPC6_ne120pg2_ne120pg2_mg17_181106_dt675.pdf-omg.nc", \
	     "physgrid_180607_QPC6_ne120pg2_ne120pg2_mg17_180608.pdf-omg.nc"/)

  ncase = dimsizes(fnamlo)
  nres = 2
  xmin = (/-4.5   ,-18.     /)
  xmax = (/ 0.05  ,  0.2    /)
  ymin = (/ 1.0e-9,  6.e-11 /)
  ymax = (/ 1.0   ,  1.0    /)

  nbins  = 200
  varNam = "pdfvar1"

  xaxis = "~F33~w~F21~ (Pa/s)"
  yaxis = "Probability (fraction)"

  labels = (/"ne30pg2","ne120pg2"/)
  leglo  = (/"  ~F33~D~F21~t~B~phys~N~ = 2700 s", \
	     "  ~F33~D~F21~t~B~phys~N~ = 1800 s"/)
  leghi  = (/"  ~F33~D~F21~t~B~phys~N~ = 675 s", \
             "  ~F33~D~F21~t~B~phys~N~ = 450 s"/)

  pltNam = "temp_pdf"

  colors = (/"blue","red"/)


;;;flip for better plotting
 fnamlo = fnamlo(::-1)
 fnamhi = fnamhi(::-1)
 colors = colors(::-1)

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  plot = new( (/nres/), "graphic")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  res@gsnMaximize 	   = False
  res@vpWidthF = 0.5
  res@vpHeightF = 0.5
  res@xyYStyle ="Log"

  res@tmBorderThicknessF = 2 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@trXReverse            = True
  res@gsnXYBarChart            = True
  res@gsnXYBarChartOutlineOnly = True

  ;;res@xyMonoLineThickness = True
  ;;res@xyLineThicknessF   = 2.0

  ;;add legend
  txres = True
  txres@txFontHeightF = 0.020
  txres@txJust = "CenterLeft"

  plres  = True                  ; polyline mods desired
  plres@gsLineDashPattern  = 0                    ; solid line
  plres@gsLineThicknessF  = 5.                   ; line thicker

do n = 0,ncase-1

  print("Begin case "+n)

  ncdflo = addfile(dirlo+fnamlo(n), "r")
  ncdfhi = addfile(dirhi+fnamhi(n), "r")

  varlo = ncdflo->$varNam$
  varhi = ncdfhi->$varNam$
  delete([/ncdflo,ncdfhi/])

  print("Plotting...")

  pvalslo = ind(varlo.gt.0.d0)
  xlo = varlo@bin_bounds(0:nbins-1)

  pvalshi = ind(varhi.gt.0.d0)
  xhi = varhi@bin_bounds(0:nbins-1)

  res@xyLineThicknessF   = 4.0
  res@xyLineColors       = colors(n)
  if (n.eq.0) then
    res@tiYAxisString          = yaxis
    res@tiXAxisString          = xaxis
    res@trXMaxF                = xmax(0)
    res@trXMinF                = xmin(0)
    res@trYMinF                = ymin(0)
    res@trYMaxF                = ymax(0)
    plot(0) = gsn_csm_xy(wks,xlo(pvalslo),varlo(pvalslo)/100.,res)

    res@trXMaxF                = xmax(1)
    res@trXMinF                = xmin(1)
    res@trYMinF                = ymin(1)
    res@trYMaxF                = ymax(1)
    plot(1) = gsn_csm_xy(wks,xhi(pvalshi),varhi(pvalshi)/100.,res)
  else
    tmp0 = gsn_csm_xy(wks,xlo(pvalslo),varlo(pvalslo)/100.,res)
    tmp1 = gsn_csm_xy(wks,xhi(pvalshi),varhi(pvalshi)/100.,res)
    overlay(plot(0),tmp0)
    overlay(plot(1),tmp1)
    delete([/tmp0,tmp1/])
  end if
  delete([/pvalslo,pvalshi,xlo,xhi/])

end do

;;;drawNDCGrid(wks)
;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                    = True                
  res_text@txFontHeightF      = 0.012
  res_text@txJust             = "CenterLeft"        

  res_lines                   = True                
  res_lines@gsLineDashPattern = 0                   
  res_lines@gsLineThicknessF  = res@xyLineThicknessF

  xxl = (/0.285,0.285+0.04/)
  xxh = (/0.675,0.675+0.04/)
  yy0 = 0.403
  yy1 = 0.383
  yy = (/yy0,yy1/)
  do n = 0,ncase-1
    res_lines@gsLineColor       = colors(ncase-1-n)
    gsn_polyline_ndc(wks,xxl,(/yy(n),yy(n)/),res_lines)
    gsn_text_ndc(wks,leglo(n),xxl(1),yy(n),res_text)

    res_lines@gsLineColor       = colors(ncase-1-n)
    gsn_polyline_ndc(wks,xxh,(/yy(n),yy(n)/),res_lines)
    gsn_text_ndc(wks,leghi(n),xxh(1),yy(n),res_text)
  end do

;*****************************************************
; Panel Plot
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStrings = labels
  resP@gsnPanelFigureStringsFontHeightF = 0.013
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "TopRight"

  resP@gsnPanelRight = 0.98
  resP@gsnPanelLeft = 0.2
  resP@gsnPanelXWhiteSpacePercent = 2.
  gsn_panel(wks,plot,(/1,nres/),resP)               ; now draw as one plot
  frame(wks)

end

