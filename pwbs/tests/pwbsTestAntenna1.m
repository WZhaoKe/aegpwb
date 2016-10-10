function [ isPass ] = pwbsTestAntenna1()
% pwbsTestAntenna1 - 
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

  tol = 100 * eps;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  c0 = 299792458;
  f = [ 1e9 ];
  lambda = c0 ./ f;
  
  pwbm = pwbsInitModel( f , 'TestAntennas1' );
  pwbm = pwbsInitModel( f , 'TestAntenna1' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'C' , 1 , 'Matched' , { 50.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Antenna' , 'Tx' , { 1 } );
  pwbm = pwbsSolveModel( pwbm );

  [ data , units ] = pwbsGetOutput( pwbm , 'Antenna' , 'Tx' , { 'ACS' , 'AE' , 'absorbedPower' } );
  ACS_val = lambda.^2 ./ 8.0 ./ pi .* 2;
  AE_val = ones( size( f ) );
  absorbedPower_val = 1.0;
  isPass = isPass && isValid( data{1} , ACS_val );
  isPass = isPass && isValid( data{2} , AE_val );
  isPass = isPass && isValid( data{3} , absorbedPower_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' } );
  powerDensity_val = 1.0 ./ ACS_val;
  isPass = isPass && isValid( data{1} , powerDensity_val );
  
end % function
