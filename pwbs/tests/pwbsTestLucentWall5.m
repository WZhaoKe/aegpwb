function [ isPass ] = pwbsTestLucentWall5()
%
% pwbsTestLucentWall5 - 
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
  f = [ 1e9 ; 2e9 ; 3e9 ];
  area = 4.0;
  epsc_r = 2.0;
  sigma = 1e-1;
  mu_r = 1.0;
  thickness = 0.2;
  
  [ ACS1_val , ACS2_val , TCS_val , AE1_val , AE2_val , TE_val ] = pwbLucentWall( f , area , thickness , epsc_r , sigma , mu_r );
  
  dlmwrite( 'pwbsTestLucentWall5.asc' , [ f , AE1_val , AE2_val , TE_val ] );
  
  pwbm = pwbsInitModel( f , 'TestLucentWall5' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  pwbm = pwbsAddAperture( pwbm , 'LW' , 'C1' , 'C2' , 1 , 'LucentWallFileCE' , { area , 'pwbsTestLucentWall5.asc' } );
  pwbm = pwbsSetupModel( pwbm );
  pwbm = pwbsSolveModel( pwbm );
 
  delete( 'pwbsTestLucentWall5.asc' );
 
  [ data , units ] = pwbsGetOutput( pwbm , 'Aperture' , 'LW_T' , { 'TCS' , 'TE' } );
  isPass = isPass && isValid( data{1} , TCS_val );
  isPass = isPass && isValid( data{2} , TE_val );  
  [ data , units ] = pwbsGetOutput( pwbm , 'Absorber' , 'LW_A1' , { 'ACS' , 'AE' } );
  isPass = isPass && isValid( data{1} , ACS1_val );  
  isPass = isPass && isValid( data{2} , AE1_val ); 
  [ data , units ] = pwbsGetOutput( pwbm , 'Absorber' , 'LW_A2' , { 'ACS' , 'AE' } );
  isPass = isPass && isValid( data{1} , ACS2_val );  
  isPass = isPass && isValid( data{2} , AE2_val ); 
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C1' , { 'powerDensity' } );
  
  [ S1_val , S2_val , ~ , ~ , ~ , ~ ] = pwbsCoupledCavities( ACS1_val , ACS2_val , TCS_val , 1.0 , 0.0 );
  isPass = isPass && isValid( data{1} , S1_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C2' , { 'powerDensity' } );
  isPass = isPass && isValid( data{1} , S2_val );

end % function
