function [ isPass ] = pwbTestCavityModes()
% pwbTestCavityModes -
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

  isPass = true;
  
  f = logspace( log10( 10e6 ) , log10(1e9) , 200 );

  a = 1.0;
  b = 2.0;
  c = 3.0;
  volume =  a * b * c;

  [ numModes_Weyl , modeDensity_Weyl , f_1_Weyl , f_60_Weyl ] = pwbGenericCavityModesWeyl( f , volume );

  [ numModes_Liu , modeDensity_Liu , f_1_Liu , f_60_Liu ] = pwbCuboidCavityModesLiu( f , a , b , c );

  [ numModes_Count , modeDensity_Count , f_1_Count , f_60_Count ] = pwbCuboidCavityModesCount( f , a  , b , c );

  numModes_Weyl(find( numModes_Weyl <= 0 )) = NaN;
  numModes_Liu(find( numModes_Liu <= 0 )) = NaN;
  numModes_Count(find( numModes_Count <= 0 )) = NaN;
  modeDensity_Weyl(find( modeDensity_Weyl <= 0 )) = NaN;
  modeDensity_Liu(find( modeDensity_Liu <= 0 )) = NaN;
  modeDensity_Count(find( modeDensity_Count <= 0 )) = NaN;
  
  hf1 = figure();
  hl1 = loglog( f ./1e6 , numModes_Weyl , 'r-' );
  hold on;
  hl2 = loglog( f ./1e6 , numModes_Liu , 'b-' );
  hl3 = loglog( f ./1e6 , numModes_Count , 'kd' );
  line( [ f_1_Count , f_1_Count ] ./ 1e6 , [ 1 , 10 ] );
  text( f_1_Count / 1e6 , 12 , sprintf( 'f_1 = %g MHz' , f_1_Count / 1e6 ) );
  line( [ f_60_Count , f_60_Count ] ./ 1e6 , [ 60 , 6 ] );
  text( f_60_Count / 1e6 , 4 , sprintf( 'f_{60} = %g MHz' , f_60_Count / 1e6 ) );
  xlabel( 'Frequency (MHz)' );
  ylabel( 'Cumulative number of modes (-)' );
  legend( 'Weyl' , 'Liu' , 'Count' , 'location' , 'northwest' );
  set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
  set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
  set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
  set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
  grid( 'on' );
  xlim( [ 80 1000 ] );
  print( '-dpng' , 'pwbTestCavityModes_numModes.png' );
  hold off;
  close( hf1 );
  
  hf2 = figure();
  hl1 = loglog( f ./1e6 , 1e6 .* modeDensity_Weyl , 'r-' );
  hold on;
  hl2 = loglog( f ./1e6 , 1e6 .* modeDensity_Liu , 'b-' );
  hl3 = loglog( f ./1e6 , 1e6 .* modeDensity_Count , 'kd' );
  xlabel( 'Frequency (MHz)' );
  ylabel( 'Mode density (/MHz)' );
  legend( 'Weyl' , 'Liu' , 'Count' , 'location' , 'northwest' );
  set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
  set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
  set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
  set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
  grid( 'on' );
  xlim( [ 80 1000 ] );
  print( '-dpng' , 'pwbTestCavityModes_modeDensity.png' );
  hold off;
  close( hf2 );
  
end % function
