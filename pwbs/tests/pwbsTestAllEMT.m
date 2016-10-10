function [ isPass ] = pwbsTestAllEMT()
% pwbsTestAllEMT - 
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

  isPass = true;
  
  f = [ 1e9 ];
  pwbm = pwbsInitModel( f , 'TestAllEMT' );
  pwbm = pwbsAddCavity( pwbm , 'C1' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddCavity( pwbm , 'C2' , 'Generic'  , { 1.0 , 1.0 , Inf , 1.0 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB' , 'C1' , 1 , 'ACS' , { 4.0 , 1.0 } );
  pwbm = pwbsAddAperture( pwbm , 'AP1' , 'C1' , 'EXT' , 1 , 'TCS' , { 1.0 , 1.0 } );
  pwbm = pwbsAddAperture( pwbm , 'AP2' , 'C1' , 'C2' , 1 , 'TCS' , { 1.0 , 1.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'PowerDensity' , 'EXT' , { 1 } );
  pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'C1' , 1 , 'Matched' , { 50.0 } );
  pwbm = pwbsAddAntenna( pwbm , 'Rx' , 'C2' , 1 , 'Matched' , { 50.0 } );
  pwbm = pwbsAddSource( pwbm , 'S' , 'Antenna' , 'Tx' , { 1 } );
  pwbsDrawEMT( pwbm ); 
  close();
  
  delete( 'TestAllEMT_EMT.eps' );
  delete( 'TestAllEMT_EMT.png' );
  delete( 'TestAllEMT_EMT.dot' );
  
end % function
