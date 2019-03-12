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
  spname1=(/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.spectra-PTTEND-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180616-iwidth1-PCoM.spectra-PTTEND-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.spectra-PTTEND-lev19.nc"/)

  spname2=(/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.spectra-FT-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180616-iwidth1-PCoM.spectra-FT-lev19.nc", \
	    "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.spectra-FT-lev19.nc"/)

  fname1 = (/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.pdf-omg_gll.nc", \
	     "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180616-iwidth1-PCoM.pdf-omg_gll.nc", \
	     "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.pdf-omg_gll.nc"/)

  fname2 = (/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.pdf-omg.nc",  \
	     "physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180616-iwidth1-PCoM.pdf-omg.nc", \
	     "physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.pdf-omg.nc"/)

  ncase = dimsizes(fname1)
  dx = (/"1~F135~G~F21~"/)
  nres = dimsizes(dx)
  cutoff = 165;;118

  nbins = 200
  xmin  = -3.4;;;-3.2
  ymin  = 2.e-9;;;2.e-9

  spvarNam = "specbar1"
  spxNam   = "xbar1"
  fnvarNam = "pdfvar1"

  xaxis = "~F33~w~F21~ (Pa/s)"
  yaxis1 = "~F10~f~B~T~N~~F21~ spectral density (K~S~2~N~/s~S~2~N~), 369 hPa level"

  pltNam = "temp_pdf"

  ;;colors = (/"red","magenta","blue","magenta","sienna1","deepskyblue","magenta","palegreen4","darkorchid4","red4"/)
  ;;colors = (/"magenta","blue","deepskyblue1","black"/)
  colors1 = (/"deepskyblue1","green3","black"/)
  colors2 = (/"blue","darkorchid4","black"/)

;;;flip for better plotting
 spname1 = spname1(::-1)
 spname2 = spname2(::-1)
 fname1 = fname1(::-1)
 fname2 = fname2(::-1)
 colors1 = colors1(::-1)
 colors2 = colors2(::-1)
;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wks = gsn_open_wks("pdf",pltNam)

  plot = new( (/2*nres/), "graphic")
  rlabels = new( (/3*nres/), "string")

  res                      = True         ; plot modifications desired
  res@gsnDraw              = False        ; don't draw plot
  res@gsnFrame             = False        ; don't advance frame
  ;res@gsnMaximize = True
  ;res@gsnPaperOrientation = "portrait"
  res@vpWidthF = 0.5
  res@vpHeightF = 0.5

  res@tmBorderThicknessF = 3.5 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  ;res@gsnXYBarChart            = True              ; Create bar plot
  ;res@gsnXYBarChartOutlineOnly = True
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

     spncdf1 = addfile("../spectra/"+mdir+spname1(n*ncase+m), "r")
     spncdf2 = addfile("../spectra/"+mdir+spname2(n*ncase+m), "r")
     fnncdf1  = addfile("1case/" + fname1(n*ncase+m), "r")
     fnncdf2  = addfile("1case/" + fname2(n*ncase+m), "r")

     spvar1   = spncdf1->$spvarNam$
     spxvals1 = spncdf1->$spxNam$
     spvar2   = spncdf2->$spvarNam$
     spxvals2 = spncdf2->$spxNam$
     fnvar1   = fnncdf1->$fnvarNam$
     fnvar2   = fnncdf2->$fnvarNam$

     delete([/spncdf1,spncdf2,fnncdf1,fnncdf2/])

     print("Plotting...")

     fnpvals1 = ind(fnvar1.gt.0.d0)
     fnxvals1 = fnvar1@bin_center(0:nbins-1)
     fnpvals2 = ind(fnvar2.gt.0.d0)
     fnxvals2 = fnvar2@bin_center(0:nbins-1)

     res@xyLineThicknessF   = 4.0
     if (m.eq.0) then
       res@xyLineThicknessF   = 6.0
     end if

     if (m.eq.0) then

       ;;;spectra first
 
       ;;res@tmYLMode = "Explicit"
       ;;res@tmYLValues = (/3.e-12,4.e-12,5.e-12,6.e-12,7.e-12,8.e-12,9.e-12, \
       ;;    	 	    1.e-11,2.e-11,3.e-11,4.e-11,5.e-11,6.e-11,7.e-11,8.e-11,9.e-11/)
       ;;res@tmYLLabels = (/"3~F34~4~F21~10~S~-12~N~","","5~F34~4~F21~10~S~-12~N~", \
       ;; 	            "","7~F34~4~F21~10~S~-12~N~","", \
       ;;                   "","1~F34~4~F21~10~S~-11~N~","2~F34~4~F21~10~S~-11~N~", \
       ;;                   "3~F34~4~F21~10~S~-11~N~","","5~F34~4~F21~10~S~-11~N~", \
       ;;                   "","7~F34~4~F21~10~S~-11~N~","",""/)

       res@tmXUseBottom  = False      ; Keep top axis independent of bottom.
       res@tmXTLabelsOn  = True       ; have tick mark labels
       res@tmXTOn        = True       ; have tick marks
       res@tmXTMode      = "Explicit" ; label independently
       L = 2*pi*Re
       dist = (/2000.,1800.,1600.,1400.,1200.,1000.,900.,800.,700.,600.,500.,400.,300.,200./)
       res@tmXTValues    = L/dist
       res@tmXTLabels    = (/"2000","","","","","1000","","","","600","","400","300","200"/)

       res@xyYStyle ="Log"
       res@xyDashPattern      = 15
       res@xyLineThicknessF   = 6.0
       res@xyLineColors       = colors1(m)
       res@xyXStyle ="Linear"
       res@tiYAxisString          = yaxis1
       res@tiXAxisString          = "spherical wavenumber"
       res@trXMaxF                = 100.0789
       res@trXMinF                = 20.;;30.
       res@trYMinF     = 2.4e-12;;;2.6e-12
       res@trYMaxF     = 0.6e-10
       plot(n*ncase+0) = gsn_csm_xy(wks,spxvals1(1:cutoff-1),spvar1(1:cutoff-1),res)
       res@tmXBMode = "Automatic"
       res@tmYLMode = "Automatic"
       res@tmXUseBottom  = True
       res@tmXTLabelsOn  = False

       res@xyDashPattern      = 0
       res@xyLineColors       = colors1(m)
       tmp = gsn_csm_xy(wks,spxvals2(1:cutoff-1),spvar2(1:cutoff-1),res)
       overlay(plot(n*ncase+0),tmp)
       res@xyXStyle ="Linear"
       delete(tmp)

       ;;;now pdfs
       res@xyLineThicknessF   = 6.0
       res@trXReverse            = True
       res@tiYAxisString          = "Probability (fraction)"
       res@tiXAxisString          = xaxis
       res@trXMaxF                = -0.6;;;;;-1.0;;0.05
       res@trXMinF                = xmin(n)
       res@trYMaxF                = 0.6e-3;;;1.e-4;;1.0
       res@trYMinF                = ymin(n)
       plot(n*ncase+1) = gsn_csm_xy(wks,fnxvals1(fnpvals1),fnvar1(fnpvals1)*1.e-2,res)
       res@xyDashPattern      = 15
       tmp = gsn_csm_xy(wks,fnxvals2(fnpvals2),fnvar2(fnpvals2)*1.e-2,res)
       overlay(plot(n*ncase+1),tmp)
       delete(tmp)
       res@trXReverse            = False
     else 
       res@xyDashPattern      = 15
       res@xyLineThicknessF   = 4.0
       res@xyLineColors       = colors1(m)
       tmp0 = gsn_csm_xy(wks,spxvals1(1:cutoff-1),spvar1(1:cutoff-1),res)

       res@xyDashPattern      = 0
       res@xyLineColors       = colors1(m)
       tmp1 = gsn_csm_xy(wks,spxvals2(1:cutoff-1),spvar2(1:cutoff-1),res)

       res@xyLineThicknessF   = 4.0
       tmp2 = gsn_csm_xy(wks,fnxvals1(fnpvals1),fnvar1(fnpvals1)*1.e-2,res)

       res@xyDashPattern      = 15
       tmp3 = gsn_csm_xy(wks,fnxvals2(fnpvals2),fnvar2(fnpvals2)*1.e-2,res)

       overlay(plot(n*ncase+0),tmp0)
       overlay(plot(n*ncase+0),tmp1)
       overlay(plot(n*ncase+1),tmp2)
       overlay(plot(n*ncase+1),tmp3)
       delete([/tmp0,tmp1,tmp2,tmp3/])
     end if
     delete([/spxvals1,spvar1/])
     delete([/spxvals2,spvar2/])
     delete([/fnpvals1,fnxvals1,fnvar1/])
     delete([/fnpvals2,fnxvals2,fnvar2/])
     print("done with case " + m)
   end do

   print("done with res " + n)

 end do

;;drawNDCGrid(wks)
;*****************************************************
; Manually create and attach legend
;*****************************************************
  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.013                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0                    ; solid line
  res_lines@gsLineThicknessF  = 2.5                   ; line thicker

  xx = (/0.115,0.165/)
  yy0 = (/0.4000/)
  yy1 = (/0.3800/)
  yy2 = (/0.3600/)
  ll0 = "  ne30pg2"
  ll1 = "  ne30pg2-loworder"
  ll2 = "  ne30pg3"
  do n = 0,nres-1
    yy = (/yy0(n),yy1(n),yy2(n)/)
    label = (/ll0(n),ll1(n),ll2(n)/)
    do m = 0,ncase-1
      res_lines@gsLineColor       = colors1(ncase-m-1)
      res_lines@gsLineThicknessF  = 4.0
      if (m.eq.ncase-1) then
        res_lines@gsLineThicknessF  = 6.0
      end if
      gsn_polyline_ndc(wks,xx,(/yy(m),yy(m)/),res_lines)
      gsn_text_ndc(wks,label(m),xx(1),yy(m),res_text)
    end do
  end do

  res_text@txFontHeightF      = 0.015
  res_text@txJust             = "CenterCenter"
  gsn_text_ndc(wks,"wavelength (km)",0.29,0.76,res_text)

  res_lines@gsLineColor       = "Black"
  res_lines@gsLineThicknessF  = 3.0
  tx = (/ L/1000.,L/1000. /)
  ty = (/ 0.53E-10,0.6E-10 /)

  mush = gsn_add_polyline(wks,plot(0),tx,ty,res_lines)

;*****************************************************
; Panel Plot
;*****************************************************

  rlabels = (/"GLL","phys","phys"/)

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPaperOrientation = "portrait"
  ;resP@gsnPanelFigureStrings = rlabels
  resP@gsnPanelFigureStringsFontHeightF = 0.01
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@amJust           = "TopRight"
  resP@gsnPanelYWhiteSpacePercent = 5.

  resP@gsnPanelRight = 0.99
  ;;resP@gsnPanelLeft = 0.02

  gsn_panel(wks,plot,(/1,2/),resP)               ; now draw as one plot
  frame(wks)

end

