function [ ACS , AE ] = pwbLaminatedSphere_SPlaC( f , radii , eps_r , sigma , mu_r )
%
% pwbLaminatedSphere_SPlaC - Mie absorption cross-section of a multi-layer lossy sphere
%                            using the SERS and Plasmonics Codes (SPlaC)  package [1].
%
% [ ACS , AE ] = pwbLaminatedSphere_SPlaC( f , area , radii , eps_r , sigma , mu_r )
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
% References:
%
% [1] SERS and Plasmonics Codes, SPlaC, 
%     http://www.victoria.ac.nz/scps/research/research-groups/raman-lab/numerical-tools/sers-and-plasmonics-codes
% [2] E. C. Le Ru and P. G. Etchegoin, Principles of Surface-Enhanced Raman Spectroscopy and Related 
%     Plasmonic Effects, Elsevier, Amsterdam, 2009.
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

  % EM Constants.
  [ c0 , eps0 , mu0 , eta0 ] = emConst();

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
