function [ ACS , AE , sigma_eff ] = pwbWallLossFromMCIG( f , area , volume , MCIG )
% pwbWallLossFromMCIG - estimate cavity wall losses from mismatch corrected insertion gain
%
% [ ACS , AE , sigma_eff ] = pwbWallLossFromMCIG( f , area , volume , MCIG )
%
% Estimates the absorption cross-section, absorption efficiency and effective 
% wall conductivity from the mismatch corrected insertion gain of a cavity 
% containing only the two antennas used to determine the insertion gain.
% Asssumes the relative permeability of the walls is unity.
%
% Inputs:
%
% f      - real vector, frequencies [Hz].
% area   - real scalar, area of cavity walls [m^2].
% volume - real scalar, volume of cavity walls [m^3].
% MCIG   - real vector, mismatch corrected insertion gain [-]
%
% Outputs:
%
% ACS       - real vector, average absorption cross-section of walls [m^2].
% AE        - real vector, average absorption efficiency of walls [m^2].
% sigma_eff - real scalar, effective electrical conductivity of walls [S/m].
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
% Date: 04/09/2016

  c0 = 299792458;  
  mu0 = 4 * pi * 1e-7;
      
  f=f(:);
  w = 2 .* pi .* f;
  lambda = c0 ./ f;
  
  % Absorption in transmitting antenna.
  [ ACS_Tx , AE_Tx ] = pwbAntenna( f , 1 , 1 );

  % Absorption in receiving antenna.
  [ ACS_Rx , AE_Rx ] = pwbAntenna( f , 0 , 1 );
  
  % Total ACS including antennas.
  ACS_total = 8.0 .* pi ./ lambda.^2 .* MCIG;
  
  % ACS and AE of walls.
  ACS = ACS_total - ACS_Rx - ACS_Tx;
  AE = 4.0 .* ACS / area; 

  % Make initial estimate at band centre, ignoring first order term.
  guessIdx = floor( length( f ) / 2.0 );
  sigma_eff_0 = 16.0 * area^2 / ( 3.0 * c0 )^2 * pi * f(guessIdx) / ACS(guessIdx)^2 / mu0 * ( 1.0 + 3.0 * c0 * area / 32.0 / volume / f(guessIdx) )^2;

  % Fit metal cavity ACS to get effective conductivity. 
  mu_r = ones( size( f ) );
  wallACS=@(sigma) 4.0 .* area ./ ( 3.0 * c0 ) .* sqrt( pi .* mu_r .* f ./ sigma ./ mu0 ) .* ( 1.0 + 3.0 * c0 * area / 32.0 / volume ./ f );
  fitFcn=@(sigma) sum( abs( wallACS( sigma ) - ACS ).^2 );
  sigma_eff = fminunc( fitFcn , sigma_eff_0 );

end % function
