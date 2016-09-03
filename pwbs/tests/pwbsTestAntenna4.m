function [ isPass ] = pwbsTestAntenna4()
%
% pwbsTestAntenna4 - 
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
  
  c0 = 299792458;
  f = [ 1e9 ];
  lambda = c0 ./ f;
  
  dlmwrite( 'pwbsTestAntenna4.asc' , [ 0.99e9 , 0.5 ; 1.0e9 , 0.5 ; 1.1e9 , 0.5 ] , ' ' );
  
  pwbm = pwbsInitModel( f , 'TestAntenna4' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'C' , 1 , 'MismatchedFileAE' , { 'pwbsTestAntenna4.asc' , 50.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Antenna' , 'Tx' , { 1 } );
  pwbm = pwbsSolveModel( pwbm );
  
  delete( 'pwbsTestAntenna4.asc' );
  
  [ data , units ] = pwbsGetOutput( pwbm , 'Antenna' , 'Tx' , { 'ACS' , 'AE' , 'absorbedPower' } );
  ACS_val = 0.5 .* lambda.^2 ./ 8.0 ./ pi .* 2;
  AE_val = 0.5 .* ones( size( f ) );
  absorbedPower_val = 0.5;
  isPass = isPass && isValid( data{1} , ACS_val);
  isPass = isPass && isValid( data{2} , AE_val );
  isPass = isPass && isValid( data{3} , absorbedPower_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' } );
  powerDensity_val = 0.5 ./ ACS_val;
  isPass = isPass && isValid( data{1} , powerDensity_val );

end % function
