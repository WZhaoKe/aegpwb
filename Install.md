# AEG PWB: Installation and testing

[TOC]

## Requirements

The code is written in a portable subset of GNU [Octave][] and [MATLAB][]. 
Additional requirements are:

1. (Optional) To view the EMT of a model the [graphviz][] package must be
   installed on the system with the `dot` command line tool available in the
   system command path.

2. (Optional) A Mie series code needs to be installed in order for the absorption
   in spherical bodies to be calculated. See below for the supported codes.

3. (Optional) To help with development or as an alternative way to download the 
   source a client for the [Mercurial][] Version Control System is required.

The code has been primarily developed using GNU [Octave][] on Linux platforms, 
but should run under both GNU [Octave][] and [MATLAB][] on Linux and Windows 
systems.

## Installation

### Get the source code

Either use Mercurial to clone the source code repository on Bitbucket, for 
example using Mercurial directly from a Linux shell,

    $ hg clone ssh://hg@bitbucket.org/uoyaeg/aegpwb aegpwb-working

or download a zip file of the source code from 
https://bitbucket.org/uoyaeg/aegpwb/downloads and unzip it into a directory call 
aegpwb-working

    $ unzip aeg-aegpwb-x12ey12ey.zip
    $ mv aeg-aegpwb-x12ey12ey aegpwb-working

### Install the m-files

After getting the source code copy the sub-directories called pwb and pwbs from 
the aegpwb-working directory to somewhere convenient and add them to your 
Octave/MATLAB path. For octave you may also need to put the files in the 
sub-directory matcompat somewhere in search path too.

### Install third party Mie codes

Four [Mie codes][] are supported for determining the absorption in spheres:

1. [SPlaC][]: Supports multilayer sphere's with large range of absorption.

2. [scattnlay][]: Supports multilayer sphere's more limited range of absorption.

3. Christian [Matzler][]'s MATLAB functions: Supports homogeneous spheres 
   with moderate range of absorption.

4. [scatterlib][]: Supports homogeneous spheres with limited range of absorption. 

Instruction for installing each of these are given below.

#### SPlaC

The SERS and Plasmonics Code [SPlaC][] is a package of MATLAB functions that
includes Mie Series calculations. To use this code for multi-layer sphere 
cacluations the code should be installed and the required sub-directories 
add to the path, for example, using

    addpath( genpath( '<path to SPlaC>/SPlaC/Mie' ) );

#### [scattnlay_v2][]

Pena and Pal's [scattnlay_v2][] C code execuable can also be used for multi-layer sphere 
cacluations. As a minimum the C program from the package should be compiled using

    make standalone

and the excutable `scattnlay` that is created (in the directory one level up from that
containing the Makefile) copied to a location in the systems command search path.

#### [scattnlay_v][]

Pena and Pal's earlier code [scattnlay_v1][] contains a MATLAB implementation that can 
also be used by the toolbox. To use this installed the package and add the folder 
containing the function nMie to the MATLAB/Octave path.

#### [Matzler][]

Christian Matzler's MATLAB code can also be used for homogeneous spheres. 
Put the function `mie` into a directory in MATLAB/Octave's path.

#### [scatterlib][]

K. Markowicz's MATLAB implementation of Bohren and Huffmann's code can be used
for homogeneous spheres. Put the function `bhmie` into a directory in MATLAB/Octave's
path.

## Run the test-suite

Once install the test-suite for the toolbox can be run using

    pwbTests();

and that for the solver using

    pwbsTests();
    
All the tests should pass. If not please report a bug.

## References

[graphviz]: http://www.graphviz.org
[Octave]: http://www.gnu.org/software/octave
[MATLAB]: http://www.mathworks.co.uk/products/matlab
[Mercurial]: https://www.mercurial-scm.org/
[Mie codes]: https://en.wikipedia.org/wiki/Codes_for_electromagnetic_scattering_by_spheres
[SPlaC]: http://www.victoria.ac.nz/scps/research/research-groups/raman-lab/numerical-tools/sers-and-plasmonics-codes
[scattnlay_v1]: http://cpc.cs.qub.ac.uk/cpc/cgi-bin/showversions.pl/?catid=AEEY&usertype=toolbar&deliverytype=view.
[scattnlay_v2]: https://github.com/ovidiopr/scattnlay
[Matzler]: http://www.iap.unibe.ch/publications/download/2004-02
[scatterlib]: https://code.google.com/archive/p/scatterlib/
