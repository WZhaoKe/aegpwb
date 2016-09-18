# AEG Power Balance Toolbox To-Do List

[TOC]

## General

* Decide whether to stay with conventional of putting factor of 1/2 from wall
  shadowing into TCS. If so, write detailed note for user manual.

* `scattnlay` is GPL3. Could consider distributing with toolbox.

## Toolbox

* Use Legendre quadrature in `pwbLucentWall`.

* Function [ ACCS ] = pwbAverageCCS( CCS , isHemisphere )

* Port rest of old toolbox:

  pwbTwoWireLineDiameter.m
  pwbTwoWireLineZc.m

  tlTestExcitedMicrostrip3.m
  tlTestExcitedMicrostrip4.m
  tlTestExcitedMicrostrip.m
  pwbMicrostripLine.m
  pwbMicrostripLineSimple.m
  pwbMicrostripLineZhou.m
  pwbTestMicrostripLine.m

  GaussLegendre.m
  pwbAcsFromNormTransmission.m
  pwbBiomat1.m
  pwbBiomat2.m
  pwbBiomat3.m
  pwbQuasiStaticEllipsoid.m
  rcChamberModel2.m
  rcChamberModel.m

  rcStirringEfficiency.m

* Improve mode density determination algorithm in pwbCubiodCavityModesCount.

* Write function [ numModesInBW ] = pwbCavityModesInBandwidth( numModes , BW )
  that is more accurate than multiplying BW by modeDensity when numModes is
  obtained from exact mode counting. See 
  [Wi](https://en.wikipedia.org/wiki/Electromagnetic_reverberation_chamber)
  numModesBW = numModes(f+BW/2) - numModes(f-BW/2) by need care with endpoints
  and sampling rate.

## Solver

* Check and write tests for plane-wave apertures sources.

* Check and write tests for short-circuit field aperture sources.

* estimateCutoffFreq in pwbsAddAperture may not work very well.

* More tests for probability distributions.

* Estimate polarisabilities of apertures defined by TCS/TE from area and 
  cut-off frequency by assuming circular aperture.

* Add areScatterers attribute to cavities.

* For Cuboid cavity use actual mode frequencies for first 1000? modes 
  spliced onto Weyl estimate at higher frequencies.

* Improve state model
 
  Maybe make it possible to delete objects. Difficult as they are linked.
  Maybe refuse to delete if object is referenced by another and feedback to
  user names of linked objects so the user can delete recursively if desired.
  Is it safe to allow adding new objects after solved ans running solver again? 

