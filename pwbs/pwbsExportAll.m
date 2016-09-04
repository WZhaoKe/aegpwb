function pwbsExportAll( pwbm )
% pwbsCavityOutput - Write out results for cavities to ASCII files.
%
% pwbsCavityOutput( pwbm )
%
% Inputs:
%
% pwbm   - structure, contains the model state.
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

  if( ~strcmp( pwbm.state , 'solved' ) )
    error( 'pwb model has not been solved yet!' );
  end % if
  
  % Iterate over cavities.
  pwbsExportOutput( pwbm , 'Cavity' , 'EXT' , { 'tag' , 'type' , 'totalCoupledPower' } )
  for cavityIdx=2:pwbm.numCavities
    pwbsExportOutput( pwbm , 'Cavity' , pwbm.cavities(cavityIdx).tag , pwbm.cavityOutputs ); 
  end % for

  % Iterate over apertures.
  for apertureIdx=1:pwbm.numApertures
    pwbsExportOutput( pwbm , 'Aperture' , pwbm.apertures(apertureIdx).tag , pwbm.apertureOutputs ); 
  end % for

  % Iterate over absorbers.
  for absorberIdx=1:pwbm.numAbsorbers
    pwbsExportOutput( pwbm , 'Absorber' , pwbm.absorbers(absorberIdx).tag , pwbm.absorberOutputs ); 
  end % for
  
  % Iterate over antennas.
  for antennaIdx=1:pwbm.numAntennas
    pwbsExportOutput( pwbm , 'Antenna' , pwbm.antennas(antennaIdx).tag , pwbm.antennaOutputs ); 
  end % for
  
  % Iterate over sources.
  for sourceIdx=1:pwbm.numSources
    pwbsExportOutput( pwbm , 'Source' , pwbm.sources(sourceIdx).tag , pwbm.sourceOutputs ); 
  end % for

end % function
