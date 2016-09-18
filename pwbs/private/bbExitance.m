function [ exitance ] = bbExitance( T , f )
% bbExitance - spectral exitance of black body
%
% [ exitance ] = bbExitance( T , f )
%
% Inputs:
%
% T - real scalar, temperature [K].
% f - real vector, frequency [Hz].
%
% Outputs:
%
% exitance - real vector, spectral exitance [W/m^2/Hz]
%

  k = 1.38064852e-23;
  h = 6.62607004e-34;
  c0 = 299792458;
  
  exitance = 2.0 .* pi .* h .* f.^3 ./ c0.^2 ./ ( exp( h .* f ./ k ./ T ) - 1.0 );

end % function
