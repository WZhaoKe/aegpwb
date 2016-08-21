function [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesWeyl( f , volume )
%
% pwbGenericCavityModesWeyl - Weyl continuum limit estimate of cavity modes in  generic cavity.
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesWeyl( f , volume )
%
% Inputs:
%
% f      - real vector, frequency [Hz].
% volume - real scalar, cavity volume [m^3].
%
% Outputs:
%
% numNodes    - integer vector, number of modes below given frequency [-].
% modeDensity - real vector, density of modes [/Hz]. 
% f_1         - real scalar, lowest cavity resonant frequency [Hz].
% f_60        - real scalar, 60-th cavity resonant frequency [Hz].
%
  
  c0 = 299792458;

  % Weyl formula.
  numModes = 8 * pi * volume * f.^3 / 3.0 / c0^3; 
  modeDensity = 8 * pi * volume * f.^2 / c0^3;
  
  % Mode frequencies.
  f_1 = ( 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3);
  f_60 = ( 60.0 * 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3); 
  
  % Set to zero if below first mode.
  idx = find( f < f_1 );
  numModes(idx) = 0;
  modeDensity(idx) = 0;
  
end %function
