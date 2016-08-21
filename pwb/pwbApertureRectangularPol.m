function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureRectangularPol( side_x , side_y )
%
% pwbsApertureRectangularPol - Polarisabilities of rectangular aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureRectangularPol( side_x , side_y )
%
% Inputs:
%
% side_x - side length along x direction [m].
% side_y - side length along y direction [m].
%
% Output:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%

  area = side_x * side_y;
  aspect = side_x / side_y;
  a_x = sqrt( area * aspect / pi );
  b_x = sqrt( area / aspect / pi );
  [ ~ , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , b_y );

end %function
