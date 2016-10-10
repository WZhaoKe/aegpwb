function [ ACS , AE ] = pwbSphere( f , radius , eps_r , sigma , mu_r )
% pwbSphere - Absorption cross-section of a lossy homogneous sphere.
%
% [ ACS , AE ] = Sphere( f , radii , eps_r , sigma , mu_r )
%
% Chooses the best available Mie code to determine the absorption cross-section 
% and efficiency of a lossy homogeneous sphere.
%
% Inputs:
%
% f      - real vector (numFreq), frequencies [Hz].
% radius - real scalar, radius of sphere [m].
% eps_r  - complex array (numFreq), complex relative permittivities [-].
%          If first dimension is 1 assumed same for all frequencies.
% sigma  - real array (numFreq), electrical conductivities [S/m].
%          If first dimension is 1 assumed same for all frequencies.
% mu_r   - real array (numFreq), relative permeabilities of [-].
%          If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS - real vector (numFreq x 1), average absorption cross-section [m^2].
% AE  - real vector (numFreq x 1), average absorption efficiency [-].
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft <ian.flintoft@googlemail.com>
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
% Author: Ian Flintoft <ian.flintoft@googlemail.com>
% Date: 03/09/2016

  % Cache function handle of first alternative found.
  persistent MieFcn
  
  if( isempty( MieFcn ) )
    if( exist( 'mie' ) )
      MieFcn = @pwbSphere_Matzler;
    elseif( exist( 'bhmie' ) )
      MieFcn = @pwbSphere_Markowicz;
    else
      error( 'could not find multilayer Mie code' );
    end % if
  end % if

  [ ACS , AE ] = MieFcn( f , radius , eps_r , sigma , mu_r );

end % function
