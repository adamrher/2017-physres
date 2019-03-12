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

  mdir = ""
  spname= (/"physgrid_180607_QPC6zmcin5_ne20pg3_ne20pg3_mg17_180607.spectra-FT-lev19.nc",\
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180617_bilin-ne20visc.spectra-FT-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.spectra-FT-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.spectra-FT-lev19.nc"/)

  fname = (/"physgrid_180607_QPC6zmcin5_ne20pg3_ne20pg3_mg17_180607.pdf-omg_gll.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180617_bilin-ne20visc.pdf-omg_gll.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.pdf-omg_gll.nc", \
	    "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.pdf-omg_gll.nc"/)

  scname= (/"physgrid_180607_QPC6zmcin5_ne20pg3_ne20pg3_mg17_180607.pdf-omg_gll-scale32.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180617_bilin-ne20visc.pdf-omg_gll-scale32.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.pdf-omg_gll-scale32.nc", \
	    "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.pdf-omg_gll.nc"/)

  ncase = dimsizes(fname)
  dx = (/"1~F135~G~F21~"/)
  ;dx = (/"1~F135~G~F21~","0.5~F135~G~F21~","0.25~F135~G~F21~"/)
  ;dx = (/"target (magenta) ne30pg3","target (magenta) ne60pg3","target (magenta) ne120pg3"/)
  nres = dimsizes(dx)
  wave = (/165,330,660/)
  offset = (/20.,40.,80./)
  cutoff = 118

  nbins  = 200
  xmin = (/-5.,-10.,-20./)
  ymin = (/4.e-10,1.e-10,1.e-11/)

  spvarNam = "specbar1"
  spxNam   = "xbar1"
  fnvarNam = "pdfvar1"
  scvarNam = "pdfvar1"

  xaxis = "~F33~w~F21~~B~gll~N~ (Pa/s)"
  yaxis = "~F10~f~B~T~N~~F21~ (gll) spectral density (K~S~2~N~/s~S~2~N~), 369 hPa level"
  ;;yaxis = "~V1~d~F10~T~H-45~~V-1~~F21~___~H-40~~V-30~~F21~d~F10~t~H23~~V18~~F21~(phys) spectral density (K~S~2~N~/s~S~2~N~), 369 hPa level"

  scxaxis = (/"~F33~w~F21~~B~gll~N~ (Pa/s)", \
	      "~F33~w~F21~~B~s,ne60pg3~N~ (Pa/s)", \
 	      "~F33~w~F21~~B~s,ne120pg3~N~ (Pa/s)"/)
 
  pltNam = "temp_pdf-omg"

  ;;colors = (/"red","sienna1"/)
  ;;colors = (/"red","magenta","blue","magenta","sienna1","deepskyblue","magenta","palegreen4","darkorchid4","red4"/)
  colors = (/"magenta","blue","deepskyblue1","black"/)
  ;;colors = (/"blue","darkorchid4","red","green"/)


;;;flip for better plotting
 spname = spname(::-1)
 fname = fname(::-1)
 scname = scname(::-1)
 colors = colors(::-1)

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  plot = new( (/3*nres/), "graphic")
  rlabels = new( (/3*nres/), "string")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
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

  res@xyMonoLineThickness = True
  res@xyLineThicknessF   = 2.0

  ;;add legend
  txres = True
  txres@txFontHeightF = 0.020
  txres@txJust = "CenterLeft"

  plres  = True                  ; polyline mods desired
  plres@gsLineDashPattern  = 0                    ; solid line
  plres@gsLineThicknessF  = 5.                   ; line thicker

do n = 0,nres-1

print("Begin res "+n)

   do m = 0,ncase-1

   runnum = n*ncase + m
   print("Loading run " + runnum)

     spncdf = addfile("../spectra/"+mdir+spname(n*ncase+m), "r")
     fnncdf = addfile("1case/" + fname(n*ncase+m), "r")
     scncdf = addfile("1case/" + scname(n*ncase+m), "r")

     spvar = spncdf->$spvarNam$
     spxvals = spncdf->$spxNam$

     fnvar = fnncdf->$fnvarNam$
     scvar = scncdf->$scvarNam$

     delete([/spncdf,fnncdf,scncdf/])

     print("Plotting...")

     fnpvals = ind(fnvar.gt.0.d0)
     fnxvals = fnvar@bin_bounds(0:nbins-1)

     scpvals = ind(scvar.gt.0.d0)
     scxvals = scvar@bin_bounds(0:nbins-1)

     res@xyLineThicknessF   = 2.5
     if (m.eq.ncase-1) then
     else if (m.eq.ncase-2) then
     else if (m.eq.ncase-3) then
     else
       res@xyLineThicknessF   = 4.0
     end if
     end if
     end if

     res@xyLineColors       = colors(m)
     if (m.eq.0) then

       ;;;spectra first
       res@xyXStyle ="Log"
       res@tiYAxisString          = yaxis
       res@tiXAxisString          = "spherical wavenumber"
       res@trXMaxF                = 1.*cutoff + offset(n)
       res@trXMinF                = 1.
       res@trYMinF     = 0.6e-12
       res@trYMaxF     = 2.e-10
       plot(n*ncase+0) = gsn_csm_xy(wks,spxvals(1:cutoff-1),spvar(1:cutoff-1),res)
       res@xyXStyle ="Linear"

       ;;;now pdfs
       res@trXReverse            = True
       res@gsnXYBarChart            = True
       res@gsnXYBarChartOutlineOnly = True

       res@tiYAxisString          = "Probability (fraction)"
       res@tiXAxisString          = xaxis
       res@trXMaxF                = 0.05
       res@trXMinF                = xmin(n)
       res@trYMaxF                = 1.
       res@trYMinF                = ymin(n)

       plot(n*ncase+1) = gsn_csm_xy(wks,fnxvals(fnpvals),fnvar(fnpvals)*1.e-2,res)

       res@tiYAxisString          = "Scaled Probability (fraction)"
       res@tiXAxisString          = scxaxis(n)
       plot(n*ncase+2) = gsn_csm_xy(wks,scxvals(scpvals),scvar(scpvals)*1.e-2,res)
       res@trXReverse            = False

     else 
       res@gsnXYBarChart            = False
       res@gsnXYBarChartOutlineOnly = False
       tmp0 = gsn_csm_xy(wks,spxvals(1:cutoff-1),spvar(1:cutoff-1),res)
       res@gsnXYBarChart            = True
       res@gsnXYBarChartOutlineOnly = True
       tmp1 = gsn_csm_xy(wks,fnxvals(fnpvals),fnvar(fnpvals)*1.e-2,res)
       tmp2 = gsn_csm_xy(wks,scxvals(scpvals),scvar(scpvals)*1.e-2,res)
       overlay(plot(n*ncase+0),tmp0)
       overlay(plot(n*ncase+1),tmp1)
       overlay(plot(n*ncase+2),tmp2)
       delete([/tmp0,tmp1,tmp2/])
     end if
     delete([/spxvals,spvar/])
     delete([/fnpvals,fnxvals,fnvar/])
     delete([/scpvals,scxvals,scvar/])


   end do

   print("done with res " + n)

 end do

;;drawNDCGrid(wks)
;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.009                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0                    ; solid line
  res_lines@gsLineThicknessF  = 2.5                   ; line thicker

  ;;xx = (/0.11,0.13/)
  xx = (/0.08,0.11/)
  ;;yy0 = (/0.7685,0.435,0.1021/)
  ;;yy1 = (/0.7535,0.420,0.0871/)
  ;;yy2 = (/0.7385,0.405,0.0721/)
  yy0 = (/0.4450/)
  yy1 = (/0.4300/)
  yy2 = (/0.4150/)
  yy3 = (/0.4000/)
  ll0 = (/"  ne20pg3"," ne40pg3"," ne80pg3"/)
  ll1 = (/"  ne30pg2-ne20visc-loworder"," ne60pg2"," ne120pg2"/)
  ll2 = (/"  ne30pg2"," ne60pg3"," ne120pg3"/)
  ll3 = (/"  ne30pg3"/)
  do n = 0,nres-1
    yy = (/yy0(n),yy1(n),yy2(n),yy3(n)/)
    label = (/ll0(n),ll1(n),ll2(n),ll3(n)/)
    do m = 0,ncase-1
      res_lines@gsLineColor       = colors(ncase-m-1)
      res_lines@gsLineThicknessF  = 2.5
      if (m.eq.ncase-1) then
        res_lines@gsLineThicknessF  = 4.0
      end if
      gsn_polyline_ndc(wks,xx,(/yy(m),yy(m)/),res_lines)
      gsn_text_ndc(wks,label(m),xx(1),yy(m),res_text)
    end do
  end do

;*****************************************************
; Panel Plot
;*****************************************************

  rlabels = (/"a","b","c; scaled by ~F33~D~F21~x~B~phys~N~"/)

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelFigureStrings = rlabels
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.

  resP@gsnPanelRight = 0.99
  ;;resP@gsnPanelLeft = 0.02

  gsn_panel(wks,plot,(/1,3/),resP)               ; now draw as one plot
  frame(wks)

end

