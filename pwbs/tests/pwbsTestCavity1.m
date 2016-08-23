function [ isPass ] = pwbsTestCavity1()
%
% pwbsTestCavity1 - 
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

  tol = 100 * eps;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  a = 1.0;
  b = 2.0;
  c = 3.0;
  sigma = 1e6;
  mu_r = 1.0;
  
  f = logspace( log10( 10e6 ) , log10( 100e9 ), 100 )';
  pwbm = pwbsInitModel( f , 'TestCavity1' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Cuboid'  , { a , b , c , sigma , mu_r } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C' , { 1 } );
  pwbm = pwbsSetupModel( pwbm );
  pwbm = pwbsSolveModel( pwbm );

  volume = a * b * c;
  area = 2 * ( a * b + b * c + c * a );
  [ ACS_val , ~ ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r );
  
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'wallACS' , 'powerDensity' } );
  isPass = isPass && isValid( data{1} , ACS_val );
  isPass = isPass && isValid( data{2} , 1.0 ./ ACS_val );

end % function
