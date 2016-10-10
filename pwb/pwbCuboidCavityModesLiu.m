function [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesLiu( f , a , b , c )
% pwbGenericCavityModesLiu - Liu continuum limit estimate of cavity modes in a cuboid cavity
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesLiu( f ,  a , b , c )
%
% Uses the Liu formula to estimate the cumulative number and density of modes in a cuboid cavity [1].
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
% [1] B. H. Liu, D. C. Chang, and M. T. Ma [1983], “Eigenmodes and the Composite Quality 
%     Factor of a Reverberation Chamber,” NBS Technical Note 1066, National Institute 
%     of Standards and Technology, Boulder, Colorado 80303-3328, USA.
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
  
  volume = a * b * c;

  numModes = 8 * pi * volume * f.^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0; 
  modeDensity = 8 * pi * volume * f.^2 / c0^3 - ( a + b + c ) / c0;

  % Estimate mode frequencies using basic Weyl formula.
  f_1_est = ( 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3);
  f_60_est = ( 60.0 * 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3); 
  
  % Solve nonlinear equations to improve esitmate.
  fcn1=@(f) 8 * pi * volume * f^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0 - 1;
  fcn60=@(f) 8 * pi * volume * f^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0 - 60;
  f_1 = fzero( fcn1 , f_1_est );
  f_60 = fzero( fcn60 , f_60_est );
    
  % Set to zero if below first mode.
  idx1 = find( f < f_1 );
  numModes(idx1) = 0;
  modeDensity(idx1) = 0;

end %function
