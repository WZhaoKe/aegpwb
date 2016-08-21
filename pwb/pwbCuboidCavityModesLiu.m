function [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesLiu( f , a , b , c )
%
% pwbCuboidCavityModesLiu - Liu correction to the Weyl continuum limit estimate of cavity 
%                           modes in a cuboid cavity.
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesLiu( f , a , b , c )
%
% Inputs:
%
% f       - real vector, frequency (Hz).
% a, b, c - real scalars, cavity linear dimensions [m].
%
% Outputs:
%
% numModes    - integer vector, cumulative number of modes below frequencies in f [-].
% modeDensity - real vector, density of modes at frequencies in f [/Hz]. 
% f_1         - real scalar, frequency at which numModes is greater than or equal to 1 [Hz].
% f_60        - real scalar, frequency at which numModes is greater than or equal to 60 [Hz].
% 
% References:
%
% [1] B. H. Liu, D. C. Chang, and M. T. Ma [1983], “Eigenmodes and the Composite Quality 
%     Factor of a Reverberation Chamber,” NBS Technical Note 1066, National Institute 
%     of Standards and Technology, Boulder, Colorado 80303-3328, USA.
%

  c0 = 299792458;
  
  volume = a * b * c;

  numModes = 8 * pi * volume * f.^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0; 
  modeDensity = 8 * pi * volume * f.^2 / c0^3 - ( a + b + c ) / c0;

  % Estimate mode frequencies using basic Weyl formula.
  f_1_est = ( 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3);
  f_60_est = ( 60.0 * 3.0 * c0^3 / ( 8.0 * pi * volume ) )^(1/3); 
  
  % Solve nonlinear equations to improve esitmate.
  fcn1=@(f) 8 * pi * volume * f^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0 - 1;
  fcn60=@(f) 8 * pi * volume * f^3 / 3.0 / c0^3 - ( a + b + c ) * f / c0 - 60;
  f_1 = fzero( fcn1 , f_1_est );
  f_60 = fzero( fcn60 , f_60_est );
    
  % Set to zero if below first mode.
  idx1 = find( f < f_1 );
  numModes(idx1) = 0;
  modeDensity(idx1) = 0;

end %function
