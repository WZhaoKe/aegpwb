# AEG Power Balance Toolbox User Manual

I. D. Flintoft

Version 0.1, 16/08/2016

[TOC]

# Glossary

Acronym | Expansion
:-------|:----------------------------------------------
ACS     | Absorption cross-section
AE      | Absorption efficiency
CCDF    | Complementary cumulative distribution function
CCS     | Coupling cross-section
CDF     | Cumulative distribution function
CE      | Coupling efficiency
EMT     | Electromagnetic topology
GO      | Geometric optics
JIT     | Just-in-time
PDF     | Probability density function
PoA     | Point of absorption
PoC     | Point of coupling
PoE     | Point of entry/exit
PWB     | Power balance
SC      | Short circuited
SCS     | Scattering cross-section
SE      | Scattering efficiency
TCS     | Transmission cross-section
TE      | Transmission efficiency
TE      | Transverse electric
TM      | Transverse magnetic


# Utilities

## `pwbImportAndInterp`

**[TBC]**

## `pwbDistDiffuse`

**[TBC]**

# Cavities

## `pwbCuboidCavityModeFreqs`

**[TBC]**

## `pwbCuboidCavityModesCount`

**[TBC]**

## `pwbCuboidCavityModesLiu`

**[TBC]**

## `pwbGenericCavityModesWeyl`

**[TBC]**

## `pwbGenericCavityWallACS`

**[TBC]**

## `pwbEnergyParamsFromCCS`

**[TBC]**

## `pwbEnergyParamsFromDecayRate`

**[TBC]**

## `pwbEnergyParamsFromQ`

**[TBC]**

## `pwbEnergyParamsFromTimeConst`

**[TBC]**

## `pwbCoupledCavities`

**[TBC]**

# Antennas

## `pwbAntenna`

**[TBC]**

# Absorbers

## `pwbMetalSurface`

The function 

    [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )

determines the average absorption cross-section and efficiency of a highly
conducting surface by averaging the reflectance determined from the Fresnel
coefficients over the angles of arrival and the polarisations ([Orfanidis2016][]).
       
The input arguments and output values are:

argument/return | type               | unit  | description
:---------------|:------------------:|:-----:|:-------------------------
`f`             | string             | Hz    | frequencies
`area`          | real scalar        | m^2   | area
`sigma`         | real vector [1]    | S/m   | conductivity
`mu_r`          | real vector [1]    | -     | relative permeability
`ACS`           | real vector        | m^2   | absorption cross-section
`AE`            | real vector        | -     | absorbers efficiency

[1] The material vectors must be either scalars for frequency independent parameters 
or have the same length as `f` for frequency dependent parameters.

## `pwbDielectricSurface`

The function 

    [ ACS , AE ] = pwbDielectricSurface( f , area , eps_r , sigma , mu_r )

determines the average absorption cross-section and efficiency of a lossy 
dielectric surface by averaging the reflectance determined from the Fresnel
coefficients over the angles of arrival and the polarisations ([Orfanidis2016][]).
        
The input arguments and output values are:

argument/return | type               | unit  | description
:---------------|:------------------:|:-----:|:-----------------------------
`f`             | string             | Hz    | frequencies
`area`          | real scalar        | m^2   | area
`eps_r`         | complex vector [1] | -     | complex relative permittivity
`sigma`         | real vector [1]    | S/m   | conductivity
`mu_r`          | real vector [1]    | -     | relative permeability
`ACS`           | real vector        | m^2   | absorption cross-section
`AE`            | real vector        | -     | absorbers efficiency

[1] The material vectors must be either scalars for frequency independent parameters 
or have the same length as `f` for frequency dependent parameters.

## `pwbLaminatedSurface`

![Figure: Laminated surface](figures/LaminatedSurface.png)

The function 

    [ ACS , AE ] = pwbLaminatedSurface( f , area , thicknesses , eps_r , sigma , mu_r , sigmam )

determines the (average) absorption cross-section and efficiency of a lossy 
multilayer surface. It uses a multi-layer reflection and transmission code to
determine the reflectance at oblique incidence for TE and TM polarisations and 
then averages over the angles of arrival and the polarisations ([Orfanidis2016][]).
        
The input arguments and output values are:

argument/return | type              | unit  | description
:---------------|:-----------------:|:-----:|:---------------------------------------
`f`             | string            | Hz    | frequencies
`area`          | real scalar       | m^2   | area
`thicknesses`   | real vector       | m     | thicknesses of layers, outer first
`eps_r`         | complex array [1] | -     | complex relative permittivity of layers
`sigma`         | real array [1]    | S/m   | conductivities of layers
`mu_r`          | real array [1]    | -     | relative permeabilities of layers
`sigmam`        | real array [1]    | ohm/m | magnetic conductivities of layers
`ACS`           | real vector       | m^2   | absorption cross-section
`AE`            | real vector       | -     | absorbers efficiency

