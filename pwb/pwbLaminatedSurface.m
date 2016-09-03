function [ ACS , AE ] = pwbLaminatedSurface( f , area , thicknesses , eps_r , sigma , mu_r , sigmam )
% pwbLaminatedSurface - Absorption cross-section of a laminated surface.
%
% [ ACS , AE ] = pwbLaminatedSurface( f , area , thicknesses , eps_r , sigma , mu_r , sigmam )
%
%             |   |   |       |
%             |   |   |       |
%  cavity     | 1 | 2 | ..... | numLayer -> oo
%             |   |   |       | 
%  eps0 , m0  |   |   |       |
%             |   |   |       |
%
% Determines the absorption cross-section and efficiency of a lossy multilayer surface
% by averaging the reflectance over angles of arrival and polarisation [1].
%
% Inputs:
%
% f           - real vector (numFreq), frequencies [Hz].
% area        - real scalar, area of surface [m^2].
% thicknesses - real vector (numLayer-1), layer thicknesses [m].
% eps_r       - complex array (numFreq x numLayer) complex relative permittivities of layers [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigma       - real array (numFreq x numLayer), electrical conductivities of layers [S/m].
%               If first dimension is 1 assumed same for all frequencies.
% mu_r        - real array (numFreq x numLayer), relative permeabilities of layers [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigmam      - real array (numFreq x numLayer), magnetic conductivities of layers [ohm/m].
%               If first dimension is 1 assumed same for all frequencies.
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

  function [ kernel ] = pwbLaminatedSurfaceKernel( f , theta , thicknesses ,  eps_r , sigma , mu_r , sigmam ) 

    for idx=1:length( theta )
      [ rhoTE(idx) , rhoTM(idx) , ~ , ~ ] = emMultiRefG( f , 180 * theta(idx) / pi , thicknesses , eps_r , sigma , mu_r , sigmam );
    end % for
    
    kernel = ( 1 - 0.5 .* ( abs( rhoTE ).^2 + abs( rhoTM ).^2 ) ) .* cos( theta ) .* sin( theta ); 
    
  end %function
 
  % Get number of frequencies and layers.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses ) + 1;
  
  % Check and expand material arrays.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer , 'epsc_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );
  [ sigmam ] = expandMaterialArray( sigmam , numFreq , numLayer , 'sigmam' ); 

  % Iterate over frequencies integrating over angles of incidence.
  ACS = zeros( size( f ) );
  AE = zeros( size( f ) );
  for freqIdx=1:length( f )  
    AE(freqIdx) = 2.0 * quad( ...
      @(theta) pwbLaminatedSurfaceKernel( f(freqIdx) , theta ,  thicknesses , [1.0,eps_r(freqIdx,:)] , [0.0,sigma(freqIdx,:)] , [1.0,mu_r(freqIdx,:)] , [0.0,sigmam(freqIdx,:)] ) , ...
      0.0 , pi / 2.0 - 1e-4 );
    ACS(freqIdx) = 0.25 * AE(freqIdx) * area;
  end %for

end %function
