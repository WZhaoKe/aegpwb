function [ isPass ] = pwbsTestAperture5()
% pwbsTestAperture5 - 
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
  
  f = [ 1e9 ];
  ACS1 = 3.0;
  ACS2 = 7.0;
  TCS = 1e-3;
  
  pwbm = pwbsInitModel( f , 'TestAperture5' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB1' , 'C1' , 1 , 'ACS' , { 1.0 , ACS1 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB2' , 'C2' , 1 , 'ACS' , { 1.0 , ACS2 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  pwbm = pwbsAddAperture( pwbm , 'AP1' , 'C1' , 'C2' , 1 , 'TCS' , { 1.0 , TCS } );
  pwbm = pwbsSolveModel( pwbm );

  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C1' , { 'powerDensity' } );
  PD1 = data{1};
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C2' , { 'powerDensity' } );
  PD2 = data{1};
  det = ( ACS2 + TCS ) .* ( ACS1 + TCS ) - TCS.^2;
  PD1_val = ( ACS2 + TCS ) ./ det;
  PD2_val = TCS ./ det;
  isPass = isPass && isValid( PD1 , PD1_val );
  isPass = isPass && isValid( PD2 , PD2_val );

end % function
