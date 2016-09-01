function [ ACS1 , ACS2 , TCS , AE1 , AE2 , TE ] = pwbLucentWall( f , area , thicknesses , eps_r , sigma , mu_r )
%
% pwbLucentWall - translucent multilayer wall.
%
% [ ACS1 , ACS2 , TCS , AE1 , AE2 , TE ] = pwbLucentWall( f , area , thicknesses , eps_r , sigma , mu_r )
%
%             |   |   |       |          |
%             |   |   |       |          |
%  cavity 1   | 1 | 2 | ..... | numLayer |  cavity 2
%             |   |   |       |          |
%  eps0 , mu0 |   |   |       |          | eps0 , mu0
%             |   |   |       |          |
%
% Parameters:
%
% f           - vector (numFreq) of required frequencies [Hz].
% area        - real scalar, area of surface [m^2].
% thicknesses - vector (numLayer) of layer thicknesses [m].
% eps_r       - array (numFreq x numLayer) of relative permittivities [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigma       - array (numFreq x numLayer) of electrical conductivities [S/m].
%               If first dimension is 1 assumed same for all frequencies.
% mu_r        - array (numFreq x numLayer) of relative permeabilities [-].
%               If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS1 - average absorption cross-section of side 1 [m^2].
% ACS2 - average absorption cross-section of side 2 [m^2].
% TCS  - average transmission cross-section [m^2].
% AE1  - average absorption efficiency of side 1 [-].
% AE2  - average absorption efficiency of side 2 [-].
% TE   - average transmission efficiency [-].
%
  
  % Get number of frequencies and layers.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses );
  
  % Check and expand material arrays.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer , 'epsc_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );
 
  % Integrate over angles of incidence.
  thetas = linspace( 0 , pi / 2 - 1e-4 , 801 );
  dtheta = thetas(2) - thetas(1);
  RE1 = zeros( size( f ) );
  RE2 = zeros( size( f ) );
  TE = zeros( size( f ) );
     
  for idx = 1:length( thetas )
    theta = thetas(idx);
    [ S ] = emMultiRefAniso( f , 180.0 * theta / pi  , thicknesses , [ 0.0 ] , 1.0 , 1.0 , eps_r , sigma , mu_r , 'S' );
    rhoTM1 = squeeze( S(1,1,:) ); 
    rhoTE1 = squeeze( S(3,3,:) );
    rhoTM2 = squeeze( S(2,2,:) ); 
    rhoTE2 = squeeze( S(4,4,:) );
    tauTM  = squeeze( S(2,1,:) ); 
    tauTE  = squeeze( S(4,3,:) );
    costhetasintheta = cos( theta ) .* sin( theta );
    RE1 = RE1 + 2.0 .* ( 0.5 .* ( abs( rhoTE1 ).^2 + abs( rhoTM1 ).^2 ) ) .* costhetasintheta;
    RE2 = RE2 + 2.0 .* ( 0.5 .* ( abs( rhoTE2 ).^2 + abs( rhoTM2 ).^2 ) ) .* costhetasintheta;
    TE  = TE  + 2.0 .* ( 0.5 .* ( abs( tauTE ).^2  + abs( tauTM ).^2 )  )  .* costhetasintheta;
  end % for
  
  RE1 = RE1 .* dtheta;
  RE2 = RE2 .* dtheta;
  TE = TE .* dtheta;
  
  % Effective absorption efficiencies.
  AE1 = 1.0 - RE1;
  AE2 = 1.0 - RE2;
  
  % Cross-sections.
  G = 0.25 * area;
  ACS1 = G .* AE1;
  ACS2 = G .* AE2;
  TCS = G .* TE;
 
end %function
