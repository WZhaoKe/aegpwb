function [ ACS , AE ] = pwbSphere_Matzler( f , radius , eps_r , sigma , mu_r )
%
% pwbSphere_Matzler - Mie absorption cross-sections of a homogeneous lossy sphere
%                     using Christian Matzler's MATLAB code [1,2,3].
%
% [ ACS , AE ] = pwbSphere_Matzler( f , area , radius , eps_r , sigma , mu_r )
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
% References:
%
% [1] C. Mätzler, "MATLAB functions for Mie scattering and absorption", 
%     Res. Rep. 2002-08, Inst. für Angew. Phys., Bern., 2002.
%
% [2] http://omlc.org/software/mie/
%
% [3] C. F. Bohren and D. R. Huffman, Absorption and Scattering of Light by Small
%     Particles (Wiley-VCH Verlag GmbH & Co. KGaA, Weinheim, 2004).
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
  lambda = c0 ./ f;
  
  % Reshape material parameters.
  eps_r = eps_r(:);
  sigma = sigma(:);
  mu_r = mu_r(:);
  eps_r = eps_r .* ones ( size( f ) ); 
  sigma = sigma .* ones ( size( f ) );
  mu_r = mu_r .* ones ( size( f ) ); 

  % Refractive index.
  refIndex = sqrt( ( eps_r + sigma ./ ( j .* 2 .* pi .* f .* eps0 ) ) .* mu_r );

  % Mie code uses convention exp(-j*w*t) => nc = n + j * kappa. 
  refIndex = real( refIndex ) + j * abs( imag( refIndex ) );

  % Check for bhmie in path.
  if( ~exist( 'mie' ) )
    error( 'call to mie failed - is it installed and in the path?' );
  end % if
  
  AE = zeros( size( f ) );
  for freqIdx = 1:numFreq
    x = 2 * pi * radius / lambda(freqIdx);
    result = mie( refIndex(freqIdx) , x );
    AE(freqIdx) = result(3);
  end %for 

  ACS = pi * radius^2 .* AE;

end % function
