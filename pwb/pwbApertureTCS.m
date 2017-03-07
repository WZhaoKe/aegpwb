function [ TCS , TE , f_c ] = pwbApertureTCS( f , area  , alpha_mxx , alpha_myy , alpha_ezz )
%pwbsApertureTCS - Average transmission cross-section of an aperture.
%
% [ TCS , TE , f_c ] = pwbApertureTCS( f , area , alpha_mxx , alpha_myy , alpha_ezz )
%
% Determine the average transmission cross-section of an aperture from its area and electric
% and magnetic polarisabiltites [1]. 
%
% Note: The TCS and TE follow convention of including the factor of half from the 
% half-space illumination in the cross-section itself.
%
% Inputs:
%
% f         - real vector, frequency [Hz].
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%
% Output:
%
% TCS - real vector, average transmission cross-section [m^2].
% TE  - real vector, average transmission efficiency [-]
% f_c - real vector, cut-off frequency [Hz].
%
% References:
%
% [1] D. A. Hill, M. T. Ma, A. R. Ondrejka, B. F. Riddle, M. L. Crawford and R. T. Johnk, 
%     "Aperture excitation of electrically large, lossy cavities", IEEE Transactions on 
%     Electromagnetic Compatibility, vol. 36, no. 3, pp. 169-178, Aug 1994.
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
  w = 2.0 .* pi .* f;
  k = w ./ c0;

  f_c = c0 / 2.0 / pi * ( ( 9.0 * pi * area ) / ( 8.0 * ( alpha_ezz^2 + alpha_mxx^2 + alpha_myy^2 ) ) )^0.25;  
  TCS_LF = 2.0 .* k.^4.0 ./ 9.0 ./ pi .* ( alpha_ezz^2 + alpha_mxx^2 + alpha_myy^2 );
  TCS_HF = area ./ 4.0;

  TCS = ( f < f_c ) .* TCS_LF + ( f >= f_c ) .* TCS_HF;  
  TE = 4.0 .* TCS ./ area;

end %function
