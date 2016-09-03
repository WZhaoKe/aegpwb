function [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )
% pwbMetalSurface - Absorption cross-section of a highly conducting surface.
%
% [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )
%
% Determines the absorption cross-section and efficiency of a highly conducting 
% ( sigma >> w * epsilon ) surface by averaging the reflectance over angles of 
% arrival and polarisation [1].
%
% Inputs:
%
% f     - real vector (numFreq), frequencies [Hz].
% area  - real scalar, area of surface [m^2].
% sigma - real array (numFreq), electrical conductivity [S/m].
%         If first dimension is 1 assumed same for all frequencies.
% mu_r  - real array (numFreq), relative permeability [-].
%         If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS - real vector (numFreq x 1), average absorption cross-section [m^2].
% AE  - real vector (numFreq x 1), average absorption efficiency [-].
%
% References:
%
% [1] S. J. Orfanidis, "Electromagnetic waves and antennas", Rutgers University,
%     New Brunswick, NJ , 2016. URL: http://www.ece.rutgers.edu/~orfanidi/ewa
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
% along with aegpwb.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: I. D Flintoft
% Date: 01/09/2016
%
% pwbMetalSurface - absorption cross-section of metal surface.
%
% [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )
%
% Parameters:
%
% f         - real vector of frequencies [Hz].
% area      - real scalar, total area of surface [m^2]
% sigma     - real vector, conductivity of surface [S/m]
% mu_r      - real vector, relative permeability of surface [-]
%
% sigma and mu_r must be scalars or the same length as f.
%
% Outputs:
%
% ACS       - real vector, absorption cross-section [m^2].
% AE        - real vector, absorption efficiency [-].
%

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             

  validateattributes( f , { 'double' } , { 'real' , 'vector' , 'positive' , 'increasing' } , 'pwbMetalSurface' , 'f' , 1 );
  validateattributes( area , { 'double' } , { 'real' , 'scalar' , 'positive' } , 'pwbMetalSurface' , 'area' , 2 ); 
  validateattributes( sigma , { 'double' } , { 'real' , 'vector' , 'nonnegative' } , 'pwbMetalSurface' , 'sigma' , 3 );
  validateattributes( mu_r , { 'double' } , { 'real' , 'vector' , '>=' , 1.0 } , 'pwbMetalSurface' , 'mu_r' , 4 );
  
  if( length( sigma ) ~= 1 && length( sigma ) ~= length( f ) )
    error( 'sigma must be a scalar or the same size as f' );
  end % if
  if( length( mu_r ) ~= 1 && length( mu_r ) ~= length( f ) )
    error( 'mu_r must be a scalar or the same size as f' );
  end % if

  ACS = 4.0 * area / ( 3.0 * c0 ) .* sqrt( pi .* mu_r .* f ./ sigma ./ mu0 );
  AE = 4.0 .* ACS ./ area;

end %function
