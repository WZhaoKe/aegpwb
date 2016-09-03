function [ ACS , AE ] = pwbDielectricSurface( f , area , epsc_r , sigma , mu_r )
%
% pwbDielectricSurface - lossy dielectric surface absorption cross-section.
%
% [ ACS , AE ] = pwbDielectricSurface( f , area , eps_r , sigma , mu_r )
%
% Parameters:
%
% f         - real vector of frequencies [Hz].
% area      - real scalar, total area of surface [m^2]
% epsc_r    - complex vector, complex relative permittivity [-].
% sigma     - real vector, conductivity of surface [S/m]
% mu_r      - real vector, relative permeability of surface [-]
%
% epsc_r, sigma and mu_r must be scalars or the same length as f.
%
% Outputs:
%
% ACS       - real vector, absorption cross-section [m^2].
% AE        - real vector, absorption efficiency [-].
%

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  function [ kernel ] = pwbDielectricSurfaceKernel( theta , n_a , n_b )

    [ rhoTE , rhoTM , tauTE , tauTM ] = emFresnelCoeff( n_a , n_b , theta );
    kernel = ( 1 - 0.5 .* ( abs( rhoTE ).^2 + abs( rhoTM ).^2 ) ) .* cos( theta ) .* sin( theta );

  end %function

  validateattributes( f , { 'double' } , { 'real' , 'vector' , 'positive' , 'increasing' } , 'pwbDielectricSurface' , 'f' , 1 );
  validateattributes( area , { 'double' } , { 'real' , 'scalar' , 'positive' } , 'pwbDielectricSurface' , 'area' , 2 ); 
  validateattributes( epsc_r , { 'double' } , { } , 'pwbDielectricSurface' , 'epsc_r' , 3 );
  validateattributes( sigma , { 'double' } , { 'real' , 'vector' , 'nonnegative' } , 'pwbDielectricSurface' , 'sigma' , 4 );
  validateattributes( mu_r , { 'double' } , { 'real' , 'vector' , '>=' , 1.0 } , 'pwbDielectricSurface' , 'mu_r' , 5 );
  
  if( length( epsc_r ) ~= 1 && length( epsc_r ) ~= length( f ) )
    error( 'epsc_r must be a scalar or the same size as f' );
  end % if
  if( length( sigma ) ~= 1 && length( sigma ) ~= length( f ) )
    error( 'sigma must be a scalar or the same size as f' );
  end % if
  if( length( mu_r ) ~= 1 && length( mu_r ) ~= length( f ) )
    error( 'mu_r must be a scalar or the same size as f' );
  end % if

  % Complex relative permittivity.
  epsc_r = epsc_r + sigma ./ ( j .* 2 .* pi .* f .* eps0 );

  % Refractive indicies of left and right media.
  n_a = 1.0;
  n_b = sqrt( epsc_r .* mu_r );

  ACS = zeros( size( f ) );
  for freqIdx=1:length( f )
    ACS(freqIdx) = 0.5 * area * quad( @(theta) pwbDielectricSurfaceKernel( theta , n_a , n_b(freqIdx) ) , 0.0 , pi / 2 );
  end %for
  AE = 4.0 .* ACS ./ area;

end %function
