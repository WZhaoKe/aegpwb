function RC()
% RC - reverberation chamber PWB model
%
% RC()
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

  % Set frequencies to analyse.
  f = logspace( log10( 1e9 ) , log10( 100e9 ) , 100 );

  % Properties of chamber.
  a_RC = 2.37;
  b_RC = 3.00;
  c_RC = 4.70;
  sigma_eff_RC = 0.16e6; 
  mu_r_RC = 1.0;

  % Initial model.
  pwbm = pwbsInitModel( f , 'RC' );
      
  % Add the objects to the model.
  pwbm = pwbsAddCavity( pwbm , 'RC' , 'Cuboid'  , ...
    { a_RC , b_RC , c_RC , sigma_eff_RC , mu_r_RC } );
  pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'RC' , 1 , 'Matched' , { 50 } );
  pwbm = pwbsAddAntenna( pwbm , 'Rx1' , 'RC' , 1 , 'Matched' , { 50 } );
  pwbm = pwbsAddSource( pwbm , 'STx', 'Antenna' , 'Tx' , { 1 } );
  pwbm = pwbsAddAbsorber( pwbm , 'AB1', 'RC' , 1.0 , 'AE' , { 0.01 , 1.0 } );
   
  % Visualise the EMT.
  pwbsDrawEMT( pwbm );    
      
  % Solve the model.
  pwbm = pwbsSolveModel( pwbm );
       
  % Export all the results to ASCII files.
  pwbsExportAll( pwbm );
     
  % Get the power density in each chamber.
  data = pwbsGetOutput( pwbm , 'Antenna' , 'Rx1' , { 'absorbedPower' } );
  IG_RC = data{1};
       
  % Save the model to a file.
  pwbsSaveModel( pwbm );
      
  figure();
  semilogx( f ./ 1e9 , 10 .* log10( IG_RC ) , 'lineWidth' , 3 );
  xlabel( 'Frequency (GHz)' , 'fontSize' , 18 , 'fontName' , 'Helvetica' );
  ylabel( 'Chamber insertion gain (dB)' , 'fontSize' , 18 , 'fontName' , 'Helvetica' );
  set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
  set( gca , 'fontSize' , 18 , 'fontName' , 'Helvetica' );
  ylim( [ -60 0 ] );
  grid( 'on' );
  print( '-dpng' , 'RC_IG.png' );
      
end % function
