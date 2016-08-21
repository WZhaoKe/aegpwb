function [ data , units ] = pwbsGetOutput( pwbm , type , tag , parameters )
%
% pwbsGetOutput - Get results and parameters from PWB model.
%
% [ data ] = pwbsGetOutput(  pwbm , type , tag , parameters )
%
% Inputs:
%
% pwbm       - structure, contains the model state.
% type       - string, type of object to collect data for.
%              Valid types are 'Cavity', 'Antenna' , 'Absorber',
%              'Aperture' and 'PowerSource'
% tag        - string, name of object to collect data for.
% parameters - cell array of strings containing parameter names to collect.
%              Valid parameters for the different types are:
%
%              'Cavity'      - 'wallACS',
%              'Antenna'     - 'ACS',
%              'Absorber'    - 'ACS',
%              'Aperture'    - 'TCS',
%              'PowerSource' - 'power' , 
%
% Outputs:
%
% data  - cell array, data{i} contains the data for parameter{i}.
% units - cell array, units{i} contains a string with the unitis of output i.
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

  if( ~strcmp( pwbm.state , 'solved' ) )
    error( 'pwb model has not been solved yet!' );
  end % if
  
  switch( type )
  case 'Cavity'
    cavityIdx = mapGet( pwbm.cavityMap , tag );
    for idx=1:length( parameters )
      validatestring( parameters{idx} , pwbm.cavityOutputs , 'pwbsGetOutput' , sprintf( 'parameter{%d}' , idx ) );
      if( isfield( pwbm.cavities(cavityIdx) , parameters{idx} ) )
        data{idx} = getfield( pwbm.cavities(cavityIdx) , parameters{idx} );
      else
        error( 'unknown parameter %s for cavity type' , parameters{idx} );
      end % if
      if( isfield( pwbm.cavityUnits , parameters{idx} ) )
        units{idx} = getfield( pwbm.cavityUnits , parameters{idx} );
      else
        error( 'unknown cavity output %s' , parameters{idx} );
      end % if
    end % for
  case 'Antenna'
    antennaIdx = mapGet( pwbm.antennaMap , tag );
    for idx=1:length( parameters )
      validatestring( parameters{idx} , pwbm.antennaOutputs , 'pwbsGetOutput' , sprintf( 'parameter{%d}' , idx ) );
      if( isfield( pwbm.antennas(antennaIdx) , parameters{idx} ) )
        data{idx} = getfield( pwbm.antennas(antennaIdx) , parameters{idx} );
      else
        error( 'unknown parameter %s for antenna type' , parameters{idx} );
      end % if
      if( isfield( pwbm.antennaUnits , parameters{idx} ) )
        units{idx} = getfield( pwbm.antennaUnits , parameters{idx} );
      else
        error( 'unknown antenna output %s' , parameters{idx} );
      end % if
    end % for
  case 'Aperture'
    apertureIdx = mapGet( pwbm.apertureMap , tag );  
    for idx=1:length( parameters )
      validatestring( parameters{idx} , pwbm.apertureOutputs , 'pwbsGetOutput' , sprintf( 'parameter{%d}' , idx ) );
      if( isfield( pwbm.apertures(apertureIdx) , parameters{idx} ) )
       data{idx} = getfield( pwbm.apertures(apertureIdx) , parameters{idx} );
      else
        error( 'unknown parameter %s for aperture type' , parameters{idx} );
      end % if
      if( isfield( pwbm.apertureUnits , parameters{idx} ) )
        units{idx} = getfield( pwbm.apertureUnits , parameters{idx} );
      else
        error( 'unknown aperture output %s' , parameters{idx} );
      end % if
    end % for
  case 'Absorber'
    absorberIdx = mapGet( pwbm.absorberMap , tag );
    for idx=1:length( parameters )
      validatestring( parameters{idx} , pwbm.absorberOutputs , 'pwbsGetOutput' , sprintf( 'parameter{%d}' , idx ) );
      if( isfield( pwbm.absorbers(absorberIdx) , parameters{idx} ) )
       data{idx} = getfield( pwbm.absorbers(absorberIdx) , parameters{idx} );
      else
        error( 'unknown parameter %s for absorber type' , parameters{idx} );
      end % if
      if( isfield( pwbm.absorberUnits , parameters{idx} ) )
        units{idx} = getfield( pwbm.absorberUnits , parameters{idx} );
      else
        error( 'unknown absorber output %s' , parameters{idx} );
      end % if
    end % for       
   case 'Source'
    sourceIdx = mapGet( pwbm.sourceMap , tag );
    for idx=1:length( parameters )
      validatestring( parameters{idx} , pwbm.sourceOutputs , 'pwbsGetOutput' , sprintf( 'parameter{%d}' , idx ) );
      if( isfield( pwbm.sources(sourceIdx) , parameters{idx} ) )
       data{idx} = getfield( pwbm.sources(sourceIdx) , parameters{idx} );
      else
        error( 'unknown parameter %s for source type' , parameters{idx} );
      end % if
      if( isfield( pwbm.sourceUnits , parameters{idx} ) )
        units{idx} = getfield( pwbm.sourceUnits , parameters{idx} );
      else
        error( 'unknown source output %s' , parameters{idx} );
      end % if
    end % for         
  otherwise
    error( 'unknown type %s ' , type );
  end % switch
  
end % function
