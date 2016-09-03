function [ ACS , AE ] = pwbLaminatedSphere( f , radii , eps_r , sigma , mu_r )
% pwbLaminatedSphere - Absorption cross-section of a lossy multi-layer sphere.
%
% [ ACS , AE ] = pwbLaminatedSphere( f , radii , eps_r , sigma , mu_r )
%
%     cavity     /   /  /        /
%               |   |   |       |
%               | 1 | 2 | ..l.. | numLayer      * centre 
%               |   |   |       |               |
%    eps0 , m0   \   \   \      \               |
%                            <----radii(l)------|
%
% Chooses the best available Mie code to determine the absorption cross-section 
% and efficiency of a lossy multilayer sphere.
%
% Inputs:
%
% f     - real vector (numFreq), frequencies [Hz].
% radii - real vector (numLayer), radii of layers, outer first [m].
% eps_r - complex array (numFreq x numLayer), complex relative permittivities of layers [-].
%         If first dimension is 1 assumed same for all frequencies.
% sigma - real array (numFreq x numLayer), electrical conductivities of layers [S/m].
%         If first dimension is 1 assumed same for all frequencies.
% mu_r  - real array (numFreq x numLayer), relative permeabilities of layers [-].
%         If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS - real vector (numFreq x 1), average absorption cross-section [m^2].
% AE  - real vector (numFreq x 1), average absorption efficiency [-].
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

  % Cache function handle of first alternative found.
  persistent MieFcn
  
  if( isempty( MieFcn ) )
    if( exist( 'MulPweSolveMultiSphere' ) )
      % SPlaC.
      MieFcn = @pwbLaminatedSphere_SPlaC;
    else
      cmd = sprintf( 'scattnlay -l 1 1.0 1.0 1.0' );
      [ status , resultString ] = system( cmd );
      if( status == 0 )
        % Pena & Pal scattnlay C program.
        MieFcn = pwbLaminatedSphere_PenaPal;
      elseif ( exist( 'nMie' ) )
        % Pena & Pal scattnlay MATLAB function.
        MieFcn = pwbLaminatedSphere_PenaPalM;
      else
        error( 'could not find a multilayer Mie code' );
      end % if
    end % if
  end % if

  [ ACS , AE ] = MieFcn( f , radii , eps_r , sigma , mu_r );

end % function
