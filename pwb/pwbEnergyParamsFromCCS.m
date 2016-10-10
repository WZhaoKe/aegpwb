function [ Q , decayRate , timeConst ] = pwbEnergyParamsFromCCS( f , CCS , volume )
% pwbEnergyParamsFromCCS - determine energy loss parameters from total coupling cross-section
%
% [ Q , decayRate , timeConst ] = pwbEnergyParamsFromCCS( f , CCS , volume )
%
% Inputs:
%
% f      - real vector (numFreq), frequencies [Hz].
% CCS    - real vector (numFreq), total loss coupling cross-section [m^2].
% volume - real scalar, cavity volume [m^3].
%         
% Outputs:
%
% Q         - real vector (numFreq x 1), total composite Q-factor [-].
% decayRate - real vector (numFreq x 1), total energy decay rate [/s].
% timeConst - real vector (numFreq x 1), total energy time constant [s].
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
% Date: 01/09/2016   

  c0 = 299792458;

  idx = find( CCS == 0 );
  CCS(idx) = eps;

  decayRate = c0 .* CCS ./ volume;
  timeConst = 1.0 ./ decayRate;
  Q = 2 .* pi .* f .* timeConst;
    
  decayRate(idx) = 0.0;
  timeConst(idx) = Inf;
  Q(idx) = Inf;
  
end % function
