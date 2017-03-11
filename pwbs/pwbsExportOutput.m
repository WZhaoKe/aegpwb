function pwbsExportOutput( pwbm , type , tag , parameters )
% pwbsExportOutput - Export results and parameters from PWB model to ASCII file.
%
% pwbsExportOutput( pwbm , type , tag , parameters )
%
% Inputs:
%
% pwbm       - structure, contains the model state.
% type       - string, type of object to collect data for.
%              Valid types are 'Cavity', 'Antenna' , 'Absorber',
%              'Aperture' and 'Source'
% tag        - string, name of object to collect data for.
% parameters - cell array of strings containing parameter names to collect.
%              Valid parameters for the different types are:
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

  strtrunc=@(x,n) x(1:min([n,length(x)]));

  if( ~strcmp( pwbm.state , 'solved' ) )
    error( 'pwb model has not been solved yet!' );
  end % if

  [ data , units ] = pwbsGetOutput( pwbm , type , tag , parameters );
  
  fileName = [ pwbm.modelName , '_' , type , '_' , tag , '.asc' ];

  % Open file.
  fid = fopen( fileName , 'w' );

  % Write out frequency independent data into header.  
  fprintf( fid , '# AEGPWB %.1f\n' , pwbm.version );
  fprintf( fid , '# %s = %s [-]\n' , 'objectType' , type );
  for idx = 1:length( parameters )
    if( isscalar( data{idx} ) || ischar( data{idx} ) )
      if( ischar( data{idx} ) )
        fprintf( fid , '# %s = %s [%s]\n' , parameters{idx} , data{idx} , units{idx} );        
      else
        fprintf( fid , '# %s = %12.5e [%s]\n' , parameters{idx} , data{idx} , units{idx} );
      end % if
    end % if
  end % for
 
  fprintf( fid , '###\n' );

  % Collect frequency dependent data.
  fdData = [ pwbm.f ];
  nameStr = { 'f'  };
  unitStr = { '[Hz]' };
  for idx = 1:length( parameters )
    if( ~isscalar( data{idx} ) && ~ischar( data{idx} ) )
      assert( all( size( data{idx} ) == size( pwbm.f ) ) );
      fdData = [ fdData , data{idx} ];
      nameStr{end+1} = strtrunc( parameters{idx} , 12 ) ;
      unitStr{end+1} = [ '[' , strtrunc( units{idx} , 10 ) , ']' ];
    end % if
  end % for 

  % Write out header for frequency dependent data.
  fprintf( fid , '# %10s ' , nameStr{1} );
  for idx = 2:length( nameStr )
    fprintf( fid , '%12s ' , nameStr{idx} );
  end % for
  fprintf( fid , '\n' );
  fprintf( fid , '# %10s ' , unitStr{1} );
  for idx = 2:length( unitStr )
    fprintf( fid , '%12s ' , unitStr{idx} );
  end % for
  fprintf( fid , '\n' );
    
  % Close file.
  fclose( fid );

  % Append to data file.
  dlmwrite( fileName , fdData , '-append' , 'delimiter' , ' ' , 'precision' , '%12.5e' );

end % function
