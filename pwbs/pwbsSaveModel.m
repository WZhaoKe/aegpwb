function pwbsSaveModel( pwbm )
% pwbsSaveModel - Save PWB model to file.
%
% pwbsSaveModel( pwbm )
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

  fileName = [ pwbm.modelName , '.mat' ];
  save( '-v7' , fileName , '-struct' , 'pwbm' );
  fprintf( 'model %s saved to file %s\n' , pwbm.modelName , fileName );
  
end % function
