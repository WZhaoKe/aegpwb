# AEG PWB: Things to do list

[TOC]

## General

* Decide whether to stay with conventional of putting factor of 1/2 from wall
  shadowing into TCS. If so, write detailed note for user manual.

* Should reference nodes be hidden in the documentation and EMT - replace
  with small black dots or make invisible? They are not really relevant to 
  using the solver.

* Is keeping the setup phase user visible worth it or useful - maybe not.

* Make third party tools required for Mie Series discovered at run time and 
  error message if not found. Add instruction for obtaining and installing.
  
* scattnlay has been updated and is GPL3. Could consider distributing with
  toolbox.

## Toolbox

* Use Legendre quadrature in pwbLucentWall.

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

* Integrate and test new version of scattnlay. 

* Improve mode density determination algorithm in pwbCubiodCavityModesCount.

* Write function [ numModesInBW ] = pwbCavityModesInBandwidth( numModes , BW )
  that is more accurate than multipling BW by modeDensity when numModes is
  obtained from exact mode counting. See 
  [Wi](https://en.wikipedia.org/wiki/Electromagnetic_reverberation_chamber)
  numModesBW = numModes(f+BW/2) - numModes(f-BW/2) by need care with endpoints
  and sampling rate.


## Solver

* Tests for probability distributions.

* Enforce it so that once a model is set up further objects cannot be added.

* Estimate polarisabilities of apertures defined by TCS/TE from area and 
  cut-off frequency by assuming circular aperture

* Add areScatterers attribute to cavitites.

* Make scatterer change cavity outline to double circle.

* For Cuboid cavity use actual mode frequencies for first 1000? modes 
  spliced onto Weyl estimate at higher frequencies.

* [Maybe] Make is possible to delete objects. Difficult as they are linked.
  Maybe refuse to delete if object is referenced by another and feedback to
  user names of linked onjects so the user can delete recursively if desired.
