function [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesCount( f , a  , b , c )
% pwbGenericCavityModesCount - exact mode counting for cavity modes in a cuboid cavity
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesCount( f , a , b , c )
%
% Uses exact mode counting to determine the cumulative number and density of modes in a cuboid cavity.
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
% Date: 03/09/2016

  % Get mode frequencies.
  [ f_c , ~ ] = pwbCuboidCavityModeFreqs( f(end) , a , b , c );

  
  if( ~isempty( f_c ) )
  
    f_1 = f_c(1);
    f_60 = f_c(60);
  
    % Find cumulative number of modes. Modes could be degenerate!
    for p=1:length( f )
      numModes(p) = sum( f_c < f(p) );
    end % for

    % Differentiate for mode density. Frequencies may not have uniform spacing!
    % [FIXME] This will give poor result if the sampling rate is low!
    modeDensity = diff( numModes ) ./ ( f(2:end) - f(1:end-1) );
    modeDensity(end+1) = ( numModes(end) - numModes(end-1) ) / ( f(end) - f(end-1) );
    
  else
  
    % Requested frequencies below lowest mode.
    f_1 = NaN;
    f_60 = NaN;
    numModes = zeros( size( f ) );
    modeDensity = zeros( size( f ) );
    
  end % if

end % function
