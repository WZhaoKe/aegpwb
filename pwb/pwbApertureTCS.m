function [ TCS , TE , f_c ] = pwbApertureTCS( f , area  , alpha_mxx , alpha_myy , alpha_ezz )
%
% pwbsApertureTCS - Average transmission cross-section of aperture.
%
% [ TCS , TE , f_c ] = pwbApertureTCS( f , area , alpha_mxx , alpha_myy , alpha_ezz )
%
% Note: TCS and TE follow convention of including factor of half from half-space illumination.
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

  c0 = 299792458;
  w = 2.0 .* pi .* f;
  k = w ./ c0;

  f_c = c0 / 2.0 / pi * ( ( 9.0 * pi * area ) / ( 8.0 * ( alpha_ezz^2 + alpha_mxx^2 + alpha_myy^2 ) ) )^0.25;  
  TCS_LF = 2.0 .* k.^4.0 ./ 9.0 ./ pi .* ( alpha_ezz^2 + alpha_mxx^2 + alpha_myy^2 );
  TCS_HF = area ./ 4.0;

  TCS = ( f < f_c ) .* TCS_LF + ( f >= f_c ) .* TCS_HF;  
  TE = 4.0 .* TCS ./ area;

end %function
