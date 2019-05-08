load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ;
  ; user set variables
  ;
  vname      = (/"p2f_CLDICE","p2f_CLDICE_fvm","p2f_CLDICE_err_fvm"/)
;  vname                 = "PS"      ; variable you wish to output
  horizontal_resolution = "ne30_ne30" ; -res setting
  compset="FKESSLER"                ; compset used
  iday  = 0                        ; plot day
  output_format = "pdf"             ; output format
  

;******************************************************
; create plot
;******************************************************


;  fnames =  systemfunc("ls no-high-order-prealloc.nc")
  fnames = (/"no-high-order-prealloc.native-grid.nc","default.native-grid.nc","no-high-order-prealloc.native-grid.nc","default.native-grid.nc"/)
  wks = gsn_open_wks(output_format,"mapping.pdf")
  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  fcnt = dimsizes(fnames)
  print(fnames)


  time= fall[0]->time(iday)
  lon = fall[0]->lon
  lat = fall[0]->lat
  nlon=dimsizes(lon)
  nlat=dimsizes(lat)

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
  gsn_define_colormap(wks,"hotcold_18lev")
  

  res                     = True         ; plot modifications desired
  res@gsnMaximize         = True         ; Maximize size of plot in frame
  res@gsnSpreadColors     = True         ; Use full colormap, but start
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True         ; Turn on contour fill
;  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@mpOutlineOn     = False       ; No continents
  res@cnFillMode="RasterFill"

  res@mpMinLatF = -60.                   ; set the minimum latitude = -70.
  res@mpMaxLatF = 60.                    ; set the maximum latitude = 70.

;  res@mpMinLonF = 30.                    ; set the minimum latitude = -70.
;  res@mpMaxLonF = 210.

  res@gsnStringFontHeightF = 0.02
  res@tiMainFontHeightF = 0.025
  res@lbLabelFontHeightF = 0.02
  res@tmXBLabelFontHeightF = 0.015
  res@tmYLLabelFontHeightF = 0.015
  res@pmLabelBarOrthogonalPosF = 0.2


  plot = new(3*fcnt,graphic) 
  plotk=0
  do k=0,fcnt-1
    do nvar=0,2
      if (nvar.eq.0) then
        lat1d = fall[k]->lat          ; Pull off lat/lon variable and
        lon1d = fall[k]->lon          ; convert both to 1D.
      else
        lat1d = fall[k]->lat_fvm          ; Pull off lat/lon variable and
        lon1d = fall[k]->lon_fvm          ; convert both to 1D.      
      end if	
      res@sfXArray            = lon1d        ; Required to tell NCL where to
      res@sfYArray            = lat1d        ; overlay data on globe.

      print("plot "+k)


      if (k.lt.2) then
        var  = fall[k]->$vname(nvar)$(iday,0,:)    ; Read some data; convert to 1D.i
      else
        var  = fall[k]->$vname(nvar)$(iday,5,:)    ; Read some data; convert to 1D.i      
      end if
      if (k.eq.0) then
        if (nvar.eq.0) then	
          res@tiMainString        = "Forcing increment on pg2 (analytical)"
        end if
        if (nvar.eq.1) then
          res@tiMainString        = "Forcing increment mapped to pg3"
        end if
        if (nvar.eq.2) then 
          res@tiMainString        = "Error"
        end if       
      else
        res@tiMainString        = ""
      end if
;      if (nvar.ne.0) then
        if (k.eq.0) then
          res@gsnLeftString = "Default mapping without high-order pre-allocation"
        end if

        if (k.eq.2) then
          res@gsnLeftString = "Default mapping without high-order pre-allocation"
        end if
        if (k.eq.1) then
          res@gsnLeftString = "Default mapping algorithm"
        end if
        if (k.eq.3) then
          res@gsnLeftString = "Default mapping algorithm"
        end if	


;      else

;      end if


      print("row "+k+"  column "+nvar)
      print("max "+max(var)+ "     min "+min(var))
;if (True) then
if (False) then
      if (vname(nvar).eq."p2f_CLDICE_err_fvm") then
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnMinLevelValF  = -0.8
        res@cnMaxLevelValF  = 0.8
        res@cnLevelSpacingF = 0.15
        gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
      end if
      if (vname(nvar).eq."p2f_CLDICE_fvm") then
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnMinLevelValF  = 1.0
        res@cnMaxLevelValF  = 2.0
        res@cnLevelSpacingF = 0.05

      end if
      if (vname(nvar).eq."p2f_CLDICE") then
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnMinLevelValF  = 1.0
        res@cnMaxLevelValF  = 2.0
        res@cnLevelSpacingF = 0.05
        gsn_define_colormap(wks,"wh-bl-gr-ye-re")	
      end if      
end if
      res@mpCenterLonF = 180.0           ; Rotate the projection.
      plot(plotk) = gsn_csm_contour_map_ce(wks,var,res)
      plotk=plotk+1
      delete(var)
      delete(lat1d)
      delete(lon1d)
      delete(res@sfXArray)
      delete(res@sfYArray)      
    end do
  end do
;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelLabelBar = True                  ; add common colorbar
;  resP@gsnPanelBottom   = 0.05
;  resP@txString   = "Day "+time+" moist baroclinic wave"
;  resP@gsnPanelYWhiteSpacePercent = 10.0
  resP@gsnPanelXWhiteSpacePercent = 4.0
  gsn_panel(wks,plot,(/fcnt,3/),resP)            ; now draw as one plot

  txres               = True
;  txres@txFontHeightF = 0.015
;  gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end