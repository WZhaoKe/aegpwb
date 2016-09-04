function [ isPass ] = pwbsTestSphere1()
% pwbsTestSphere1 - 
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

  tol = 1e-6;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
 
  f = linspace( 1e9 , 14e9 , 10 )';
  radius = 0.1;
  eps_r = 42;
  sigma = 0.99;
  mu_r = 1.0;
 
  [ ACS_val , AE_val ] = pwbLaminatedSphere( f , radius , eps_r , sigma , mu_r );
  
  pwbm = pwbsInitModel( f , 'TestSphere1' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB' , 'C1' , 1 , 'LaminatedSphere' , { radius , eps_r , sigma , mu_r } );
  pwbm = pwbsSolveModel( pwbm );

  [ data , units ] = pwbsGetOutput( pwbm , 'Absorber' , 'AB' , { 'ACS' , 'AE' } );
  isPass = isPass && isValid( data{1} , ACS_val );
  isPass = isPass && isValid( data{2} , AE_val );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C1' , { 'powerDensity' } );
  isPass = isPass && isValid( data{1} , 1.0 ./ ACS_val );
  
end % function
