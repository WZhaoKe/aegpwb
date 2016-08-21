function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , b_y )
%
% pwbsApertureEllipticalPol - Polarisabilities of elliptical aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , b_y )
%
% Inputs:
%
% a_x - semi-axis along x direction [m].
% a_y - semi-axis along y direction [m].
%
% Output:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%

  area  = pi * b_y * a_x;
  aspect = b_y / a_x;
  eccentricity = sqrt( 1 - aspect^2 );

  [ K , E ] = ellipke( eccentricity^2 );

  alpha_ezz = pi / 3.0 * a_x * b_y^2 / E;
  alpha_mxx = pi / 3.0 * a_x^3 * eccentricity^2 / ( K - E );
  alpha_myy = pi / 3.0 * a_x^3 * eccentricity^2 / ( ( 1.0 / aspect )^2 * E - K );

end %function
