;**************************************
;lagrange.ncl
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
;**************************************
begin
;****************************************

 plottype = 2 ;0 = 3x3
	      ;1 = 2x2
	      ;2 = exchange grid
 

;******************************************************
; plot options
;******************************************************
;---Start the graphics
  wkstype = "pdf"
  wkstype@wkBackgroundOpacityF    = 0.
  wks = gsn_open_wks("pdf","temp")

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineDashPattern = 0                    ; solid line
  res_lines@gsLineThicknessF  = 4.                   ; line thicker
  res_lines@gsLineColor = "Black"

  resb			      = True
  resb@gsLineColor 	      = "cadetblue3";;;"deepskyblue"
  resb@gsLineDashPattern = 0                    ; solid line
  resb@gsLineThicknessF  = 4.

;*****************************************************
; define grids
;******************************************************

  ;;note xx spans 0.3-0.7
  ;;     yy spans 0.3-0.7

  ;;;Create Frame First
  ds = 0.
  xframe = (/ 0.315-ds, 0.315-ds, 0.685+ds, 0.685+ds, 0.315-ds /)
  yframe = (/ 0.315-ds, 0.685+ds, 0.685+ds, 0.315-ds, 0.315-ds /)

  ;;;Create 3x3 physgrid grid with grid id numbers

  dfv = 0.4/3

  pg3x0 = (/0.30    ,0.30+dfv  ,0.70-dfv,0.30    ,0.30+dfv,0.70-dfv,0.30    ,0.30+dfv,0.70-dfv/)
  pg3y0 = (/0.70-dfv,0.70-dfv  ,0.70-dfv,0.30+dfv,0.30+dfv,0.30+dfv,0.30    ,0.30    ,0.30    /)

  pg3x1 = (/0.30    ,0.30+dfv  ,0.70-dfv,0.30    ,0.30+dfv,0.70-dfv,0.30    ,0.30+dfv,0.70-dfv/)
  pg3y1 = (/0.70    ,0.70      ,0.70    ,0.70-dfv,0.70-dfv,0.70-dfv,0.30+dfv,0.30+dfv,0.30+dfv/)

  pg3x2 = (/0.30+dfv,0.30+2*dfv,0.70    ,0.30+dfv,0.70-dfv,0.70    ,0.30+dfv,0.70-dfv,0.70    /)
  pg3y2 = (/0.70    ,0.70      ,0.70    ,0.70-dfv,0.70-dfv,0.70-dfv,0.30+dfv,0.30+dfv,0.30+dfv/)

  pg3x3 = (/0.30+dfv,0.30+2*dfv,0.70    ,0.30+dfv,0.70-dfv,0.70    ,0.30+dfv,0.70-dfv,0.70    /)
  pg3y3 = (/0.70-dfv,0.70-dfv  ,0.70-dfv,0.30+dfv,0.30+dfv,0.30+dfv,0.30    ,0.30    ,0.30    /)

  pg3x4 = pg3x0
  pg3y4 = pg3y0

  ;;;Create 2x2 physgrid grid with grid id numbers

  dfv = 0.4/2
  
  pg2x0 = (/0.30    ,0.70-dfv,0.30    ,0.70-dfv/)
  pg2y0 = (/0.70-dfv,0.70-dfv,0.30    ,0.30    /)
  
  pg2x1 = (/0.30    ,0.70-dfv,0.30    ,0.70-dfv/)
  pg2y1 = (/0.70    ,0.70    ,0.30+dfv,0.30+dfv/)
  
  pg2x2 = (/0.30+dfv,0.70    ,0.30+dfv,0.70    /)
  pg2y2 = (/0.70    ,0.70    ,0.30+dfv,0.30+dfv/)
  
  pg2x3 = (/0.30+dfv,0.70    ,0.30+dfv,0.70    /)
  pg2y3 = (/0.70-dfv,0.70-dfv,0.30    ,0.30    /)
  
  pg2x4 = pg2x0
  pg2y4 = pg2y0

;******************************************************
; begin figures
;******************************************************

  offx = 0.
  offy = 0.
  overlap = False

  if (plottype.eq.0) then
    ;;res_lines@gsLineColor = "Red"
    x0 = pg3x0
    y0 = pg3y0
    x1 = pg3x1
    y1 = pg3y1
    x2 = pg3x2
    y2 = pg3y2
    x3 = pg3x3
    y3 = pg3y3
    x4 = pg3x4
    y4 = pg3y4
  else if (plottype.eq.1) then
    ;;res_lines@gsLineColor = "Blue"
    x0 = pg2x0
    y0 = pg2y0
    x1 = pg2x1
    y1 = pg2y1
    x2 = pg2x2
    y2 = pg2y2
    x3 = pg2x3
    y3 = pg2y3
    x4 = pg2x4
    y4 = pg2y4
  else if (plottype.eq.2) then
    overlap = True
    ;;res_lines@gsLineColor = "Red"
    x0 = pg3x0
    y0 = pg3y0
    x1 = pg3x1
    y1 = pg3y1
    x2 = pg3x2
    y2 = pg3y2
    x3 = pg3x3
    y3 = pg3y3
    x4 = pg3x4
    y4 = pg3y4
  end if
  end if
  end if

  ;;do frame first
  do m = 0,10
    gsn_polyline_ndc(wks,xframe,yframe,resb)
    ds = ds + 0.003
    xframe = (/ 0.315-ds, 0.315-ds, 0.685+ds, 0.685+ds, 0.315-ds /)
    yframe = (/ 0.315-ds, 0.685+ds, 0.685+ds, 0.315-ds, 0.315-ds /)
  end do

  nx = dimsizes(x0)
  do m = 0,nx-1
    xbox = (/x0(m),x1(m),x2(m),x3(m),x4(m)/)+offx
    ybox = (/y0(m),y1(m),y2(m),y3(m),y4(m)/)+offy
    gsn_polyline_ndc(wks,xbox,ybox,res_lines)
  end do

  if (overlap) then
    delete([/x0,y0,x1,y1,x2,y2,x3,y3,x4,y4/])
    x0 = pg2x0
    y0 = pg2y0
    x1 = pg2x1
    y1 = pg2y1
    x2 = pg2x2
    y2 = pg2y2
    x3 = pg2x3
    y3 = pg2y3
    x4 = pg2x4
    y4 = pg2y4

    ;;res_lines@gsLineColor = "Blue"
    ;;res_lines@gsLineDashPattern = 2
    nx = dimsizes(x0)
    do m = 0,nx-1
      xbox = (/x0(m),x1(m),x2(m),x3(m),x4(m)/)+offx
      ybox = (/y0(m),y1(m),y2(m),y3(m),y4(m)/)+offy
      gsn_polyline_ndc(wks,xbox,ybox,res_lines)
    end do
  end if

  ;;gsn_text_ndc(wks,"Element 1",0.435,0.875,txres)
  ;;gsn_text_ndc(wks,"Element 2",0.525,0.875,txres)
  ;;gsn_text_ndc(wks,"Element 3",0.612,0.875,txres)

  ;;;;drawNDCGrid(wks)
  frame(wks)

end

