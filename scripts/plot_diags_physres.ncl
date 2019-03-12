load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;******************************************************
;
;******************************************************

;;;pg3

  fpg3_all  = (/"physgrid_180607_QPC6_ne20pg3_ne20pg3_mg17_181020_dt2700.all-diags.nc", \
  	  	"physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.all-diags.nc", \
	        "physgrid_180607_QPC6_ne40pg3_ne40pg3_mg17_181020_dt1350.all-diags.nc", \
		"physgrid_180515_QPC6_ne60pg3_ne60pg3_mg17_180528.all-diags.nc", \
	        "physgrid_180607_QPC6_ne80pg3_ne80pg3_mg17_181018.all-diags.nc", \ 
		"physgrid_180515_QPC6_ne120pg3_ne120pg3_mg17_180602.all-diags.nc"/)

  fpg3_omg  = (/"physgrid_180607_QPC6_ne20pg3_ne20pg3_mg17_181020_dt2700.omg-diags.nc", \
  		"physgrid_180607_QPC6_ne30pg3_ne30pg3_mg17_180617.omg-diags.nc", \
	        "physgrid_180607_QPC6_ne40pg3_ne40pg3_mg17_181020_dt1350.omg-diags.nc", \
		"physgrid_180515_QPC6_ne60pg3_ne60pg3_mg17_180528.omg-diags.nc", \
	        "physgrid_180607_QPC6_ne80pg3_ne80pg3_mg17_181018.omg-diags.nc", \
		"physgrid_180515_QPC6_ne120pg3_ne120pg3_mg17_180602.omg-diags.nc"/)

  npg3 = dimsizes(fpg3_all)

  dxdynpg3 = (/166.8,111.2,83.4,55.6,41.7,27.8/)
  dyphypg3 = dxdynpg3

