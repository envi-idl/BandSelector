;h+
; Copyright (c)  Exelis Visual Information Solutions, Inc., a subsidiary of Harris Corporation
;h-

;+
; :Description:
;    Procedure that will return RGB or CIR band combinations for a raster
;    if they exist.
;
;    The ranges for the different bands were taken from the ENVI
;    definition for broadband spectral indices which can be found at the
;    following link under the "Band Assignments" section:
;
;    https://www.harrisgeospatial.com/docs/SpectralIndices.html
;
;    See the main level program below for an example.
;
;
;
; :Keywords:
;    INPUT_RASTER: in, required, type=ENVIRaster
;      The raster that you want to band the right bands for. Must have valid
;      wavelengths and wavelength units to be processed otherwise an error
;      will be thrown.
;    CIR: in, optional, type=bool
;      Set to check for CIR visualization bands.
;    RGB: in, optional, type=bool
;      Set to check for RGB visualization bands.
;    OUTPUT_BANDS: out, required, type=orderedhash
;      This contains a key-value pair of band name and the zero-based index
;      for what band in the raster represents that wavelength.
;
; :Author: Zachary Norman - GitHub: znorman-harris
;-
pro visualizationSelector,$
  INPUT_RASTER = input_raster,$
  CIR = cir,$
  RGB = rgb,$
  OUTPUT_BANDS = output_bands
  compile_opt idl2

  ;make sure EVNI is running
  if (envi(/CURRENT) eq !NULL) then begin
    message, 'ENVI has not started yet, requried!'
  endif
  
  ;initialize output variable
  output_bands = orderedhash()

  ;check what bands are avaiable
  bandSelector,$
    INPUT_RASTER = input_raster,$
    /RED, /GREEN, /BLUE, /NIR,$
    QUIET = 1,$
    OUTPUT_BANDS = specific_bands
  
  ;check for cir
  if keyword_set(cir) then begin
    if specific_bands.hasKey('NIR') AND specific_bands.hasKey('RED') AND specific_bands.hasKey('GREEN') then begin
      output_bands['CIR'] = [specific_bands['NIR'], specific_bands['RED'], specific_bands['GREEN']]
    endif
  endif
  
  ;check for rgb
  if keyword_set(rgb) then begin
    if specific_bands.hasKey('RED') AND specific_bands.hasKey('GREEN') AND specific_bands.hasKey('BLUE') then begin
      output_bands['RGB'] = [specific_bands['RED'], specific_bands['GREEN'], specific_bands['BLUE']]
    endif
  endif
end


;main level program for how to use this routine

; start ENVI
e = envi(/HEADLESS)

; Open the first input file
file = filePath('qb_boulder_msi', ROOT_DIR = e.ROOT_DIR, $
  SUBDIRECTORY = ['data'])
msiRaster = e.openRaster(file)

;get the RGB bands from our raster
visualizationSelector,$
  INPUT_RASTER = msiRaster,$
  /RGB, /CIR, $
  OUTPUT_BANDS = output_bands

;print to the console
print, output_bands, /IMPLIED_PRINT
end