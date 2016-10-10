function [ isPass ] = pwbsTestProb2()
% pwbsTestProb2 - 
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

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );
  
  tol = 100 * eps;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  f = logspace( log10( 10e6 ) , log10( 100e9 ), 10 )';
  pwbm = pwbsInitModel( f , 'TestProb2' );
  pwbm = pwbsAddCavity( pwbm , 'C' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB' , 'C' , 1 , 'ACS' , { 1.0 , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C' , { 1 } );
  pwbm = pwbsSolveModel( pwbm );

  [ meanQuantity , stdQuantity , quantQuantity ] = pwbsStats( pwbm , 'Cavity' , 'C' , 'Ei2' );
  [ data , units ] = pwbsGetOutput( pwbm , 'Cavity' , 'C' , { 'powerDensity' } );
  refValue = 2.0 .* eta0 .* data{1} ./ 3.0;
  sigma = sqrt( refValue ./ 2.0 );
  meanQuantity_val = 2.0 * sigma.^2;
  stdQuantity_val = 2.0 * sigma.^2;
  isPass = isPass && isValid( meanQuantity  , meanQuantity_val );
  isPass = isPass && isValid( stdQuantity  , stdQuantity_val );
  
end % function
