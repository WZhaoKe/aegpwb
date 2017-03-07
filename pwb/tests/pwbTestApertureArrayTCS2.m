function [ isPass ] = pwbTestApertureArrayTCS2( isPlot )
%pwbTestApertureArrayTCS2 -
%
% Reproduces Fig. 3 from [1].
% 
% References:
%
% [1] U. Paoletti, T. Suga and H. Osaka, 
%     "Average transmission cross section of aperture arrays in electrically large complex enclosures",
%     2012 Asia-Pacific Symposium on Electromagnetic Compatibility, Singapore, 2012, pp. 677-680.
%     DOI: 10.1109/APEMC.2012.6237888
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
% Date: 07/03/2017

  tol = 1e-5;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
 
  if( nargin == 0 )
    isPlot = false;
  end % if
  
  
  c0 = 299792458;
  
  f = logspace( log10( 100e6 ) , log10( 100e9 ) , 400 )';
 
  % Wavenumber.
  k = 2.0 .* pi .* f ./ c0;
  
  %
  % Square aperture on square lattice.
  %
  
  % From [1, Table I].
  arrayPeriodX = 7e-3;
  arrayPeriodY = 7e-3;
  apertureSpacing = 2e-3;
  thickness = 1e-3;
  
  % Side lengths of aperture.
  side_x = arrayPeriodX - apertureSpacing;
  side_y = arrayPeriodY - apertureSpacing;

  % Area of primitive unit cell.
  cellArea = arrayPeriodX * arrayPeriodY;
  
  % Array size is set to unity.
  array_size_x = 1.0;
  array_size_y = 1.0;
  array_area = array_size_x * array_size_y;
  
  % Aperture polarisabilitites.  
  [ apertureArea , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureSquarePol( side_x );

  % Array porosity.
  porosity = apertureArea / arrayPeriodX / arrayPeriodY;
  fprintf( 'Square array porosity: %.2f\n' , porosity );
  
  % Square aperture cut-off frequency.
  cutOffFreq = c0 / 2.0 / max( [ side_x , side_y ] );
  
  % TCS.  
  [ TCS_sq , TE_sq ] = pwbApertureArrayTCS( f , 1.0 , arrayPeriodX , arrayPeriodY , cellArea , thickness , apertureArea , alpha_mxx , alpha_myy , alpha_ezz , cutOffFreq );

  %
  % Hexagonal apertures on parallelogram lattice.
  %
  
  % From [1, Table I].
  arrayPeriodX = 5e-3;
  arrayPeriodY = 5e-3 * sqrt( 3 );
  apertureSpacing = 1e-3;
  thickness = 1e-3;
  
  % Side length of hexagonal aperture.
  side = ( arrayPeriodX - apertureSpacing ) / sqrt( 3 );
  
  % Perpendicular distance from centre of aperture to mid-poinr of a side. 
  h = ( arrayPeriodX - apertureSpacing ) / 2;
  
  % Area of primitive unit cell.
  cellArea = arrayPeriodX * arrayPeriodY / 2.0;

  % Array size is set to unity.
  array_size_x = 1.0;
  array_size_y = 1.0;
  array_area = array_size_x * array_size_y;
    
  % Aperture polarisabilitites - use circular aperture of smae area.
  A_hex = 3 * sqrt( 3 ) / 2 * side^2;
  radius = sqrt( A_hex / pi );
  [ apertureArea , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius );
  
  % Array porosity.
  porosity = ( 1 - apertureSpacing / arrayPeriodX )^2; 
  fprintf( 'Hexagonal array porosity: %.2f\n' , porosity );
  
  % Hexagonal aperture cut-off frequency.
  cutOffFreq = c0 / pi / side;

  % TCS.
  [ TCS_hex , TE_hex ] = pwbApertureArrayTCS( f , array_area , arrayPeriodX , arrayPeriodY , cellArea , thickness , apertureArea , alpha_mxx , alpha_myy , alpha_ezz , cutOffFreq );
  
  %
  % Circular aperture on square lattice.
  % 
  
  % Scroff 4U grills.
  arrayPeriodX = 4.8e-3;
  arrayPeriodY = 4.7e-3;
  apertureSpacing = ( 4.80e-3 - 3.96e-3 );
  thickness = 0.92e-3;
  
  % Side lengths of aperture.
  radius = 0.5 * ( arrayPeriodX - apertureSpacing );

  % Area of primitive unit cell.
  cellArea = arrayPeriodX * arrayPeriodY;
  
  % Array size is set to unity.
  array_size_x = 1.0;
  array_size_y = 1.0;
  array_area = array_size_x * array_size_y;
  
  % Aperture polarisabilitites.  
  [ apertureArea , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius );

  % Array porosity.
  porosity = apertureArea / arrayPeriodX / arrayPeriodY;
  fprintf( 'Cicular array porosity: %.2f\n' , porosity );

  % Circular aperture cut-off frequency.
  cutOffFreq = 3.682 * c0 / 4.0 / pi / radius;
  
  % TCS.  
  [ TCS_circ , TE_circ ] = pwbApertureArrayTCS( f , array_area , arrayPeriodX , arrayPeriodY , cellArea , thickness , apertureArea , alpha_mxx , alpha_myy , alpha_ezz , cutOffFreq );
  [ TCS_circ_2 , TE_circ_2 ] = pwbPerforatedScreen( f , array_area , arrayPeriodX , apertureArea );

  %
  % Plots.
  %
  
  if( isPlot )
    
    figure()
    semilogx( f ./ 1e9 , db10( TE_sq ) , 'r-' );
    hold on;
    semilogx( f ./ 1e9 , db10( TE_hex ) , 'b-' );
    semilogx( f ./ 1e9 , db10( TE_circ ) , 'g-' );
    semilogx( f ./ 1e9 , db10( TE_circ_2 ) , 'k-' );
    grid( 'on' );
    xlabel( 'Frequency (GHz)' );
    ylabel( 'Average transmission efficiency, <Q^t> / A (dB)' );
    legend( 'Square, analytic' , 'Hexagonal, analytic' , 'Cicular, analytic' , 'Check' , 'location' , 'southeast' );
    print( '-depsc2' , 'pwbTestApertureArrayTCS2.eps' );
    hold off;
  
  end % if
  
%  isPass = isPass && isValid( ACS1 , ACS1b );
%  isPass = isPass && isValid( ACS1 , ACS2b );

end % function