[1] The material arrays must have `numLayer` columns and either one row for frequency
independent parameters or the same number of rows as the length of `f` for frequency
dependent parameters.

## `pwbSphere`

The function 

    [ ACS , AE ] = pwbSphere( f , radius , eps_r , sigma , mu_r )

determines the (average) absorption cross-section and efficiency of a lossy 
homogeneous sphere. It uses a [Mie Series][] calculation to determine the 
absorption efficiency. Interfaces are provide for a number of different Mie
codes which can be called explicity using

    [ ACS , AE ] = pwbLaminatedSphere_Matzler( f , radius , eps_r , sigma , mu_r )
    [ ACS , AE ] = pwbLaminatedSphere_Markowicz( f , radius , eps_r , sigma , mu_r )
    
The generic function `pwbSphere` chooses the best available code it can find.  
        
The input arguments and output values are:

argument/return | type            | unit | description
:---------------|:---------------:|:----:|:------------------------------
`f`             | string          | Hz   | frequencies
`radius`        | real scalar     | m    | radius of sphere 
`eps_r`         | complex vector  | -    | complex relative permittivity
`sigma`         | real vector [1] | S/m  | conductivity
`mu_r`          | real vector [1] | -    | relative permeability
`ACS`           | real vector     | m^2  | absorption cross-section
`AE`            | real vector     | -    | absorbers efficiency

[1] Either a scalar of vector with the same length as `f`.

### `pwbSphere_Matzler`

This version of the function uses Christian Matzler's MATLAB code 
([Matzler2002][],[Prahl2016][]).

### `pwbSphere_Markowicz`

This version of the function uses a MATLAB implementation of Bohren and
Huffman's code ([Bohren2004][],[Markowicz2016][]).

## `pwbLaminatedSphere`

![Figure: Sphere](figures/LaminatedSphere.png)

The function 

    [ ACS , AE ] = pwbLaminatedSphere( f , radii , eps_r , sigma , mu_r )

determines the (average) absorption cross-section and efficiency of a lossy 
multilayer sphere. It uses a [Mie Series][] calculation to determine the 
absorption efficiency. Interfaces are provide for a number of different Mie
codes which can be called explicity using

    [ ACS , AE ] = pwbLaminatedSphere_SPlaC( f , radii , eps_r , sigma , mu_r )
    [ ACS , AE ] = pwbLaminatedSphere_PenaPal( f , radii , eps_r , sigma , mu_r )
    [ ACS , AE ] = pwbLaminatedSphere_PenaPalM( f , radii , eps_r , sigma , mu_r )
    
The generic function `pwbLaminatedSphere` chooses the best available code it can find.  
        
The input arguments and output values are:

argument/return | type              | unit | description
:---------------|:-----------------:|:----:|:---------------------------------------
`f`             | string            | Hz   | frequencies
`radii`         | real vector       | m    | radii of layers 
`eps_r`         | complex array [1] | -    | complex relative permittivity of layers
`sigma`         | real array [1]    | S/m  | conductivities of layers
`mu_r`          | real array [1]    | -    | relative permeabilities of layers
`ACS`           | real vector       | m^2  | absorption cross-section
`AE`            | real vector       | -    | absorbers efficiency

[1] The material arrays must have `numLayer` columns and either one row for frequency
independent parameters or the same number of rows as the length of `f` for frequency
dependent parameters.

### `pwbLaminatedSphere_SPlaC`

This version of the function uses the SERS and Plasmonics Codes (SPlaC) package 
([SPlaC][],[LeRu2009][]).
If appears to give the large dynamic range with respect to the loss and 
electrical size of the sphere. 

### `pwbLaminatedSphere_PenaPal`

This version of the function uses the C program from Pena and Pal's more recent 
scattnlay package ([scattnlay_v2][],[Pena2009][]).
It appears to provide a moderate dynamic range with respect to the loss and 
electrical size of the sphere.

### `pwbLaminatedSphere_PenaPalM`

This version of the function uses the MATLAB program from Pena and Pal's 
original scattnlay package ([scattnlay_v1][],[Pena2009][]).
It appears to provide a moderate dynamic range with respect to the loss and 
electrical size of the sphere.

# Apertures

## `pwbApertureCircularPol`

**[TBC]**

## `pwbApertureEllipticalPol`

**[TBC]**

## `pwbApertureRectangularPol2`

**[TBC]**

## `pwbApertureRectangularPol`

**[TBC]**

## `pwbApertureSquarePol`

**[TBC]**

## `pwbApertureTCS`

**[TBC]**

## `pwbLucentWall`

![Figure: Lucent wall](figures/LaminatedWall.png)

The function 

    [ ACS1 , ACS2 , TCS , AE1 , AE2 , TE ] = ...
       pwbLucentWall( f , area , thicknesses , eps_r , sigma , mu_r )

