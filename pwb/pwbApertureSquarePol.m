function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureSquarePol( side )
%
% pwbsApertureSquarePol - Polarisabilities of square aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureSquarePol( radius )
%
% Inputs:
%
% side - real scalar, side length of aperture.
%
% Output:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%

  area = side^2;
  radius = sqrt( area / pi );
  [ ~ , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius );

end %function
