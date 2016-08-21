![](https://bitbucket.org/uoyaeg/aegpwb/wiki/aegpwb.jpg )

# AEGPWB: An open source electromagnetic power balance toolbox and solver
The Applied Electromagnetics Group ([AEG][]) power balance (PWB) toolbox and 
solver for [MATLAB][] and [GNU Octave][] is an [Open Source][] set of tools for 
undertaking PWB analysis of electrically large enclosured spaces. It was 
developed in the [Department of Electronics][] at the [University of York][] for 
research in electromagnetic compatibility ([EMC][]).

## The power balance method

**[TBC]**

## Code features

**[TBC]**

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

## Credits

[TBC]

## Related links

[TBC]


[Dr Ian Flintoft]: http://www.elec.york.ac.uk/staff/idf1.html
[University of York]: http://www.york.ac.uk
[Department of Electronics]: http://www.elec.york.ac.uk
[AEG]: http://www.elec.york.ac.uk/research/physLayer/appliedEM.html
[Open Source]: http://opensource.org
[GPL3]: http://www.gnu.org/copyleft/gpl.html

[Install.md]: Install.md
[tutorial]: Tutorial.md
[ToolboxUserManual.md]: ToolboxUserManual.md
[SolverUserManual.md]: SolverUserManual.md
[Bugs.md]: Bugs.md
[ToDo.md]: ToDo.md
[Licence.txt]: https://bitbucket.org/uoyaeg/aegpwb/src/tip/Licence.txt

[graphviz]: http://www.graphviz.org
[Octave]: http://www.gnu.org/software/octave
[MATLAB]: http://www.mathworks.co.uk/products/matlab
[Mercurial]: http://mercurial.selenic.com
