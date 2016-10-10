function [ CCS , decayRate , Q ] = pwbEnergyParamsFromTimeConst( f , timeConst , volume )
% pwbEnergyParamsFromTimeConst - determine energy loss parameters from energy time constant
%
% [ CCS , decayRate , Q ] = pwbEnergyParamsFromTimeConst( f , timeConst , volume )
%
% Inputs:
%
% f         - real vector (numFreq), frequencies [Hz].
% timeConst - real vector (numFreq x 1), total energy time constant [s].
% volume    - real scalar, cavity volume [m^3].
%         
% Outputs:
%
% CCS       - real vector (numFreq), total loss coupling cross-section [m^2].
% decayRate - real vector (numFreq x 1), total energy decay rate [/s].
% Q         - real vector (numFreq x 1), total composite Q-factor [-].
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

  idx = find( timeConst == Inf );
  timeConst(idx) = 1e20;
  
  Q = timeConst .* 2 .* pi .* f;
  decayRate = 1.0 ./ timeConst;
  CCS = decayRate .* volume ./ c0;
 
  decayRate(idx) = 0.0;
  Q(idx) = Inf;
  CCS(idx) = 0.0;
  
end % function
