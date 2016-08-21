function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius )
%
% pwbsApertureCircularPol - Polarisabilities of circular aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius )
%
% Inputs:
%
% radius - real scalar, radiius of aperture.
%
% Output:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%

  area  = pi * radius^2;
  alpha_ezz = 4 * radius^3 / 3;
  alpha_mxx = 2 * alpha_ezz;
  alpha_myy = alpha_mxx;

end %function