;;;pg2

  physdx = False

  fpg2_all  = (/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.all-diags.nc", \
                "physgrid_180607_QPC6_ne60pg2_ne60pg2_mg17_180608.all-diags.nc", \
		"physgrid_180607_QPC6_ne120pg2_ne120pg2_mg17_180608.all-diags.nc"/)

  fpg2_omg  = (/"physgrid_180607_QPC6_ne30pg2_ne30pg2_mg17_180608.omg-diags.nc", \
		"physgrid_180607_QPC6_ne60pg2_ne60pg2_mg17_180608.omg-diags.nc", \
		"physgrid_180607_QPC6_ne120pg2_ne120pg2_mg17_180608.omg-diags.nc"/)

  npg2 = dimsizes(fpg2_all)

  dxdynpg2 = (/111.2,55.6,27.8/)
  dxphypg2 = (/166.8,83.4,41.7/)

;;pg3-hidt

  fhidt_all   = (/"physgrid_180607_QPC6zmcin5_ne40pg3_ne40pg3_mg17_180607.all-diags.nc", \
	          "physgrid_180607_QPC6_ne80pg3_ne80pg3_mg17_181020_dt450.all-diags.nc"/)
                
  fhidt_omg  = (/"physgrid_180607_QPC6zmcin5_ne40pg3_ne40pg3_mg17_180607.omg-diags.nc", \
	         "physgrid_180607_QPC6_ne80pg3_ne80pg3_mg17_181020_dt450.omg-diags.nc"/)
                
  nhidt = dimsizes(fhidt_all)
  
  dxdynhidt = (/83.4,41.7/)
  dyphyhidt = dxdynpg3

;;;define VARS

  VARS  = (/"OMGUgl"  , \
	    "PRECLgl" , \
            "PRECCgl"/)

  MIN  = (/-100. , \
	     1.2 , \
             1.0/)

  MAX  = (/-54.  , \  
	     2.3 , \
             2.1/)

  nams  = (/"Mean upward ~F33~w~F21~ (hPa/day)"	  , \
  	    "Mean CLUBB Precipitation Rate (mm/day)"      , \
   	    "Mean ZM Precipitation Rate (mm/day)"/)

  nvars = dimsizes(VARS)
  omgid = 0

  colorpg2 = "blue"
  colorpg3 = "red2"
  colorhidt = "green3"

  pltNam = "temp_diags"

;******************************************************
; create plot
;******************************************************
  wkstype = "pdf"
  wks = gsn_open_wks(wkstype,pltNam)               ; open workstation
  plot = new( (/nvars/), "graphic")

  resf                        = True

  resf@gsnMaximize      = False
  resf@gsnDraw          = False        ; don't draw plot
  resf@gsnFrame         = False        ; don't advance frame

  resf@tiXAxisString    = "~F33~D~F21~x~B~dyn~N~ (km)"

  resf@tmXUseBottom = True

  resf@tmXMajorGridThicknessF = 1.
  resf@tmYMajorGridThicknessF = 1.
  resf@tmXMinorGridThicknessF = 0.5
  resf@tmYMinorGridThicknessF = 0.5

  resf@tmXBMajorThicknessF = 1.
  resf@tmYRMajorThicknessF = 1.
  resf@tmXTMajorThicknessF = 1.
  resf@tmYLMajorThicknessF = 1.

  resf@tmBorderThicknessF = 2.
  resf@tmXBMajorOutwardLengthF = 0.
  resf@tmYLMajorOutwardLengthF = 0.
  resf@tmXBMinorOutwardLengthF = 0.
  resf@tmYLMinorOutwardLengthF = 0.
  resf@tmXTMajorOutwardLengthF = 0.
  resf@tmYRMajorOutwardLengthF = 0.
  resf@tmXTMinorOutwardLengthF = 0.
  resf@tmYRMinorOutwardLengthF = 0.

  resf@tiXAxisFontHeightF = 0.03
  resf@tiYAxisFontHeightF = 0.03
  resf@tmXBLabelFontHeightF = 0.025
  resf@tmYLLabelFontHeightF = 0.025

  ;resf@vpWidthF            = 0.2           ; change aspect ratio of plot
  ;resf@vpHeightF           = 0.2
  ;resf@vpXF                = 0.1
  ;resf@vpYF                = 0.1

  resf@trXReverse            = True

  resf@trXMinF                = 10.
  resf@trXMaxF                = 180.

  resf@tmXMajorGrid= True
  resf@tmXMajorGridThicknessF      = 1.0
  resf@tmXMajorGridLineDashPattern = 2

  resf@tmYMajorGrid= True
  resf@tmYMajorGridThicknessF      = 1.0
  resf@tmYMajorGridLineDashPattern = 2
  
  resf@tmGridDrawOrder = "PreDraw"
 
  res                      = True         ; plot modifications desired
  res@gsMarkerIndex = 2;;;4
  res@gsMarkerSizeF = 14
  res@gsMarkerThicknessF = 4

;;---begin loop----;;

 res@gsMarkerColor = colorpg3

 do n = 0,npg3-1

   print("Begin case " + n)

   files = systemfunc ("ls " + fpg3_all(n))
   print("Loading Files")
   print(files)
   fall = addfiles (files,"r")
   ListSetType(fall,"cat")
   delete(files)

   files = systemfunc ("ls " + fpg3_omg(n))
   print(files)
   fomg = addfiles (files,"r")
   ListSetType(fomg,"cat")
   delete(files)

   do m = 0,nvars-1

     if (m.ne.omgid) then
       var = fall[:]->$VARS(m)$
     else
       var = fomg[:]->$VARS(m)$
     end if
     print("pg2, m: " + m)
     print(VARS(m) + ": " + var)

     if (n.eq.0) then
       resf@trYMinF = MIN(m)
       resf@trYMaxF = MAX(m)
       resf@tiYAxisString = nams(m)

       if (m.eq.omgid) then
         resf@trYReverse            = True
       else
         resf@trYReverse            = False
       end if

       plot(m) = gsn_csm_blank_plot(wks,resf)
     end if
     
     pNam = unique_string("tmp")
     plot@$pNam$ = gsn_add_polymarker(wks,plot(m),dxdynpg3(n),var,res)
   end do
   delete([/fall,fomg/])

 end do

 res@gsMarkerColor = colorpg2
 if (physdx) then
   dx = dxphypg2
 else
   dx = dxdynpg2
 end if

 do n = 0,npg2-1
   
   print("Begin case " + n)
   
   files = systemfunc ("ls " + fpg2_all(n))
   print("Loading Files")
   print(files)
   fall = addfiles (files,"r")
   ListSetType(fall,"cat")
   delete(files)

   files = systemfunc ("ls " + fpg2_omg(n))
   print(files)
   fomg = addfiles (files,"r")
   ListSetType(fomg,"cat")
   delete(files)

   do m = 0,nvars-1
     
     if (m.ne.omgid) then      
       var = fall[:]->$VARS(m)$
     else
       var = fomg[:]->$VARS(m)$
     end if     

     print("pg2, m: " + m)
     print(VARS(m) + ": " + var)
     
     pNam = unique_string("tmp")
     plot@$pNam$ = gsn_add_polymarker(wks,plot(m),dx(n),var,res)
   end do
   delete([/fall,fomg/])

 end do
 delete(dx)

 res@gsMarkerColor = colorhidt

 do n = 0,nhidt-1

   print("Begin case " + n)

   files = systemfunc ("ls " + fhidt_all(n))
   print("Loading Files")
   print(files)
   fall = addfiles (files,"r")
   ListSetType(fall,"cat")
   delete(files)

   files = systemfunc ("ls " + fhidt_omg(n))
   print(files)
   fomg = addfiles (files,"r")
   ListSetType(fomg,"cat")
   delete(files)

   do m = 0,nvars-1

     if (m.ne.omgid) then
       var = fall[:]->$VARS(m)$
     else
       var = fomg[:]->$VARS(m)$
     end if

     if (n.eq.0) then
       print(VARS(m) + " " + var)
     end if

     ;;pNam = unique_string("tmp")
     ;;plot@$pNam$ = gsn_add_polymarker(wks,plot(m),dxdynhidt(n),var,res)
   end do
   delete([/fall,fomg/])

 end do

;*****************************************************
; Manually create and attach legend
;*****************************************************

  res_text                    = True  
  res_text@txFontHeightF      = 0.010;;;09 
  res_text@txJust             = "CenterLeft"

  gsres			      = True
  gsres@gsFillColor = "Green"
  gsres@tfPolyDrawOrder = "PostDraw"
  ;;gsres@gsLineColor = "Black"

  xx = (/0.325/)
  yy0 = (/0.4510/)
  yy1 = (/0.4350/)
  yy2 = (/0.4200/)

  offx = 0.03
  offy = 0.01
  
  xx0 = 0.335
  xxx = (/xx0-offx,xx0-offx,xx0+offx,xx0+offx,xx0-offx/)
  yyy = (/yy1-offy,yy0+offy,yy0+offy,yy1-offy,yy1-offy/)
  gsn_polygon_ndc(wks,xxx,yyy,gsres)


  ll0 = "   pg3"
  ll1 = "   pg2"     ;;;pg3, small ~F33~D~F21~t~B~phys~N~"
  ll2 = "   pg2"
  yy = (/yy0(0),yy1(0),yy2(0)/)
  label = (/ll0(0),ll1(0),ll2(0)/)
  ;;colors = (/colorpg3,colorhidt,colorpg2/)
  colors = (/colorpg3,colorpg2/)
  res@gsMarkerSizeF = 12;;;8
  res@gsMarkerThicknessF = 3
  do m = 0,1;;;nvars-1
    res@gsMarkerColor = colors(m)
    gsn_polymarker_ndc(wks,xx(0),yy(m),res)
    gsn_text_ndc(wks,label(m),xx(0),yy(m),res_text)
  end do

;;;drawNDCGrid(wks)
;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  ;resP@gsnPanelBottom   = 0.05
  ;resPgsnPanelXWhiteSpacePercent = 20
  resP@gsnPanelFigureStrings = (/ "a","b","c","d" /)
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopLeft"
  ;resP@txString = pltTitle
  gsn_panel(wks,plot,(/1,4/),resP)               ; now draw as one plot

frame(wks)

end

