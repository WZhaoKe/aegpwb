function [ isPass ] = pwbsTestExt1()
% pwbsTestExt1 - 
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

  pwbm = pwbsInitModel( f , 'TestExt1' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB' , 'C' , 1 , 'ACS' , { 4.0 , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C' , { 1 } );
  pwbm = pwbsAddAperture( pwbm , 'AP' , 'C' , 'EXT' , 1 , 'TCS' , { 1.0 , 1.0 } );
  pwbm = pwbsSolveModel( pwbm );
  
  [ data , units ] = pwbsGetOutput( pwbm , 'Absorber' , 'AB' , { 'ACS' , 'absorbedPower' } );
  isPass = isPass && isValid( data{2} , 0.5 );
  [ data , units ] = pwbsGetOutput( pwbm , 'Aperture' , 'AP' , { 'TCS' , 'coupledPower' } );
  isPass = isPass && isValid( data{2} , 0.5 );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' } );
  isPass = isPass && isValid( data{1} , 0.5 );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'EXT' , { 'totalAbsorbedPower' } );  
  isPass = isPass && isValid( data{1} , 0.5 );
  
end % function
