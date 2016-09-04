function [ isPass ] = pwbsTestAntenna2()
% pwbsTestAntenna2 - 
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

  tol = 100 * eps;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  c0 = 299792458;
  f = [ 1e9 ];
  lambda = c0 ./ f;

  pwbm = pwbsInitModel( f , 'TestAntenna2' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'C' , 1 , 'Matched' , { 50.0 } );
  pwbm = pwbsAddAntenna( pwbm , 'Rx' , 'C' , 1 , 'Matched' , { 50.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Antenna' , 'Tx' , { 1 } );
  pwbm = pwbsSolveModel( pwbm );

  [ data , units ] = pwbsGetOutput( pwbm , 'Antenna' , 'Tx' , { 'ACS' , 'AE' , 'absorbedPower' } );
  ACS_Tx_val = lambda.^2 ./ 4.0 ./ pi;
  AE_Tx_val = ones( size( f ) );
  absorbedPower_Tx_val = 2.0 ./ 3.0 .* ones( size( f ) );
  isPass = isPass && isValid( data{1} , ACS_Tx_val );
  isPass = isPass && isValid( data{2} , AE_Tx_val );
  isPass = isPass && isValid( data{3} , absorbedPower_Tx_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Antenna' , 'Rx' , { 'ACS' , 'AE' , 'absorbedPower' } );
  ACS_Rx_val = lambda.^2 ./ 8.0 ./ pi;
  AE_Rx_val = ones( size( f ) );
  absorbedPower_Rx_val = 1.0 ./ 3.0 .* ones( size( f ) );
  isPass = isPass && isValid( data{1} , ACS_Rx_val );
  isPass = isPass && isValid( data{2} , AE_Rx_val );
  isPass = isPass && isValid( data{3} , absorbedPower_Rx_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' } );
  powerDensity_val = 1.0 ./ ( ACS_Tx_val + ACS_Rx_val );
  isPass = isPass && isValid( data{1} , powerDensity_val );

end % function
