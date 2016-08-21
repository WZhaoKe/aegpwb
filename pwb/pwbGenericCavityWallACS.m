function [ ACS , AE ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r )
%
% pwbGenericCavityWallACS - Determine ACS and AE of walls of generic cavity.
%
% [ ACS , AE ] = pwbGenericCavityWallACS( f , area , volume , sigma , mu_r )
%
% Inputs:
%
% f      - real vector, frequencies [Hz].
% area   - real scalar, area of cavity walls [m^2].
% volume - real scalar, volume of cavity walls [m^3].
% sigma  - real scalar, electrical conductivity of cavity wall material [S/m].
% mu_ r  - real scalar, relative permeability of cavity wall material [-].
%
% Outputs:
%
% ACS - real vector, average absorption cross-section of walls [m^2].
% AE  - real vector, average absorption efficiency of walls [m^2].
%

  c0 = 299792458;             
  mu0 = 4 * pi * 1e-7;
  
  if( isinf( sigma ) )
    ACS = zeros( size( f ) );
    AE = zeros( size( f ) );
  else
    ACS = 4.0 * area ./ ( 3.0 * c0 ) .* sqrt( pi .* mu_r .* f ./ sigma ./ mu0 ) .* ( 1.0 + 3.0 * c0 * area / 32.0 / volume ./ f ) ;
    AE = 4.0 .* ACS ./ area;
  end % if

end % function