determines the average absorption and transmission cross-sections and efficiencies
of a lossy multilayer surface. It uses a multi-layer reflection and transmission code 
to determine the reflectance at oblique incidence for TE and TM polarisations and 
then averages over the angles of arrival and the polarisations ([Orfanidis2016][]).

The input arguments and output values are:

argument/return | type              | unit  | description
:---------------|:-----------------:|:-----:|:---------------------------------------
`f`             | string            | Hz    | frequencies
`area`          | real scalar       | m^2   | area
`thicknesses`   | real vector       | m     | thicknesses of layers, side 1 first
`eps_r`         | complex array [1] | -     | complex relative permittivity of layers
`sigma`         | real array [1]    | S/m   | conductivities of layers
`mu_r`          | real array [1]    | -     | relative permeabilities of layers
`ACS1`          | real vector       | m^2   | absorption cross-section of side 1
`ACS2`          | real vector       | m^2   | absorption cross-section of side 2
`TCS`           | real vector       | m^2   | transmission cross-section
`AE1`           | real vector       | -     | absorbers efficiency of side 1
`AE2`           | real vector       | -     | absorbers efficiency of side 2
`tE`            | real vector       | -     | transmission efficiency

[1] The material arrays must have `numLayer` columns and either one row for frequency
independent parameters or the same number of rows as the length of `f` for frequency
dependent parameters.

# References

[Bohren2004]: http://onlinelibrary.wiley.com/book/10.1002/9783527618156

([Bohren2004]) C. F. Bohren and D. R. Huffman, "Absorption and Scattering of Light by Small
Particles", Wiley-VCH Verlag GmbH & Co. KGaA, Weinheim, 2004.

[LeRu2009]: http://store.elsevier.com/product.jsp?isbn=9780080931555
 
([LeRu2009]) E. C. Le Ru and P. G. Etchegoin, Principles of Surface-Enhanced Raman Spectroscopy and Related 
Plasmonic Effects, Elsevier, Amsterdam, 2009.

[Liu1983]: http://nvlpubs.nist.gov/nistpubs/Legacy/TN/nbstechnicalnote1066.pdf 

([Liu1983]) B. H. Liu, D. C. Chang, and M. T. Ma, "Eigenmodes and the Composite 
Quality Factor of a Reverberation Chamber", NBS Technical Note 1066, National Institute 
of Standards and Technology, Boulder, Colorado, 1983.
            
[Markowicz2016]: http://code.google.com/p/scatterlib/wiki/Spheres

([Markowicz2016]) K. Markowicz, in "scatterlib" (August 16, 2016),
URL: http://code.google.com/p/scatterlib/wiki/Spheres.

[Matzler2002]: http://www.atmo.arizona.edu/students/courselinks/spring08/atmo336s1/courses/spring09/atmo656b/maetzler_mie_v2.pdf

([Matzler2002]) C. Mätzler, "MATLAB functions for Mie scattering and absorption", 
Res. Rep. 2002-08, Inst. für Angew. Phys., Bern., 2002.

[Orfanidis2016]: http://www.ece.rutgers.edu/~orfanidi/ew

([Orfanidis2016]) S. J. Orfanidis, "Electromagnetic waves and antennas", Rutgers University,
New Brunswick, NJ , 2016. URL: http://www.ece.rutgers.edu/~orfanidi/ewa.

[Pena2009]: http://www.sciencedirect.com/science/article/pii/S0010465509002306

([Pena2009]) O. Pena and U. Pal, "Scattering of electromagnetic radiation by a multilayered sphere", 
Computer Physics Communications, vol. 180, Nov. 2009, pp. 2348-2354.

[Prahl2016]: http://omlc.org/software/mie

([Prahl2016]) S. Prahl, Mie Scattering codes web page, URL: http://omlc.org/software/mie

[scattnlay_v1]: http://cpc.cs.qub.ac.uk/cpc/cgi-bin/showversions.pl/?catid=AEEY&usertype=toolbar&deliverytype=view.

([scattnlay_v1]) Computer Physics Communications Program Library, AEEY_v1_0, 
URL: http://cpc.cs.qub.ac.uk/cpc/cgi-bin/showversions.pl/?catid=AEEY&usertype=toolbar&deliverytype=view.

[scattnlay_v2]: https://github.com/ovidiopr/scattnlay

([scattnlay_v2]) github, scattnlay source code. URL: https://github.com/ovidiopr/scattnlay.

[SPlaC]: http://www.victoria.ac.nz/scps/research/research-groups/raman-lab/numerical-tools/sers-and-plasmonics-codes 

([SPlaC]) SERS and Plasmonics Codes, SPlaC, University of Victoria,
URL: http://www.victoria.ac.nz/scps/research/research-groups/raman-lab/numerical-tools/sers-and-plasmonics-codes
