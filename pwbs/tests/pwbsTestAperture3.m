function [ isPass ] = pwbsTestAperture3()
% pwbsTestAperture3 - 
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
  
  dlmwrite( 'pwbsTestAperture3.asc' , [ 0.99e9 , 1.0 ; 1.0e9 , 1.0 ; 1.1e9 , 1.0 ] , ' ' );
  
  pwbm = pwbsInitModel( f , 'TestAperture3' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB' , 'C2' , 1 , 'ACS' , { 4.0 , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  pwbm = pwbsAddAperture( pwbm , 'AP' , 'C1' , 'C2' , 1 , 'FileTCS' , { 1.0 , 'pwbsTestAperture3.asc' } );
  pwbm = pwbsSolveModel( pwbm );
  
  delete( 'pwbsTestAperture3.asc' );
  
  [ data , units ] = pwbsGetOutput( pwbm , 'Absorber' , 'AB' , { 'ACS' , 'AE' , 'absorbedPower' } );
  ACS_val = 1.0;
  AE_val = ones( size( f ) );
  absorbedPower_val = 1.0;
  isPass = isPass && isValid( data{1} , ACS_val );
  isPass = isPass && isValid( data{2} , AE_val );
  isPass = isPass && isValid( data{3} , absorbedPower_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C1' , { 'powerDensity' } );
  powerDensity_val = 2.0;
  isPass = isPass && isValid( data{1} , powerDensity_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C2' , { 'powerDensity' } );
  powerDensity_val = 1.0;
  isPass = isPass && isValid( data{1} , powerDensity_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Aperture' , 'AP' , { 'coupledPower' } );
  coupledPower_val = 1.0;
  isPass = isPass && isValid( data{1} , coupledPower_val );

end % function
