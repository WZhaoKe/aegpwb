function [ TCS , TE ] = pwbPerforatedScreen( f , arrayArea , arrayPeriod , apertureArea )
%pwbPerforatedScreen - TCS of a large area of metal plate perforated with a 
%                      two-dimensional array of low aspect ratio apertures.
%
% [ TCS , TE ] =  pwbPerforatedScreen( f , arrayArea , arrayPeriod , apertureArea )
%
% Inputs:
%
% f            - real vector, frequencies [Hz].
% arrayArea    - real scalar, perforated area [m^2].
% arrayPeriod  - real scalar, period of the hole array [m].
% apertureArea - real scalar, area of single aperture [m^2].
%
% Outputs:
%
% TCS - real vector, average transmission cross-section [m2].
% TE  - real vector, average transmission efficiency [-].
% f_c - real scalar, cut-off frequency [Hz].
%
% References:
%
% [1] S.-W. Lee, G. Zarrillo and C.-L. Law, 
%     "Simple formulas for transmission through periodic metal grids or plates",
%     IEEE Transactions on Antennas and Propagation, vol. 30, no. 5, pp. 904-909, Sep 1982.
%     DOI: 10.1109/TAP.1982.1142923
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2017 Ian Flintoft <ian.flintoft@googlemail.com>
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
% Date: 19/01/2017

  c0 = 299792458;
  
  lambda = c0 ./ f;
  
  apertureSize = sqrt( apertureArea );
  
  delta = 0.5 * ( arrayPeriod - apertureSize );
  
  beta = ( 1.0 - 0.41 .* delta ./ arrayPeriod ) ./ ( arrayPeriod ./ lambda );

  Y_ind = -1j .* ( beta - 1.0 ./ beta ) .* ...
    ( ( arrayPeriod ./ apertureSize ) + 0.5 .* ( arrayPeriod ./ lambda ).^2 ) ./ log( csc( 0.8 .* pi .* delta ./ arrayPeriod ) );

  T = 1.0 ./ ( 1.0 + Y_ind );
  TE = abs( T ).^2;
  TCS = 0.25 .* arrayArea .* TE;

  % Geometric optics limit.
  TCS_GO = 0.25 * arrayArea * ( apertureSize / arrayPeriod )^2;

  % Assume GO if TCS excceds GO limit or imaginary part of T is negative.
  mask = ( TCS >= TCS_GO ) | ( imag( T ) <= 0 );
  TCS = TCS .* ~mask + TCS_GO .* mask;
  TE = 4.0 .* TCS / arrayArea;
  
end % function
