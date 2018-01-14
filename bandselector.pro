;h+
; Copyright (c)  Exelis Visual Information Solutions, Inc., a subsidiary of Harris Corporation
;h-

;+
; :Description:
;    Procedure that will return the zero-based indices for the bands
;    that match the requested broadband definitions. If no bands match,
;    then the `OUTPUT_BANDS` keyword will have an orderedhash with no
;    key-value pairs which can be detected with n_elements(output_bands).
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
;    BLUE: in, optional, type=bool
;      Set to check for a blue band.
;    GREEN: in, optional, type=bool
;      Set to check for a green band.
;    RED: in, optional, type=bool
;      Set to check for a red band.
;    NIR: in, optional, type=bool
;      Set to check for a nir band.
;    SWIR1: in, optional, type=bool
;      Set to check for a SWIR1 band
;    SWIR2: in, optional, type=bool
;      Set to check for a SWIR2 band
;    OUTPUT_BANDS: out, required, type=orderedhash
;      This contains a key-value pair of band name and the zero-based index
;      for what band in the raster represents that wavelength.
;    QUIET: in, optional, type=boolean, default=false
;      Optionally specify this keyword to have the routine silently
;      process errors and return an empty orderedhash in `OUTPUT_BANDS`.
;
; :Author: Zachary Norman - GitHub: znorman-harris
;-
pro bandSelector,$
  INPUT_RASTER = input_raster,$
  BLUE = blue,$
  GREEN = green,$
  QUIET = quiet,$
  RED = red,$
  NIR = nir,$
  SWIR1 = swir1,$
  SWIR2 = swir2,$
  OUTPUT_BANDS = output_bands
  compile_opt idl2

  ;make sure EVNI is running
  if (envi(/CURRENT) eq !NULL) then begin
    message, 'ENVI has not started yet, requried!'
  endif

  ;build arrays for the wavelengths that we will search
  ; on the form [min, mid, max] in nanometers
  rangeInfo = orderedhash()
  rangeInfo['BLUE']  = [400,   470,  500]
  rangeInfo['GREEN'] = [500,   550,  600]
  rangeInfo['RED']   = [600,   650,  700]
  rangeInfo['NIR']   = [760,   860,  960]
  rangeInfo['SWIR1'] = [1550, 1650, 1750]
  rangeInfo['SWIR2'] = [2080, 2220, 2350]

  ;check which bands we want to find
  checkBands = list()
  if keyword_set(blue)  then checkBands.Add, 'BLUE'
  if keyword_set(green) then checkBands.Add, 'GREEN'
  if keyword_set(red)   then checkBands.Add, 'RED'
  if keyword_set(nir)   then checkBands.Add, 'NIR'
  if keyword_set(swir1) then checkBands.Add, 'SWIR1'
  if keyword_set(swir2) then checkBands.Add, 'SWIR2'

  ;make a hash to contain the output band indiced
  output_bands = orderedhash()

  ;make sure our input raster was specified
  if (input_Raster eq !NULL) then begin
    if ~keyword_set(quiet) then begin
      message, 'INPUT_RASTER not specified, required!'
    endif else begin
      return
    endelse
  endif
  if ~isa(input_raster, 'ENVIRASTER') then begin
    if ~keyword_set(quiet) then begin
      message, 'INPUT_RASTER specified, but is not of type ENVIRaster, required!'
    endif else begin
      return
    endelse
  endif

  ;make sure our raster has wavelength information
  if ~input_raster.METADATA.hasTag('wavelength units') then begin
    if ~keyword_set(quiet) then begin
      message, 'INPUT_RASTER does not have valid wavelength unit metadata, required.'
    endif else begin
      return
    endelse
  endif
  wavelength_units = input_raster.metadata['wavelength units']
  if ~input_raster.METADATA.hasTag('wavelength') then begin
    if ~keyword_set(quiet) then begin
      message, 'INPUT_RASTER does not have valid wavelength metadata, required.'
    endif else begin
      return
    endelse
  endif
  wavelengths = input_raster.metadata['wavelength']

  ;account for a few differences in wavelength units
  factor = -1
  case strlowcase(wavelength_units) of
    'nanometers'  : factor = 1.0
    'nm'          : factor = 1.0
    'micrometers' : factor = 1000.0
    'um'          : factor = 1000.0
    'millimeters' : factor = 1000000.0
    'mm'          : factor = 1000000.0
    'centimeters' : factor = 10000000.0
    'cm'          : factor = 10000000.0
    'meters'      : factor = 100000000.0
    'm'           : factor = 100000000.0
    else: begin
      if ~keyword_set(quiet) then begin
        message, 'Unknown wavelength type of "' + strtrim(wavelength_units,2) + '" in raster wavelength metadata.'
      endif else begin
        return
      endelse
    end
  endcase

  ;scale wavelengths accordingly
  wavelengths *= factor

  ;find our bands that we need
  foreach band, checkBands, idx do begin
    ;get the range info
    range = rangeInfo[band]

    match = where((wavelengths ge range[0]) AND (wavelengths le range[2]), countMatch)
    case (countMatch) of
      ;one red band, pick the only one
      1:begin
        output_bands[band] = match[0]
      end
      ;more than one red band, pick closest to center
      2:begin
        diff = abs(wavelengths[match] - range[1])
        !NULL = min(diff, idxMin)
        output_bands[band] = match[idxMin]
      end
      ;no matches, do nothing
      else:
    endcase
  endforeach
end


;main level program for how to use this routine

; start ENVI
e = envi(/HEADLESS)

; Open the first input file
file = filePath('qb_boulder_msi', ROOT_DIR = e.ROOT_DIR, $
  SUBDIRECTORY = ['data'])
msiRaster = e.openRaster(file)

;get the RGB bands from our raster
bandSelector,$
  INPUT_RASTER = msiRaster,$
  /BLUE, /GREEN, /RED,$
  OUTPUT_BANDS = output_bands

;print to the console
print, output_bands, /IMPLIED_PRINT

end