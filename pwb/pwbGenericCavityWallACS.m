function [ ACS , AE ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r )
% pwbGenericCavityWallACS - determine ACS and AE of walls of generic cavity
%
% [ ACS , AE ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r )
%
% Uses perturbative calculation of wall loss in a cuboid cavity [1].
%
% Inputs:
%
% f      - real vector, frequencies [Hz].
% area   - real scalar, area of cavity walls [m^2].
% volume - real scalar, volume of cavity walls [m^3].
% sigma  - real vector, electrical conductivity of cavity wall material [S/m].
% mu_ r  - real vector, relative permeability of cavity wall material [-].
%
% Outputs:
%
% ACS - real vector, average absorption cross-section of walls [m^2].
% AE  - real vector, average absorption efficiency of walls [m^2].
%
% References:
%
% [1] B. H. Liu, D. C. Chang, and M. T. Ma [1983], “Eigenmodes and the Composite Quality 
%     Factor of a Reverberation Chamber,” NBS Technical Note 1066, National Institute 
%     of Standards and Technology, Boulder, Colorado 80303-3328, USA.
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft
%
% aegpwb is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% aegpwb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with aegpwb.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: I. D Flintoft
% Date: 03/09/2016

  c0 = 299792458;             
  mu0 = 4 * pi * 1e-7;
  
  if( isinf( sigma ) )
    ACS = zeros( size( f ) );
    AE = zeros( size( f ) );
  else
    ACS = 4.0 * area ./ ( 3.0 * c0 ) .* sqrt( pi .* mu_r .* f ./ sigma ./ mu0 ) .* ( 1.0 + 3.0 * c0 * area / 32.0 / volume ./ f ) ;
    AE = 4.0 .* ACS ./ area;
  end % if

end % function
