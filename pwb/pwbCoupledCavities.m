function [ S1 , S2 , SR1 , SR2 , TACS1 , TACS2 ] = pwbCoupledCavities( ACS1 , ACS2 , TCS , Pt1 , Pt2 )
%
% pwbCoupledCavities - power densities in coupled cavities. 
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
% Version: 1.0.0

  det = ( ACS1 + TCS ) .* ( ACS2 + TCS ) - TCS.^2;
  S1 = ( ( ACS2 + TCS ) .* Pt1  + TCS .* Pt2 ) ./ det;
  S2 = ( TCS .* Pt1  + ( ACS1 + TCS ) .* Pt2 ) ./ det;
  SR1 = 1.0 + ACS1 ./ TCS;
  SR2 = 1.0 + ACS2 ./ TCS;
  TACS1 = ACS1 + ACS2 ./ SR2;
  TACS2 = ACS2 + ACS1 ./ SR1;
  
end % function
