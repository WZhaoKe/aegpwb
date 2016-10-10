function [ ACS , AE ] = pwbLaminatedSphere_SPlaC( f , radii , eps_r , sigma , mu_r )
% pwbLaminatedSphereSPlaC - Absorption cross-section of a lossy multi-layer sphere.
%
% [ ACS , AE ] = pwbLaminatedSphere_SPlaC( f , radii , eps_r , sigma , mu_r )
%
%     cavity     /   /  /        /
%               |   |   |       |
%               | 1 | 2 | ..l.. | numLayer      * centre 
%               |   |   |       |               |
%    eps0 , m0   \   \   \      \               |
%                            <----radii(l)------|
%
% Uses the SERS and Plasmonics Codes (SPlaC) package [1,2] to determine the absorption 
% cross-section and efficiency of a lossy multilayer sphere.
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
% References:
%
% [1] SERS and Plasmonics Codes, SPlaC, 
%     http://www.victoria.ac.nz/scps/research/research-groups/raman-lab/numerical-tools/sers-and-plasmonics-codes
% [2] E. C. Le Ru and P. G. Etchegoin, Principles of Surface-Enhanced Raman 
%     Spectroscopy and Related Plasmonic Effects, Elsevier, Amsterdam, 2009.
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

  % EM constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  % Get number of frequencies and layers.
  f = f(:);
  numFreq = length( f );
  numLayer = length( radii );
  lambda = c0 ./ f;
  
  % Check and expand material arrays.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer , 'epsc_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );

  % Background medium - must be lossless.
  eps_ra = 1.0;
  mu_ra = 1.0;
  n_a = sqrt( eps_ra * mu_ra );

  % Refractive indices.
  fm = repmat( f , [ 1 , numLayer ] );
  epsc_r = eps_r + sigma ./ ( j .* 2 .* pi .* fm .* eps0 );
  refIndex = sqrt( epsc_r .* mu_r ) ./ n_a;

  % Mie code uses convention exp(-j*w*t) => nc = n + j * kappa (kappa>0). 
  refIndex = real( refIndex ) + j * abs( imag( refIndex ) );
  epsc_r = real( epsc_r ) + j * abs( imag( epsc_r ) );
  
  % Check for SPlaC.
  if( ~exist( 'MulPweSolveMultiSphere' ) )
    error( 'call to MulPweSolveMultiSphere failed - is SPlaC installed and in the path?' );
  end % if
  
  AE = zeros( size( f ) );
  for freqIdx = 1:numFreq
    cradius ={};
    Cepsilon = {};
    x = [];
    for layerIdx=1:numLayer
      cradius{numLayer-layerIdx+1} = radii(layerIdx) / 1e-9;
      Cepsilon{numLayer-layerIdx+1} = epsc_r(freqIdx,layerIdx) .* ones( 1 , 1 );
      x(numLayer-layerIdx+1) = 2.0 * pi .* radii(layerIdx) ./ lambda(freqIdx);  
    end % if
    Cepsilon{numLayer+1} = 1.0 .* ones( 1 , 1 );     
    nc = ceil( max( x ) + 4.05 *( max( x )^(1/3) ) + 2 );
    stMieRes = MulPweSolveMultiSphere( nc , cradius , lambda(freqIdx) / 1e-9 , Cepsilon );
    AE(freqIdx) = stMieRes.Qabs;
  end %for

  ACS = pi * radii(1)^2 .* AE;

end % function
