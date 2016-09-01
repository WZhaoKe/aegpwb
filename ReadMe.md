![](https://bitbucket.org/uoyaeg/aegpwb/wiki/aegpwb.jpg )

# AEGPWB: An open source electromagnetic power balance toolbox and solver

The Applied Electromagnetics Group ([AEG][]) power balance (PWB) toolbox and 
solver for [MATLAB][] and [GNU][] [Octave][] is an [Open Source][] set of tools for 
undertaking PWB analysis of electrically large enclosured spaces. It was 
developed in the [Department of Electronics][] at the [University of York][] for 
research in electromagnetic compatibility ([EMC][]).

## The power balance method

The origins of the Power Balance (PWB) approach are in the work of Hill et al in 
a paper that showed how to divide the power loss in a cavity into four component 
parts ([Hill1994][]): 

1. Power lost through apertures; 
2. Power absorbed by receiving antennas in the cavity; 
3. Power absorbed in lossy objects;
4. Power absorbed in the cavity walls.

Further theoretical work was carried out at [NIST][] and the method was 
developed into a systematic simulation technique overlaid on the Electromagnetic 
Topology (EMT) methodology by Parmantier and Junqua at [ONERA][] ([Junqua2005][], 
[Parmantier2007][]). A very similar approach has recently being reported by 
([Tait2011][]). PWB treats the problem space as a topological model of shielded 
cavities, coupled with wires, apertures, antennas etc. Each of these is assigned 
a model for its coupling cross section, and the power transferred and the 
resulting power density in each cavity is calculated over a broadband from a set 
of linear equations dervied from the overall power balance in each cavity. 

The set of linear equations can also be represented as a equivalent cicruit in 
which cavities are nodes of the cicuit and power absorption and transmission 
processes are admittances on the edges connecting the nodes. The power densities 
in the cavities are the across variables ("voltages") and the powers absorbed or 
coupled through the admittances are the through variables ("currents"). For a 
power absorption process, the average power absorbed is the product of the 
average power density in the cavity and the average absorption cross-section 
(ACS). For a process that transfers energy between two cavities the net power 
transmitted from one side to the other is the product of the difference in the 
average power densities in the two cavities and the average transmission 
cross-section (TCS) of the process.

The power balance relationship for the equilibrium state of each cavity in the 
system requires the total power transmitted into the cavity to be equal to the 
total power absorption within the cavity; this leads to a linear equation 
relating the power densities with the ACSs and TCSs as coefficients, analagous 
to Kirchhoff's Current Law. The ACSs and TCSs can be referred to collectively as 
coupling cross-section (CCSs). If a system contains `N` cavities then `N` such 
linear equations can be formed from the power balance in each cavity and then 
solved for the power densities of the cavities. 

The AEG PWB toolbox provides functions for the determination of average CCSs and 
associated utilities and the solver implements the equivalent circuit approach 
to constructing the EMT and solving the problem. 

## Code features

The toolbox and solver include:

* Models for the absorption in cavity walls;

* Detemination of polarisabilities and average transmission cross-sections of apertures;

* Models for absorption in metal, dielectric and arbitrary laminated surfaces;

* Models for absorption in homogeneous and layered spheres;

* Models for transmission and absorption in semi-transparent walls;

* Support for user supplied CCS, for example, from experiments;

* Probabilities distributions for electromagnetic quantitities in cavities and 
  received electrical parameters in antenna and transmission lines;

## Requirements

The code is written in a portable subset of GNU [Octave][] and [MATLAB][]. 
Additional requirements are:

1. (Optional) To view the EMT of a model the [graphviz][] package must be
   installed on the system.

2. (Optional) A Mie series code needs to be installed in order for the absorption
   in spherical bodies to be calculated. See [Install.md][] for the supported codes.

3. (Optional) To help with development or as an alternative way to download the 
   source a client for the [Mercurial][] Version Control System is required.

The code has been primarily developed using GNU [Octave][] on Linux platforms, 
but should run under both GNU [Octave][] and [MATLAB][] on Linux and Windows 
systems.

## Documentation

Installation instructions are contained in the file [Install.md][] in the source 
distribution.

The best place to start after installing the software is with the detailed 
[tutorial][] example for the PWB solver in the tutorial directory of the 
software package.

There are also user manuals for the toolbox in doc/[ToolboxUserManual.md][] and 
the solver in doc/[SolverUserManual.md][].

## Bugs and support

The code is still under development and no doubt will contain many bugs. Known 
significant bugs are listed in the file doc/[Bugs.md][]  in the source code. 

Please report bugs using the bitbucket issue tracker at 
<https://bitbucket.org/uoyaeg/aegpwb/issues> or by email to 
<ian.flintoft@york.ac.uk>.

For general guidance on how to write a good bug report see, for example:

* <http://www.chiark.greenend.org.uk/~sgtatham/bugs.html>
* <http://noverse.com/blog/2012/06/how-to-write-a-good-bug-report>
* <http://www.softwaretestinghelp.com/how-to-write-good-bug-report>

Some of the tips in <http://www.catb.org/esr/faqs/smart-questions.html> are also 
relevant to reporting bugs.

There is a Wiki on the bitbucket [project page](https://bitbucket.org/uoyaeg/aegpwb/wiki/). 

## How to contribute

We welcome any contributions to the development of the mesher, including:

* Fixing bugs.

* Interesting examples that can be used for test-cases.

* Improving the user documentation.

* Items in the to-do list in the file doc/[ToDo.md][].

Please contact [Dr Ian Flintoft], <ian.flintoft@york.ac.uk>, if you are 
interested in helping with these or any other aspect of development.

## Licence

The code is licensed under the GNU Public Licence, version 3 [GPL3][]. For 
details see the file [Licence.txt][].

## Developers

[Dr Ian Flintoft][], <ian.flintoft@york.ac.uk>

## Contacts

[Dr Ian Flintoft][], <ian.flintoft@york.ac.uk>

[Dr John Dawson][], <john.dawson@york.ac.uk>

## Credits

**[TBC]**

## Related links

**[TBC]**

## References

[Hill1994]: http://ieeexplore.ieee.org/xpl/articleDetails.jsp?tp=&arnumber=305461

([Hill1994]) D. A. Hill, M. T. Ma, A. R. Ondrejka, B. F. Riddle, M. L. Crawford and R. T. Johnk, 
           "Aperture excitation of electrically large, lossy cavities,"
           IEEE Transactions on Electromagnetic Compatibility, vol. 36, no. 3, pp. 169-178, Aug 1994.

[Hill1998]: http://ieeexplore.ieee.org/xpl/articleDetails.jsp?tp=&arnumber=709418

([Hill1998]) D. A. Hill, 
           "Plane wave integral representation for fields in reverberation chambers,"
           IEEE Transactions on Electromagnetic Compatibility, vol. 40, no. 3, pp. 209-217, Aug 1998.

[Junqua2005]: http://www.tandfonline.com/doi/abs/10.1080/02726340500214845

([Junqua2005]) I. Junqua, J.-P. Parmantier and F. Issac,
             "A Network Formulation of the Power Balance Method for High-Frequency Coupling",
             Electromagnetics Vol. 25 , Iss. 7-8,2005 

[Parmantier2007]: http://link.springer.com/chapter/10.1007/978-0-387-37731-5_1

([Parmantier2007]) J.-P. Parmantier and I. Junqua,
                 "EM Topology: From Theory to Application",
                 in Ultra-Wideband, Short-Pulse Electromagnetics 7, Springer New York, pp. 3-12, 2007
    
[Tait2011]: http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=5491150

([Tait2011]) G. B. Tait, R. E. Richardson, M. B. Slocum, M. O. Hatfield and M. J. Rodriguez, 
           "Reverberant Microwave Propagation in Coupled Complex Cavities",
           IEEE Transactions on Electromagnetic Compatibility, vol. 53, no. 1, pp. 229-232, Feb. 2011.


[Dr Ian Flintoft]: http://www.elec.york.ac.uk/staff/idf1.html
[Dr John Dawson]: http://www.elec.york.ac.uk/staff/jfd1.html
[University of York]: http://www.york.ac.uk
[Department of Electronics]: http://www.elec.york.ac.uk
[AEG]: http://www.elec.york.ac.uk/research/physLayer/appliedEM.html
[Open Source]: http://opensource.org
[GPL3]: http://www.gnu.org/copyleft/gpl.html
[NIST]: http://www.nist.gov
[ONERA]: http://www.onera.fr/en
[GNU]: https://www.gnu.org/home.en.html
[EMC]: http://www.york.ac.uk/electronics/research/physlayer/appliedem/emc/

[Install.md]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/Install.md
[tutorial]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/tutorial/Tutorial.md
[ToolboxUserManual.md]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/doc/ToolboxUserManual.md
[SolverUserManual.md]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/doc/SolverUserManual.md
[Bugs.md]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/doc/Bugs.md
[ToDo.md]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/doc/ToDo.md
[Licence.txt]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/Licence.txt

[graphviz]: http://www.graphviz.org
[Octave]: http://www.gnu.org/software/octave
[MATLAB]: http://www.mathworks.co.uk/products/matlab
[Mercurial]: https://www.mercurial-scm.org
