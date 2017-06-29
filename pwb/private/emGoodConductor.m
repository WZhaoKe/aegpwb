function [ gamma , eta , phaseVelocity , skinDepth ] = ...
    emGoodConductor( f , eps_r , mu_r , sigma )
%
% [ gamma , eta , phaseVelocity , skinDepth ] = ...
%          emGoodConductor( f , eps_r , mu_r , sigma )
%
% Calculate electromagnetic parameters of good conductor.
%
% Inputs:
%
% f     - vector of frequencies (Hz).
% eps_r - relative permittivity (-)
% mu_r  - relative permeability (-)
% sigma - electrical conductivity (S/m)
%
% Outputs:
%
% gamma         - complex propagation constant (/m)
% eta           - intrinsic impedance (ohms)
% phaseVelocity - phase velocity (m/s)
% delta         - skin depth (m)
%
% References:
%
% [1] C. A. Balanis, "Advanced Engineering Electromagnetics", 
%     John Wiley, 1989, pp. 151-154.
%

% I. D. Flintoft 27/04/2007.
  
  % Constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  eps = eps_r * eps0;
  mu = mu_r * mu0;
  w = 2 * pi * f;
  
  if sigma < 0
    error( 'conductivity negative or zero' );
  elseif sigma == 0
    error( 'zero conductivity invalid for good conductor' );
  elseif sigma == Inf
    gamma = Inf;
    eta = Inf;
    phaseVelocity = Inf;
    skinDepth = 0.0;
  else
    if( all( ( sigma ./ eps ./ w ).^2 >= 100 ) ~= 1 )
      warning( 'good conductor assumption poor for some frequencies' );
    end % if
    if( all( ( sigma ./ eps ./ w ).^2 >= 10 ) ~= 1 )
      warning( 'good conductor assumption invalid for some frequencies' );
    end % if
    alpha = sqrt( w * mu * sigma / 2.0 );
    beta = alpha;
    gamma = alpha + j * beta;
    eta = sqrt( w * mu / 2.0 / sigma ) * ( 1.0 + j ) ;
    phaseVelocity = w ./ beta;
    skinDepth = 1.0 ./ alpha;
  end % if
  
end % function
