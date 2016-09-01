function [ Gamma_TE , Gamma_TM , Z_TE , Z_TM ] = emMultiRefG( f , theta , thicknesses , eps_r , sigma , mu_r , sigmam )
%
% emMultiRefG - Reflection ceofficient and wave impedance of an isotropic laminated 
%               surface at  oblique incidence.
%
% [ Gamma_TE , Gamma_TM , Z_TE , Z_TM ] = emMultiRefG( f , theta , thicknesses , eps_r , sigma , mu_r , sigmam )
%
%
%          \  |   |   |       |          |
%     theta \ |   |   |       |          |
%        ___(\| 1 | 2 | ..... | numLayer |   -> oo 
%            /|   |   |       |          |
%           / |   |   |       |          |
%          /  |   |   |       |          |
%
%          1    2   3   .....  numLayer+1  numLayer+2    
%               
% Inputs:
%
% f           - vector (numFreq) of required frequencies [Hz].
% theta       - angle of incidence [degrees].
% thicknesses - vector (numLayer) of layer thicknesses [m].
% eps_r       - array (numFreq x (numLayer+2)) of relative permittivities [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigma       - array (numFreq x (numLayer+2)) of electrical conductivities [S/m].
%               If first dimension is 1 assumed same for all frequencies.
% mu_r        - array (numFreq x (numLayer+2)) of relative permeabilities [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigmam      - array (numFreq x (numLayer+2)) of magnetic conductivities [ohm/m].
%               If first dimension is 1 assumed same for all frequencies.
%
% Outputs:
%
% Gamma_TE - complex vector, overall TE reflection coefficent at interface [-].
% Gamma_TM - complex vector, overall TM reflection coefficent at interface [-].
% Z_TE     - complex vector, TE wave  impedance at the left interface in units of eta_a (left medium) [-].
% Z_TM     - complex vector, TE wave  impedance at the left interface in units of eta_a (left medium) [-].
%

  j = sqrt( -1 );

  % Constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  % Get number of layers and verify input arrays.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses );
 
  % Check and expand material parameters.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer + 2 , 'eps_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer + 2 , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer + 2 , 'mu_r' );
  [ sigmam ] = expandMaterialArray( sigmam , numFreq , numLayer + 2 , 'sigmam' );
     
  % Absolute permittivity and permeability.
  eps = eps0 .* eps_r;
  mu = mu0 .* mu_r;

  % Convert angle of incidence and layer rotations to radians.
  theta = theta * pi / 180.0;

  % Arrays for results.
  Gamma_TE = zeros( size( f ) );
  Gamma_TM = zeros( size( f ) );
  Z_TE = zeros( size( f ) );
  Z_TM = zeros( size( f ) );

  % Recurse through frequencies.
  for freqIdx=1:length( f )
    
    % Angular frequency.
    w = 2.0 * pi * f(freqIdx);
    
    % Free space wave number in layer a.
    k_a = w * sqrt( mu(freqIdx,1) * eps(freqIdx,1) );

    % Complex permittivity
    epsc = eps(freqIdx,:) - j .* sigma(freqIdx,:) ./ w;
    
    % Complex permeability
    muc = mu(freqIdx,:) - j .* sigmam(freqIdx,:) ./ w;
    
    % x component of wave  vector - same in all layers.
    kx = k_a * sin( theta );

    % Propagation constant and characteristic impedances for all layers.
    kz = sqrt( w .* w .* epsc .* muc - kx .* kx .* ones( size( epsc ) ) );

    % Intrinsic impedances.
    eta_TM = kz ./ ( w .* epsc );
    eta_TE = w .* muc ./ kz;

    % Optical thickness for all layers.
    if( numLayer > 0 )
      delta = kz(2:numLayer+1) .* thicknesses;
    end % if

    % Interfacial reflection coefficients (numLayer+1). 
    rho_TE = diff( eta_TE ) ./ ( diff( eta_TE ) + 2.0 * eta_TE(1:numLayer+1) );
    rho_TM = diff( eta_TM ) ./ ( diff( eta_TM ) + 2.0 * eta_TM(1:numLayer+1) );

    % Initialize overall reflection coefficient at right-most interface.
    GammaTE = rho_TE(numLayer+1);
    GammaTM = rho_TM(numLayer+1);

    % Recurse back through layers.
    for layerIdx = numLayer:-1:1
      z = exp( -2.0 * 1j * delta(layerIdx) );                          
      GammaTE = ( rho_TE(layerIdx) + GammaTE .* z ) ./ ( 1.0 + rho_TE(layerIdx) * GammaTE .* z );
      GammaTM = ( rho_TM(layerIdx) + GammaTM .* z ) ./ ( 1.0 + rho_TM(layerIdx) * GammaTM .* z );
    end % for

    Gamma_TE(freqIdx) = GammaTE;
    Gamma_TM(freqIdx) = GammaTM;
    Z_TE(freqIdx) = ( 1.0 + GammaTE ) ./ ( 1.0 - GammaTE );
    Z_TM(freqIdx) = ( 1.0 + GammaTM ) ./ ( 1.0 - GammaTM );

  end % for
 
end % function
