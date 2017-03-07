function [ isPass ] = pwbsTestApertureArray3()
% pwbsTestApertureArray3 - 
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
% Date: 06/03/2017
  
  % Physical consts.
  c0 = 299792458;
  
  rtol = 100 * eps;
  isValid=@(x,y) all( abs( x - y ) ./ x < rtol );
  isPass = true;
  
  f = [ 1e9 ];
  ACS1 = 3.0;
  ACS2 = 7.0;
  
  arrayArea = 1e-2;
  arrayPeriodX = 10e-3;
  arrayPeriodY = 10e-3;
  unitCellArea = 25e-4;
  thickness = 1e-5;
  a_x = 3e-3;
  a_y = 1e-3;
  cutOffFreq = 0.29 * c0 / max( [ a_x , a_y ] );
     
  [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , a_y );
  
  [ TCS , TE ] = pwbApertureArrayTCS( f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );
 
  pwbm = pwbsInitModel( f , 'TestApertureArray1' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB1' , 'C1' , 1 , 'ACS' , { 1.0 , ACS1 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB2' , 'C2' , 1 , 'ACS' , { 1.0 , ACS2 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  pwbm = pwbsAddAperture( pwbm , 'AP1' , 'C1' , 'C2' , 1 , 'EllipticalArray' , { arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , a_x , a_y } );
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
