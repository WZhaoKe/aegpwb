function [ ACS , AE ] = pwbSphere_Markowicz( f , radius , eps_r , sigma , mu_r )
% pwbSphere_Markowicz - Mie absorption cross-section of a homogeneous lossy sphere
%
% [ ACS , AE ] = pwbSphere_Markowicz( f , area , radius , eps_r , sigma , mu_r )
%
% Uses Markowicz's MATLAB implementation of Bohren & Huffman's code in scatterlib [1].
%
% Parameters:
%
% f      - real vector(numFreq), frequencies [Hz].
% area   - real scalar, area of surface [m^2].
% radius - real scalar, radius of sphere [m].
% eps_r  - complex array(numFreq) of relative (complex) permittivities [-].
%          If a scalar assumed same for all frequencies.
% sigma  - real array(numFreq) of electrical conductivities [S/m].
%          If a scalar assumed same for all frequencies.
% mu_r   - real array(numFreq) of relative permeabilities [-].
%          If a scalar assumed same for all frequencies.
%         
% Outputs:
%
% ACS - average absorption cross-section [m^2].
% AE  - average absorption efficiency [-].
%
% References:
%
% [1] Krzszystof Markowicz, in "scatterlib" (August 16, 2016),
%     http://code.google.com/p/scatterlib/wiki/Spheres.
%
% [2] C. F. Bohren and D. R. Huffman, Absorption and Scattering of Light by Small
%     Particles (Wiley-VCH Verlag GmbH & Co. KGaA, Weinheim, 2004).
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
  if( ~exist( 'bhmie' ) )
    error( 'call to bhmie failed - is it installed and in the path?' );
  end % if
  
  AE = zeros( size( f ) );
  for freqIdx = 1:numFreq
     x = 2 * pi * radius / lambda(freqIdx);
     [ ~ , ~ , Qext , Qsca , ~ , ~ ] = bhmie( x , refIndex(freqIdx) , 1 );
     AE(freqIdx) = Qext - Qsca;
  end %for 

  ACS = pi * radius^2 .* AE;
 
end % function
