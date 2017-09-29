# BandSelector

Simple procedure that returns the zero-based index for bands that correspond to broad wavelengths (i.e. red, green, blue). The procedure returns an orderdhash that contains key-value pairs for the bands if they are present.


## Usage

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

## License

Licensed under MIT. See LICENSE.txt for additional details and information.

(c) 2017 Exelis Visual Information Solutions, Inc., a subsidiary of Harris Corporation.
