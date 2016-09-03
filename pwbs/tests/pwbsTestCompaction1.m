function [ isPass ] = pwbsTestCompaction1()
%
% pwbsTestCompaction1 - 
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

  f = [ 1e9 ];
  
  pwbm = pwbsInitModel( f , 'TestCompact1' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Cuboid'  , { 1 , 1 , 1 , Inf , 1 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Cuboid'  , { 1 , 1 , 1 , Inf , 1 } );
  pwbm = pwbsAddAperture( pwbm , 'A1' , 'C1' , 'C2' , 1 , 'TCS' , { 1.0 , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB2' , 'C2' , 1 , 'ACS' , { 1.0 , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Direct' , 'C1' , { 1 } );
  CCS = pwbsCompactModel( pwbm , 'Aperture' , 'A1' , { 1 } );

  delete( 'TestCompact1_Aperture_A1_compaction1.asc' );

  isPass = isPass && isValid( CCS , 0.5 );

end % function
