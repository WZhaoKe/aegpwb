
[TOC]

# AEG PWB: Things to do list

## General

* Decide whether to stay with conventional of putting factor of 1/2 from wall
  shadowing into TCS. If so, write detailed note for user manual.

* Should reference nodes but hidden in the documentation and EMT - replace
  with small black dots ot make invisible? They are not really relevant to 
  using the solver.

* Make third party tools required for Mie Series discovered at run time and 
  error message if not found. Add instruction for obtaining and installing.
  
* scattnlay has been update and is GPL3. Could consider distributing with
  toolbox.

## Toolbox

* Port rest of old toolbox:

  GaussLegendre.m
  pwbAcsFromNormTransmission.m
  pwbBiomat1.m
  pwbBiomat2.m
  pwbBiomat3.m
  pwbDielectricSurfaceKernel.m
  pwbDielectricSurface.m
  pwbMetalSurface.m
  pwbMicrostripLine.m
  pwbMicrostripLineSimple.m
  pwbMicrostripLineZhou.m
  pwbMieMultiLayerSphere2.m
  pwbMieMultiLayerSphere3.m
  pwbMieMultiLayerSphere.m
  pwbMieSphere2.m
  pwbMieSphere.m
  pwbMultiLayerSurface2.m
  pwbMultiLayerSurface3.m 
  pwbMultiLayerSurfaceKernel3R.m
  pwbMultiLayerSurfaceKernel3T.m
  pwbMultiLayerSurface.m
  pwbQuasiStaticEllipsoid.m
  pwbTestMicrostripLine.m
  pwbTestMieSphere.m
  pwbTestMultiLayerSurface.m
  pwbTwoWireLineDiameter.m
  pwbTwoWireLineZc.m
  rcChamberModel2.m
  rcChamberModel.m
  rcStirringEfficiency.m
  tlTestExcitedMicrostrip3.m
  tlTestExcitedMicrostrip4.m
  tlTestExcitedMicrostrip.m

* Integrate and test new version of scattnlay. 

* Improve mode density determination algorithm in pwbCubiodCavityModesCount.

* Write function [ numModesInBW ] = pwbCavityModesInBandwidth( numModes , BW )
  that is more accurate than multipling BW by modeDensity when numModes is
  obtained from exact mode counting. See 
  [Wi](https://en.wikipedia.org/wiki/Electromagnetic_reverberation_chamber)
  numModesBW = numModes(f+BW/2) - numModes(f-BW/2) by need care with endpoints
  and sampling rate.


## Solver

* Enforce it so that once a model is set up further objects cannot be added.

* Estimate polarisabilities of apertures defined by TCS/TE from area and 
  cut-off frequency by assuming circular aperture

* Add areScatterers attribute to cavitites.

* Make scatterer change cavity outline to double circle.

* For Cuboid cavity use actual mode frequencies for first 1000? modes 
  spliced onto Weyl estimate at higher frequencies.
