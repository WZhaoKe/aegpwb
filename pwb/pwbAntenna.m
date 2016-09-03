function [ ACS , AE ] = pwbAntenna( f , isTx , AE )
% pwbAntenna - average absorption cross-section of antenna.
%
% [ ACS , AE ] = pwbAntenna( f , isTx , AE )
%
% Inputs:
%
% f    - real vector, frequency [Hz].
% isTx - boolean, transmitting antenna if true [0 or 1].
% AE   - real vector, efficiency of antenna [-]
%
% Outputs:
%
% ACS - absorption cross-section [m^2].
% AE  - antenna efficiency [-].
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

  c0 = 299792458;
  
  lambda = c0 ./ f;
  
  if( nargin == 2 )
    AE = ones( size ( f ) ) ;
  end % if
  
  ACS = AE .* lambda.^2 ./ ( 8 .* pi );

  if( isTx ) 
    ACS = 2.0 .* ACS;
  end %if

end %function
