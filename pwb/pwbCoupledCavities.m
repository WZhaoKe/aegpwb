function [ PD1 , PD2 , SR1 , SR2 , TACS1 , TACS2 ] = pwbCoupledCavities( ACS1 , ACS2 , TCS , Pt1 , Pt2 )
% pwbCoupledCavities - power densities and shielding ratios of coupled cavities. 
%
% [ PD1 , PD2 , SR1 , SR2 , TACS1 , TACS2 ] = pwbCoupledCavities( ACS1 , ACS2 , TCS , Pt1 , Pt2 )
%
%                  cavity 1   _______    cavity 2
%          -----------o------|_______|------o-----------
%         |           |         TCS         |           |
%         -     +     -                     -     +     -
%        / \         | |                   | |         / \
%   Pt1 | ^ |  PD1   | | ACS1         ACS2 | |   PD2  | ^ | Pt2
%        \ /         | |                   | |         \|/
%         -     -     -                     -     -     -
%         |           |                     |           |
%          ----------------------------------------------
%
% Inputs:
%
% ACS1 - real vector, absorption cross-section of losses cavity 1 [m^2].
% ACS2 - real vector, absorption cross-section of losses cavity 2 [m^2].
% TCS  - real vector, transmission cross-section between captivities [m^2].
% Pt1  - real vector, power injected into cavity 1 [W].
% Pt2  - real vector, power injected into cavity 2 [W].
%
% Outputs:
%
% PD1   - real vector, power density in cavity 1 [W/m^2].
% PD2   - real vector, power density in cavity 2 [W/m^2].
% SR1   - real vector, shielding ratio of cavity 1 [-].
% SR2   - real vector, shielding ratio of cavity 2 [-].
% TACS1 - real vector, total absorption cross-section seen from cavity 1 [m^2].
% TACS2 - real vector, total absorption cross-section seen from cavity 2 [m^2].
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

  det = ( ACS1 + TCS ) .* ( ACS2 + TCS ) - TCS.^2;
  PD1 = ( ( ACS2 + TCS ) .* Pt1  + TCS .* Pt2 ) ./ det;
  PD2 = ( TCS .* Pt1  + ( ACS1 + TCS ) .* Pt2 ) ./ det;
  SR1 = 1.0 + ACS1 ./ TCS;
  SR2 = 1.0 + ACS2 ./ TCS;
  TACS1 = ACS1 + ACS2 ./ SR2;
  TACS2 = ACS2 + ACS1 ./ SR1;
  
end % function
