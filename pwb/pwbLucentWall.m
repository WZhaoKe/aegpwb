function [ ACS1 , ACS2 , RCS1 , RCS2 , TCS , AE1 , AE2 , RE1 , RE2 , TE ] = ...
                       pwbLucentWall( f , area , thicknesses , eps_r , sigma , mu_r )
%pwbLucntWall - Absorption, reflection and transmission cross-sections of a translucent wall 
% between two cavities.
%
% [ ACS1 , ACS2 , RCS1 , RCS2 , TCS , AE1 , AE2 , RE1 , RE2 , TE ] = ...
%                     pwbLucentWall( f , area , thicknesses , eps_r , sigma , mu_r )
%
%             |   |   |       |          |
%             |   |   |       |          |
%    side 1   | 1 | 2 | ..... | numLayer |  side 2
%             |   |   |       |          |
%  eps0 , mu0 |   |   |       |          | eps0 , mu0
%             |   |   |       |          |
%
% Determines the average absorption and transmission cross-sections and efficiencies of 
% a lossy multilayer wall by averaging the reflectance over angles of arrival and 
% polarisation [1].
%
% Inputs:
%
% f           - real vector (numFreq), frequencies [Hz].
% area        - real scalar, area of one side of wall [m^2].
% thicknesses - real vector (numLayer), layer thicknesses [m].
% eps_r       - complex array (numFreq x numLayer) complex relative permittivities of layers [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigma       - real array (numFreq x numLayer), electrical conductivities of layers [S/m].
%               If first dimension is 1 assumed same for all frequencies.
% mu_r        - real array (numFreq x numLayer), relative permeabilities of layers [-].
%               If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS1 - real vector (numFreq x 1), average absorption cross-section of side 1 [m^2].
%        This is the absorption within the laminated wall for a source on side 1 and does not
%        include the power transmitted through the wall, which is also lost from side 1.
% ACS2 - real vector (numFreq x 1), average absorption cross-section of side 2 [m^2].
%        This is the absorption within the laminated wall for a source on side 2 and does not
%        include the power transmitted through the wall, which is also lost from side 2.
% RCS1 - real vector (numFreq x 1), average reflection cross-section of side 1 [m^2].
% RCS2 - real vector (numFreq x 1), average reflection cross-section of side 2 [m^2].
% TCS  - real vector (numFreq x 1), average transmission cross-section [m^2].
% AE1  - real vector (numFreq x 1), average effective absorption efficiency of side 1 [-].
% AE2  - real vector (numFreq x 1), average effective absorption efficiency of side 2 [-].
% RE1  - real vector (numFreq x 1), average reflection efficiency of side 1 [-].
% RE2  - real vector (numFreq x 1), average reflection efficiency of side 2 [-].
% TE   - real vector (numFreq x 1), average transmission efficiency [-].
%
% References:
%
% [1] S. J. Orfanidis, "Electromagnetic waves and antennas", Rutgers University,
%     New Brunswick, NJ , 2016. URL: http://www.ece.rutgers.edu/~orfanidi/ewa
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
% Date: 01/09/2016
  
  % Get number of frequencies and layers.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses );
  
  % Check and expand material arrays.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer , 'epsc_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );
 
  % Integrate over angles of incidence.
  thetas = linspace( 0 , pi / 2 - 1e-4 , 801 );
  dtheta = thetas(2) - thetas(1);
  RE1 = zeros( size( f ) );
  RE2 = zeros( size( f ) );
  TE = zeros( size( f ) );
     
  for idx = 1:length( thetas )
    theta = thetas(idx);
    [ S ] = emMultiRefAniso( f , 180.0 * theta / pi  , thicknesses , [ 0.0 ] , 1.0 , 1.0 , eps_r , sigma , mu_r , 'S' );
    rhoTM1 = squeeze( S(1,1,:) ); 
    rhoTE1 = squeeze( S(3,3,:) );
    rhoTM2 = squeeze( S(2,2,:) ); 
    rhoTE2 = squeeze( S(4,4,:) );
    tauTM  = squeeze( S(2,1,:) ); 
    tauTE  = squeeze( S(4,3,:) );
    costhetasintheta = cos( theta ) .* sin( theta );
    RE1 = RE1 + 2.0 .* ( 0.5 .* ( abs( rhoTE1 ).^2 + abs( rhoTM1 ).^2 ) ) .* costhetasintheta;
    RE2 = RE2 + 2.0 .* ( 0.5 .* ( abs( rhoTE2 ).^2 + abs( rhoTM2 ).^2 ) ) .* costhetasintheta;
    TE  = TE  + 2.0 .* ( 0.5 .* ( abs( tauTE ).^2  + abs( tauTM ).^2 )  )  .* costhetasintheta;
  end % for
  
  RE1 = RE1 .* dtheta;
  RE2 = RE2 .* dtheta;
  TE = TE .* dtheta;
  
  % Absorption efficiencies.
  AE1 = 1.0 - RE1 - TE;
  AE2 = 1.0 - RE2 - TE;
  
  % Cross-sections.
  G = 0.25 * area;
  ACS1 = G .* AE1;
  ACS2 = G .* AE2;
  RCS1 = G .* RE1;
  RCS2 = G .* RE2;
  TCS = G .* TE;
 
end %function
