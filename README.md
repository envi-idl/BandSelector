# BandSelector and VisualizationSelector

Simple procedures that return the zero-based index for bands that correspond to broad wavelengths (i.e. red, green, blue). The procedures return an orderdhash that contains key-value pairs for the bands if they are present.

BandSelector will return the bands that correspond to broadband wavelengths that you are looking for and the VisualizationSelector will return the RGB or CIR bands for an image. 

The use case for the VisualizationSelector is for automated generation of a visual representation of an image with a priority of RGB -> CIR -> First band of an image.

## General Usage

Both procedures return an orderedhash of the bands that match the user request. If you want to check to see if a band is present, then you simply need to use the ```idl orderedhash.hasKey(tag)``` method where `tag` corresponds to the keyword name that was set. For example, to check and see if a raster has the red band you would do:

```idl
;get the red band from our raster
bandSelector,$
  INPUT_RASTER = raster,$
  /RED,$
  OUTPUT_BANDS = output_bands

;check if the band is present
;NOTE: this is case sensitive, must be in all caps
if output_bands.hasKey('RED') then begin
  print, 'Red band is present'
endif else begin
  print, 'Red band is missing'
endelse
```

## Usage for BandSelector

Here is an example for how you could get the zero-based index locations for the bands:

```idl
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
```

the output in the IDL console should then be:

```json
{
    "BLUE": 0,
    "GREEN": 1,
    "RED": 2
}
```

### Quiet Keyword
You can specify the `QUIET` keyword when using this routine and most errors will be swallowed and an empty orderedhash will then be returned. This is best for production environments where you want to gracefully handle errors because the default checking of what bands are present can then handle eny exceptions present.

### Another Example

You could use this routine to get the SWIR band from a dataset, check if it is present, or throw an error. Here is how you could do that:


```idl
; start ENVI
e = envi(/HEADLESS)

; Open the first input file
file = filePath('qb_boulder_msi', ROOT_DIR = e.ROOT_DIR, $
  SUBDIRECTORY = ['data'])
msiRaster = e.openRaster(file)

;get the RGB bands from our raster
bandSelector,$
  INPUT_RASTER = msiRaster,$
  /SWIR1,$
  OUTPUT_BANDS = output_bands

;make sure we have the swir1 band
if ~output_bands.hasKey('SWIR1') then begin
  message, 'raster does not have the SWIR1 band, required!'
endif
```

## Usage for VisualizationSelector

```idl
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
```

In the IDL console you should then see the following:


```json
{
    "CIR": [3, 2, 1],
    "RGB": [2, 1, 0]
}
```

## License

Licensed under MIT. See LICENSE.txt for additional details and information.

(c) 2017 Exelis Visual Information Solutions, Inc., a subsidiary of Harris Corporation.
