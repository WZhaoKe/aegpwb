function [ isPass ] = pwbTestWallLossFromMCIG()
% pwbTestWallLossFromMCIG -
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
% Date: 19/08/2016

  tol = 1e-3;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  f = logspace( log10( 100e6 ) , log10(10e9) , 20 )';
  c0 = 299792458;  
  lambda = c0 ./ f;
  volume = 1.0;
  area = 2.0;
  sigma = 1e6;
  mu_r = 1.0;
  
  [ ACS_wall , AE_wall ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r );
  [ ACS_Tx , AE_Tx ] = pwbAntenna( f , 1 , 1 );
  [ ACS_Rx , AE_Rx ] = pwbAntenna( f , 0 , 1 );
  ACS_total = ACS_wall + ACS_Tx + ACS_Rx;
  MCIG = lambda.^2 ./ 8.0 ./ pi .* ACS_total;
  
  [ ACS , AE , sigma_eff ] = pwbWallLossFromMCIG( f , area , volume , MCIG );
 
  isPass = isPass && isValid( ACS , ACS_wall );
  isPass = isPass && isValid( AE , AE_wall );
  isPass = isPass && isValid( sigma_eff , sigma );
    
end % function
