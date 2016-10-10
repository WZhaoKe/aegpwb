function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius )
% pwbApertureCircularPol - polarisabilities of circular aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius )
%
% Inputs:
%
% radius - real scalar, radius of aperture [m].
%
% Outputs:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
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

  area  = pi * radius^2;
  alpha_ezz = 4 * radius^3 / 3;
  alpha_mxx = 2 * alpha_ezz;
  alpha_myy = alpha_mxx;

end %function
