function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , b_y )
% pwbApertureEllipticalPol - polarisabilities of elliptical aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , b_y )
%
% Inputs:
%
% a_x - real scalar, semi-axis along x direction [m].
% a_y - real scalar, semi-axis along y direction [m].
%
% Outputs:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%
% References:
%
% [1] F. De Meulenaere and J. Van Bladel, "Polarizability of some small apertures",
%     IEEE Transactions on Antennas and Propagation, vol. 25, no. 2, pp. 198-205, Mar 1977.
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

  area  = pi * b_y * a_x;
  aspect = b_y / a_x;
  eccentricity = sqrt( 1 - aspect^2 );

  [ K , E ] = ellipke( eccentricity^2 );

  alpha_ezz = pi / 3.0 * a_x * b_y^2 / E;
  alpha_mxx = pi / 3.0 * a_x^3 * eccentricity^2 / ( K - E );
  alpha_myy = pi / 3.0 * a_x^3 * eccentricity^2 / ( ( 1.0 / aspect )^2 * E - K );

end %function
