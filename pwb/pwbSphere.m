function [ ACS , AE ] = pwbSphere( f , radius , eps_r , sigma , mu_r )
%
% pwbSphere - Mie absorption cross-sections of a homogeneous lossy sphere
%             Choose best available Mie code.
%
% [ ACS , AE ] = pwbSphere( f , area , radius , eps_r , sigma , mu_r )
%
% Parameters:
%
% f      - vector (numFreq) of required frequencies [Hz].
% area   - real scalar, area of surface [m^2].
% radius - vector (numLayer-1) of layer radii [m].
% eps_r  - array (numFreq) of relative permittivities [-].
%          If first dimension is 1 assumed same for all frequencies.
% sigma  - array (numFreq) of electrical conductivities [S/m].
%          If first dimension is 1 assumed same for all frequencies.
% mu_r   - array (numFreq) of relative permeabilities [-].
%          If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS - average absorption cross-section [m^2].
% AE  - average absorption efficiency [-].
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft
%
% aeggpwb is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% aeggpwb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with aeggpwb.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: I. D Flintoft
% Date: 19/08/2016
% Version: 1.0.0

  persistent MieFcn = [];
  
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
