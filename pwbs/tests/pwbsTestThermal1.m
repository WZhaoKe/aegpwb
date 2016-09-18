function [ isPass ] = pwbsTestThermal1()
% pwbsTestThermal1 - 
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

  tol = 10000 * eps;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  k = 1.38064852e-23;
  c0 = 299792458;
 
  a = 1.0;
  b = 2.0;
  c = 3.0;
  sigma = 1e6;
  mu_r = 1.0;
  temperature = 300;
  bandwidth = 10e3;
  
  f = logspace( log10( 10e6 ) , log10( 100e9 ), 100 )';
  pwbm = pwbsInitModel( f , 'TestThermal1' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Cuboid'  , { a , b , c , sigma , mu_r } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Thermal' , 'C' , { temperature , bandwidth } );
  pwbm = pwbsSolveModel( pwbm );

  volume = a * b * c;
  area = 2 * ( a * b + b * c + c * a );
  [ ACS_val , AE_val ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r );
  sourcePower_val = area .* bandwidth .* AE_val .* 2.0 .* pi .* f.^2 ./ c0.^2 .* k .* temperature;
  powerDensity_val = sourcePower_val ./ ACS_val;
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' , 'totalSourcePower' } );
  isPass = isPass && isValid( data{1} , powerDensity_val );
  isPass = isPass && isValid( data{2} , sourcePower_val );

end % function
