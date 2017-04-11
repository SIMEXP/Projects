# Preprocessing HCP rest data

## Already done by HCP
- gradient non-linearity correction
- 6DOF time point realignment to single band ref image for motion correction
- motion estimates are output like this:
    1. x translation in mm
    2. y translation in mm
    3. z translation in mm
    4. x rotation in degrees
    5. y rotation in degrees
    6. z rotation in degrees
    7. derivative of x translation
    8. derivative of y translation
    9. derivative of z translation
    10. derivative of x rotation
    11. derivative of y rotation
    12. derivative of z rotation
- demeaned and linear detrended motion parameters as well
- correction for phase encoding related artifacts
- registered to MNI template (linear -> non-linear)
- volume mean centered at 10.000 and brain masked

## Still need to happen by us
- computing FD
    - we have the motion parameters, just need to convert them
    - currently done in __niak_brick_build_confounds__ (ln: 222)
    - based on Power 2011 we can compute that directly as well
    - need to figure out how to either do that with niak or how to recode (probably easier with niak - __niak_transf2param__)
- regressing nuisance covariates
    - motion parameters
    - slow time drifts
    - WM average
    - CSF average
        - masks for both have to be taken from template or inside niak
        - maybe have to be back-transformed (annoying)
- temporal filtering
    - highpass @ 0.1 Hz
- spatial smoothing

## Procedure:
1. Generate a WM and GM mask from wmparc
    - seems almost done
2. Figure out how to compute FD from the motion estimates
    - understand why they have a detrended version of the motion estimates
3. Figure out how to do spatial smoothing
    - probably with some external package?
    - maybe not even necessary?
