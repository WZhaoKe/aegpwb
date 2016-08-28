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
  [ c0 , eps0 , mu0 , eta0 ] = emConst();
  
  % Get number of layers and verify input arrays.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses );

  % Check and expand the relative permittivity array.
  eps_numLayer  = size( eps_r , 2 );
  eps_numFreq = size( eps_r , 1 );

  if ( eps_numLayer ~= numLayer + 2 )
    error( 'second dimension of eps_r must be the same as the number of layers plus two' );
  end %if

  if ( eps_numFreq ~= numFreq )
    if( eps_numFreq == 1 )
      eps_r = repmat( eps_r , [ numFreq , 1 ] ); 
    else
      error( 'first dimension of eps_r must be 1 or the same as the number of frequencies' );
    end %if
  end %if

  assert( all( size( eps_r ) == [ numFreq , numLayer + 2 ] ) );

  % Check and expand the conductivity array.
  sigma_numLayer  = size( sigma , 2 );
  sigma_numFreq = size( sigma , 1 );

  if ( sigma_numLayer ~= numLayer + 2 )
    error( 'second dimension of sigma must be the same as the number of layers plus two' );
  end %if

  if ( sigma_numFreq ~= numFreq )
    if( sigma_numFreq == 1 )
      sigma = repmat( sigma , [ numFreq , 1 ] ); 
    else
      error( 'first dimension of sigma must be 1 or the same as the number of frequencies' );
    end %if
  end %if

  assert( all( size( sigma ) == [ numFreq , numLayer + 2 ] ) );

  % Check and  expand the relative permeability.
  mu_numLayer  = size( mu_r , 2 );
  mu_numFreq = size( mu_r , 1 );

  if ( mu_numLayer ~= numLayer + 2 )
    error( 'second dimension of mu_r must be the same as the number of layers plus two' );
  end %if

  if ( mu_numFreq ~= numFreq )
    if( mu_numFreq == 1 )
      mu_r = repmat( mu_r , [ numFreq , 1 ] ); 
    else
      error( 'first dimension of mu_r must be 1 or the same as the number of frequencies' );
    end %if
  end %if

  assert( all( size( mu_r ) == [ numFreq , numLayer + 2 ] ) );

  % Check and expand the conductivity array.
  sigmam_numLayer  = size( sigmam , 2 );
  sigmam_numFreq = size( sigmam , 1 );

  if ( sigmam_numLayer ~= numLayer + 2 )
    error( 'second dimension of sigmam must be the same as the number of layers plus two' );
  end %if

  if ( sigmam_numFreq ~= numFreq )
    if( sigmam_numFreq == 1 )
      sigmam = repmat( sigmam , [ numFreq , 1 ] ); 
    else
      error( 'first dimension of sigmam must be 1 or the same as the number of frequencies' );
    end %if
  end %if

  assert( all( size( sigmam ) == [ numFreq , numLayer + 2 ] ) );
  
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
