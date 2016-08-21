function [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureRectangularPol2( side_x , side_y )
%
% pwbsApertureRectangularPol2 - Polarisabilities of rectangular aperture.
%
% [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureRectangularPol2( side_x , side_y )
%
% Inputs:
%
% side_x - side side_x along x direction [m].
% side_y - side side_x along y direction [m].
%
% Output:
%
% area      - real scalar, aperture area [m^2].
% alpha_mxx - real scalar, tangnetial magnetic polarisability along x direction [m^3].
% alpha_myy - real scalar, tangnetial magnetic polarisability along y direction [m^3].
% alpha_ezz - real scalar, normal electric polarisability along z direction [m^3].
%

  area  = side_x * side_y;
  aspect = side_y / side_x;

  if( aspect <= 1 )
    alpha_mxx = side_x^3 * 0.132 / log( 1 + 0.660 / aspect );
    alpha_myy = side_x^3 * pi / 16 * aspect^2 * ( 1 + 0.3221 * aspect );    
    alpha_ezz   = side_x^3 * pi / 16 * aspect^2 * ( 1 - 0.5663 * aspect + 0.1398 * aspect^2 );
  else
    aspect = 1 / aspect;
    side_x = side_y;
    alpha_mxx = side_x^3 * pi / 16 * aspect^2 * ( 1 + 0.3221 * aspect );   
    alpha_myy = side_x^3 * 0.132 / log( 1 + 0.660 / aspect );
    alpha_ezz   = side_x^3 * pi / 16 * aspect^2 * ( 1 - 0.5663 * aspect + 0.1398 * aspect^2 );
  end %if

end %function
