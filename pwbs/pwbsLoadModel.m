function [ pwbm ] = pwbsLoadModel( modelName )
% pwbsLoadModel - Load PWB model from file.
%
% pwbsSaveModel( pwbm )
%
% Inputs:
%
% modelName - string, name of model to load.
%
% Outputs
%
% pwbm   - structure, contains the model state.
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

  fileName = [ modelName , '.mat' ];
  
  if( ~exist( fileName , 'file' ) )
    error( 'model file %s does not exist' , fileName );
  else
    pwbm = load( fileName );
  end % if
  
  if( ~strcmp( modelName , pwbm.modelName ) )
    warning( 'file name of model (%s) and model name in file (%s) differ' , modelName , pwbm.modelName );
  end % if

end % function
