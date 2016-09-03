function [ ACS , AE ] = pwbDielectricSurface( f , area , epsc_r , sigma , mu_r )
% pwbDielectricSurface - Absorption cross-section of a lossy dielectric surface.
%
% [ ACS , AE ] = pwbDielectricSurface( f , area , epsc_r , sigma , mu_r )
%
% Determines the absorption cross-section and efficiency of a lossy dielectric surface
% by averaging the reflectance over angles of arrival and polarisation [1].
%
% Inputs:
%
% f     - real vector (numFreq), frequencies [Hz].
% area  - real scalar, area of surface [m^2].
% eps_r - complex array (numFreq) complex relative permittivity [-].
%         If first dimension is 1 assumed same for all frequencies.
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
% Date: 01/09/2016

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  function [ kernel ] = pwbDielectricSurfaceKernel( theta , n_a , n_b )

    [ rhoTE , rhoTM , tauTE , tauTM ] = emFresnelCoeff( n_a , n_b , theta );
    kernel = ( 1 - 0.5 .* ( abs( rhoTE ).^2 + abs( rhoTM ).^2 ) ) .* cos( theta ) .* sin( theta );

  end %function

  validateattributes( f , { 'double' } , { 'real' , 'vector' , 'positive' , 'increasing' } , 'pwbDielectricSurface' , 'f' , 1 );
  validateattributes( area , { 'double' } , { 'real' , 'scalar' , 'positive' } , 'pwbDielectricSurface' , 'area' , 2 ); 
  validateattributes( epsc_r , { 'double' } , { } , 'pwbDielectricSurface' , 'epsc_r' , 3 );
  validateattributes( sigma , { 'double' } , { 'real' , 'vector' , 'nonnegative' } , 'pwbDielectricSurface' , 'sigma' , 4 );
  validateattributes( mu_r , { 'double' } , { 'real' , 'vector' , '>=' , 1.0 } , 'pwbDielectricSurface' , 'mu_r' , 5 );
  
  if( length( epsc_r ) ~= 1 && length( epsc_r ) ~= length( f ) )
    error( 'epsc_r must be a scalar or the same size as f' );
  end % if
  if( length( sigma ) ~= 1 && length( sigma ) ~= length( f ) )
    error( 'sigma must be a scalar or the same size as f' );
  end % if
  if( length( mu_r ) ~= 1 && length( mu_r ) ~= length( f ) )
    error( 'mu_r must be a scalar or the same size as f' );
  end % if

  % Complex relative permittivity.
  epsc_r = epsc_r + sigma ./ ( j .* 2 .* pi .* f .* eps0 );

  % Refractive indicies of left and right media.
  n_a = 1.0;
  n_b = sqrt( epsc_r .* mu_r );

  ACS = zeros( size( f ) );
  for freqIdx=1:length( f )
    ACS(freqIdx) = 0.5 * area * quad( @(theta) pwbDielectricSurfaceKernel( theta , n_a , n_b(freqIdx) ) , 0.0 , pi / 2 );
  end %for
  AE = 4.0 .* ACS ./ area;

end %function
