function [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )
%
% pwbMetalSurface - absorption cross-section of metal surface.
%
% [ ACS , AE ] = pwbMetalSurface( f , area , sigma , mu_r )
%
% Parameters:
%
% f         - real vector of frequencies [Hz].
% area      - real scalar, total area of surface [m^2]
% sigma     - real vector, conductivity of surface [S/m]
% mu_r      - real vector, relative permeability of surface [-]
%
% sigma and mu_r must be scalars or the same length as f.
%
% Outputs:
%
% ACS       - real vector, absorption cross-section [m^2].
% AE        - real vector, absorption efficiency [-].
%

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             

  validateattributes( f , { 'double' } , { 'real' , 'vector' , 'positive' , 'increasing' } , 'pwbMetalSurface' , 'f' , 1 );
  validateattributes( area , { 'double' } , { 'real' , 'scalar' , 'positive' } , 'pwbMetalSurface' , 'area' , 2 ); 
  validateattributes( sigma , { 'double' } , { 'real' , 'vector' , 'nonnegative' } , 'pwbMetalSurface' , 'sigma' , 3 );
  validateattributes( mu_r , { 'double' } , { 'real' , 'vector' , '>=' , 1.0 } , 'pwbMetalSurface' , 'mu_r' , 4 );
  
  if( length( sigma ) ~= 1 && length( sigma ) ~= length( f ) )
    error( 'sigma must be a scalar or the same size as f' );
  end % if
  if( length( mu_r ) ~= 1 && length( mu_r ) ~= length( f ) )
    error( 'mu_r must be a scalar or the same size as f' );
  end % if

  ACS = 4.0 * area / ( 3.0 * c0 ) .* sqrt( pi .* mu_r .* f ./ sigma ./ mu0 );
  AE = 4.0 .* ACS ./ area;

end %function
