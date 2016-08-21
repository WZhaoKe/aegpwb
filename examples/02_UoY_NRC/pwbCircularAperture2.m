function [ acs , fc ] = pwbCircularAperture2( f , radius )
%
% pwbCircularAperture - circular aperture absorption/transmission 
%                       cross-section.
%
% [ acs ] = pwbCircularAperture( f , radius )
%
% Inputs:
%
% f         - vector of frequencies [Hz].
% radius    - radius of aperture [m]
%
% Outputs:
%
% acs       - absorption cross-section (m^2)
%

  [ c0 , eps0 , mu0 , eta0 ] = emConst();

  area = pi * radius^2;
  a_e = 4 * radius^3 / 3;
  a_mxx = 2 * a_e;
  a_myy = a_mxx;

  C = 2 * ( 2 * pi / c0 )^4 / 9 / pi * ( a_e^2 + a_mxx^2 + a_myy^2 );
  fc = c0 / 2 / pi * ( ( 9 * pi * area ) / ( 8 * ( a_e^2 + a_mxx^2 + a_myy^2 ) ) )^0.25;
  tcsInf = area / 4;

  acs = ( f < fc ) .* C .* f.^4 + ( f >= fc ) .* tcsInf;
 
end %function
