function [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesWeyl( f , volume )
% pwbGenericCavityModesWeyl - Weyl continuum limit estimate of cavity modes in  generic cavity
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesWeyl( f , volume )
%
% Uses the Weyl formula to estimate the cumulative number and density of modes in a cavity.
%
% Inputs:
%
% f      - real vector, frequency [Hz].
% volume - real scalar, cavity volume [m^3].
%
% Outputs:
%
% numNodes    - real vector, number of modes below given frequency [-].
% modeDensity - real vector, density of modes [/Hz]. 
% f_1         - real scalar, lowest cavity resonant frequency [Hz].
% f_60        - real scalar, 60-th cavity resonant frequency [Hz].
%
% References:
%
% [1] H. Weyl, Mathematische Annalen, vol. 71, no. 4, pp. 441-479, 1912.
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
% Date: 03/09/2016
  
  c0 = 299792458;

  % Weyl formula.
  numModes = 8 * pi * volume * f.^3 / 3.0 / c0^3; 
  modeDensity = 8 * pi * volume * f.^2 / c0^3;
  
  % Mode frequencies.
  f_1 = ( 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3);
  f_60 = ( 60.0 * 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3); 
  
  % Set to zero if below first mode.
  idx = find( f < f_1 );
  numModes(idx) = 0;
  modeDensity(idx) = 0;
  
end %function
