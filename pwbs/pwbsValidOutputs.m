function [ validOutputs , units ] = pwbsValidOutputs( pwbm , type , isShow )
%
% pwbsValidOutputs - Get valid outputs and units for object type.
%
% [ validOutputs , unit ] = pwbsValidOutputs(  pwbm , type , isShow )
%
% Inputs:
%
% pwbm       - structure, contains the model state.
% type       - string, type of object to collect data for.
%              Valid types are 'Cavity', 'Antenna' , 'Absorber',
%              'Aperture' and 'PowerSource'
% isShow     - scalar bool, optional, default true, if true list
%              valid outputs and units to screen.
%
% Outputs:
%
% validOutputs - cell array, contains the valid outputs.
% units        - cell array, contains units of the outputs.
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

  if( nargin == 2 )
    isShow = true;
  end % if
  
  switch( type )
  case 'Cavity'
    validOutputs = pwbm.cavityOutputs;
    units = fields2cell( pwbm.cavityUnits , pwbm.cavityOutputs );
  case 'Antenna'
    validOutputs = pwbm.antennaOutputs;
    units = fields2cell( pwbm.antennaUnits , pwbm.antennaOutputs );   
  case 'Aperture'
    validOutputs = pwbm.apertureOutputs;
    units = fields2cell( pwbm.apertureUnits , pwbm.apertureOutputs );
  case 'Absorber'
    validOutputs = pwbm.absorberOutputs;
    units = fields2cell( pwbm.absorberUnits , pwbm.absorberOutputs ); 
  case 'Source'
    validOutputs = pwbm.sourceOutputs;
    units = fields2cell( pwbm.sourceUnits , pwbm.sourceOutputs );
  otherwise
    error( 'unknown type %s ' , type );
  end % switch
  
  if( isShow )
    for idx = 1:length( validOutputs )
      fprintf( '  %-20s %-10s\n' , validOutputs{idx} , units{idx} );
    end % for
  end % if
  
end % function
