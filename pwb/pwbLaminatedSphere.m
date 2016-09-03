function [ ACS , AE ] = pwbLaminatedSphere( f , radii , eps_r , sigma , mu_r )
%
% pwbLaminatedSphere - Mie absorption cross-sections of a multi-layer lossy sphere.
%                      Choose best available Mie code.
%
% [ ACS , AE ] = pwbLaminatedSphere( f , area , radii , eps_r , sigma , mu_r )
%
%              /   /  /        /
%             |   |   |       |
%  cavity     | 1 | 2 | ..... | numLayer      * centre 
%             |   |   |       |
%  eps0 , m0   \   \   \      \ 
%
% Parameters:
%
% f     - vector (numFreq) of required frequencies [Hz].
% area  - real scalar, area of surface [m^2].
% radii - vector (numLayer-1) of layer radii [m].
% eps_r - array (numFreq x numLayer) of relative permittivities [-].
%         If first dimension is 1 assumed same for all frequencies.
% sigma - array (numFreq x numLayer) of electrical conductivities [S/m].
%         If first dimension is 1 assumed same for all frequencies.
% mu_r  - array (numFreq x numLayer) of relative permeabilities [-].
%         If first dimension is 1 assumed same for all frequencies.
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

  persistent MieFcn
  
  if( isempty( MieFcn ) )
    if( exist( 'MulPweSolveMultiSphere' ) )
      MieFcn = @pwbLaminatedSphere_SPlaC;
    else
      % Check for scattnley in path.
      cmd = sprintf( 'scattnlay -l 1 1.0 1.0 1.0' );
      [ status , resultString ] = system( cmd );
      if( status == 0 )
        MieFcn = pwbLaminatedSphere_PenaPal;
      elseif ( exist( 'nMie' ) )
        MieFcn = pwbLaminatedSphere_PenaPalM;
      else
        error( 'could not find multilayer Mie code' );
      end % if
    end % if
  end % if

  [ ACS , AE ] = MieFcn( f , radii , eps_r , sigma , mu_r );

end % function
