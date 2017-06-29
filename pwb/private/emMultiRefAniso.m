function [ MM ] = emMultiRefAniso( f , theta_i , thicknesses , alpha , ...
                                   eps_ra , eps_rb , eps_r , sigma , mu_r , param )
%
% [ MM ] = emMultiRefAniso( f , theta_i , thicknesses , alpha , ...
%                           eps_ra , eps_rb , eps_r , sigma , mu_r , param )
%
% Calculates the overall plane-wave transmission and reflection parameters 
% of a frequency dependent anisotropic (biaxial) laminated medium with numLayer
% layers medium at oblique incidence. The laminate layers are parallel to the 
% x-y plane and the plane of incidence is the x-z plane.   
%
% Geometry of laminate:
%
%   x                                                       y
%   ^                  |     |     | ... |     |            ^
%   |                \ |     |     | ... |     |      y_i   |      x_i
%   |            _____\|     |     | ... |     |         \  |    /
%   |        theta_i( /| l_1 | l_2 | ... | l_M |          \ |  /
%   |                / |     |     | ... |     |           \|/) alpha_i
% y o----> z        /  |     |     | ... |     |            o-------> x
%  
%        Interface     1     2     3     M    M+1  
%        Medium      a    1     2           M     b        M = numLayer
%
% Each layer is described by a biaxial complex permittivity tensor of the form 
% 
%          | eps_rx     0      0   |           | sigma_x    0       0    |
% epsc_r = |    0    eps_ry    0   |   sigma = |    0    sigma_y    0    |
%          |    0       0   eps_rz |           |    0       0    sigma_z |
%
% and an isotropic relative permeability tensor 
%
%        | mu_0   0    0  |
% mu_r = |  0   mu_0   0  |
%        |  0     0  mu_0 |
%
% relative to the principal axes of the layer. The principal axes of each layer
% are aligned at angle alpha_i to the global coordinate system as shown above.
% alpha_i is measured postive away from the x-axis towards to y-axis of the global
% coordinate system. 
%
% Inputs:
%
% f           - real vector (numFreq): Required frequencies [Hz].
% theta_i     - real scalar: Angle of incidence [degrees].
% thicknesses - real vector (numLayer): Layer thicknesses, [ l_1, ... , l_numLayer ] [m].
% alpha       - real vector (numLayer): Angles between the principal axes of each 
%               layer and the global axes [degrees].
% eps_ra      - real scalar: Relative permittivity of the lossless left medium [-].
% eps_rb      - real scalar: Relative permittivity of the lossless right medium [-].

% eps_r       - complex array (j=1,...numFreq;i=1,...,numLayer;k=x,y,z): Relative permittivity tensors [-].
%               If the first dimension is 1, assumed to be the same for all frequencies.
%               If the third dimension is 1, assumed to be isotropic with eps_rz = eps_ry = eps_rx.
%               If the third dimension is 2, assumed to be uniaxial with eps_rz = eps_ry.
% sigma       - real array (j=1,...numFreq;i=1,...,numLayer;k=x,y,z): Conductivity tensors [S/m].
%               If the second dimension is 1, assumed to be the same for all frequencies.
%               If the third dimension is 1, assumed to be isotropic with sig_z = sig_y = sig_x.
%               If the third dimension is 2, assumed to be uniaxial with sig_z = sig_y.
% mu_r        - real array (j=1,...numFreq;i=1,...,numLayer): Relative permeability tensors [-].
%               If the second dimension is 1, assumed to be the same for all frequencies.
%               Isotropic only at the moment.
% param       - character: Required output format:
%
%               'V' generalised chain matrix [mixed]
%               'S' scattering matrix [-]
%               'Z' impedance matrix [ohms]
%               'Y' admittance matrix [mhos]
%
% Outputs:
%
% MM(i,j,k) - complex array (i=1,.,4;j=1,..,4;k=1,..,numFreq): 4-port parameters
%             of type determined by 'param' above. The ports are ordered according to:
%
%             Port 1: left side (a), TM mode.
%             Port 2: right side (b), TM mode.
%             Port 3: left side (a), TE mode.
%             Port 4: right side (b), TE mode.    
%
%             So for example the impedance matrix is:
%
%             | E^a_TM |   | Z11 Z12 Z13 Z14 | | H^a_TM |
%             | E^b_TM | = | Z21 Z22 Z23 Z24 | | H^b_TM |
%             | E^a_TE |   | Z31 Z32 Z33 Z34 | | H^a_TE |
%             | E^b_TE |   | Z41 Z42 Z43 Z44 | | H^b_TE |
%
% I. D. Flintoft
%
% Changelog:
%
% 2005.??.?? Initial version
% 2011.01.10 Changed interface to allow frequency dependent parameters.
%
% Notes:
%
% 1. The algorithm may not be numerically robust for very low transmission layers.
%
% 2. The algorithm is not well vectorised and is somewhat inefficient.
%
% 3. Much more validation and testing is needed.
%

  % Constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  
  tol = 100 * eps;

  % Permutation matrix.
  Ppi2 = [ 1 , 0 , 0 , 0 ; ...
           0 , 0 , 1 , 0 ; ...
           0 , 1 , 0 , 0 ; ...
           0 , 0 , 0 , 1 ];

  % Zero angle "rotation" matrix  
  T0 = [ 1 , 0 ,  0 , 0 ; ...
         0 , 0 ,  0 , 1 ; ...
         0 , 1 ,  0 , 0 ; ...
         0 , 0 , -1 , 0 ];

  % Get number of layers and verify input arrays.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses );

  % Check layer axis angles.
  if ( length( alpha ) ~= numLayer )
    if ( length( alpha ) == 1 )
      alpha = alpha .* ones( 1 , numLayer );
    else
      error( 'length of alpha must 1 or the same as the number of layers' );
    end %if
  end %if

  % Check and expand the material arrays.
  [ eps_r ] = expandMaterialArrayAniso( eps_r , numFreq , numLayer , 'eps_r' );
  [ sigma ] = expandMaterialArrayAniso( sigma , numFreq , numLayer , 'sigma' );  
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );  

  % Characteristics of left and right semi-infinite half spaces - lossless.
  eps_a = eps_ra * eps0;
  eps_b = eps_rb * eps0;
  mu_a = mu0;
  mu_b = mu0;
  eta_a = sqrt( mu0 / eps_a );
  eta_b = sqrt( mu0 / eps_b );

  % Absolute permittivites and permeabilities of layers.
  epsc = eps0 .* eps_r;

  if( any ( any( any(  abs( mu_r - 1.0 ) > tol ) ) ) )
    error( 'magnetic materials not supported yet!' );
  end %if

  mu = mu0 .* mu_r;

  % Convert angle of incidence and layer rotations to radians.
  theta_i = theta_i * pi / 180.0;
  alpha = alpha .* pi ./ 180.0;

  % Difficult to vectorise so not very efficient.
  for freqIdx = 1:numFreq

    % Angular frequency.
    w = 2.0 * pi * f(freqIdx);

    % Free space wave number in layer a, b.
    k_a = w * sqrt( mu_a * eps_a );
    k_b = w * sqrt( mu_b * eps_b );

    % x component of wave  vector - same in all layers.
    kx = k_a * sin( theta_i );

    % Complex permittivities for all layers.
    epscx = epsc(freqIdx,:,1) - j .* sigma(freqIdx,:,1) ./ w;
    epscy = epsc(freqIdx,:,2) - j .* sigma(freqIdx,:,2) ./ w;
    epscz = epsc(freqIdx,:,3) - j .* sigma(freqIdx,:,3) ./ w;

    % Propagation constant and characteristic impedances for all layers.
    kz_TM = sqrt(  epscx .* ( w .* w .* mu(freqIdx,:) - kx .* kx ./  epscz ) );
    Zc_TM = kz_TM ./ ( w .* epscx );
    kz_TE = sqrt( w .* w .* mu(freqIdx,:) .* epscy - kx .* kx );
    Zc_TE = w .* mu(freqIdx,:) ./ kz_TE;

    % Running product of chain matrix and rotations through layers.
    V = T0;
    for layerIdx = 1:numLayer

      % Propagation matrices for layer.
      kl_TM = kz_TM(layerIdx) * thicknesses(layerIdx);
      Pi_TM = [ cos( -kl_TM ) , -j * Zc_TM(layerIdx) * sin( -kl_TM ) ; -j / Zc_TM(layerIdx) * sin( -kl_TM ) , cos( -kl_TM ) ];
      kl_TE = kz_TE(layerIdx) * thicknesses(layerIdx);
      Pi_TE = [ cos( -kl_TE ) , -j * Zc_TE(layerIdx) * sin( -kl_TE ) ; -j / Zc_TE(layerIdx) * sin( -kl_TE ) , cos( -kl_TE ) ];
      Pi = [ Pi_TM , zeros(2) ; zeros(2) , Pi_TE ];

      % Rotation matrix to princpal axis system of layer.
      ca = cos( alpha(layerIdx) );
      sa = sin( alpha(layerIdx) );
      T = [  ca , sa , 0   , 0   ; ...
              0 , 0  , -sa , ca  ; ...
            -sa , ca , 0   , 0   ; ...
              0 ,  0 , -ca , -sa ];

      % Running product.
      V = V * inv( T ) * Pi * T;

    end % for
    V = V * inv( T0 ) ;

    %
    % Direct calculation of S matrix
    %
    kz_a = sqrt( k_a * k_a - kx * kx );
    kz_b = sqrt( k_b * k_b - kx * kx );
    eta_TM_a = kz_a / (w * eps_a );
    eta_TM_b = kz_b / (w * eps_b );
    eta_TE_a = w * mu_a / kz_a;
    eta_TE_b = w * mu_b / kz_b;

    % Matching matrices on external faces.
    P_na = [ 1          , 1           , 0          , 0           ; ...
             1/eta_TM_a , -1/eta_TM_a , 0          , 0           ; ...
             0          , 0           , 1          , 1           ; ...
             0          , 0           , 1/eta_TE_a , -1/eta_TE_a ];
    P_nb = [ 1          , 1           , 0          , 0           ; ...
             1/eta_TM_b , -1/eta_TM_b , 0          , 0           ; ...
             0          , 0           , 1          , 1           ; ...
             0          , 0           , 1/eta_TE_b , -1/eta_TE_b ];

    PP = Ppi2 * inv( P_na ) * V * P_nb * Ppi2;

    PPA = PP(1:2,1:2);
    PPB = PP(1:2,3:4);
    PPC = PP(3:4,1:2);
    PPD = PP(3:4,3:4);
    SC = inv( PPA );
    SD = -SC * PPB;
    SA = PPC * SC;
    SB = PPD - PPC * SC * PPB;
    Sdirect = Ppi2 * [ SA , SB ; SC , SD ] * Ppi2;

    %
    % Calculate impedance matrix.
    % 

    % Permutute so sides of laminate blocked.
    V2 = Ppi2 * V * Ppi2;

    % Submatrices of overall global propagation matrix.
    PA = V2(1:2,1:2);
    PB = V2(1:2,3:4);
    PC = V2(3:4,1:2);
    PD = V2(3:4,3:4);

    % Convert to impedance matrix.
    ZC = inv( PC );
    ZD = ZC * PD;
    ZA = PA * ZC;
    ZB = ZA * PD - PB;
    Z = [ ZA , ZB ; ZC , ZD ];

    % Reorder so TE and TM modes blocked.
    Z = Ppi2 * Z * Ppi2;

    % Convert impedance matrix to scattering matrix.
    % Z0 = diag( [ eta_TM_a , eta_TM_b , eta_TE_a , eta_TE_b ] );
    % S = ( Z - Z0 ) * inv( Z + Z0 );

    % Check both calculations of scattering matrix agree.
    % assert( all( all( abs( S - Sdirect ) < 1e-4 ) ) );

    % The scattering matrix as defnied here is not symmetric if the 
    % port reference impedances are different!
    % if( abs( eps_ra - eps_rb ) < 1e-10 ) 
    %   if( nportIsSymmetric( Sdirect ) ~= 1 )
    %     warning( 'Warning: scattering matrix is not symmetric!' );
    %   end %if
    % end %if

    % The impedance matrix should always be symmetric. Failure here is probably
    % due to numerical errors.
    % if( nportIsSymmetric( Z ) ~= 1 )
    %   warning( 'Warning: impedance matrix is not symmetric at %9.2e MHz - maybe numerical errors!' , f(freqIdx) / 1e6 );
    % end %if

    % Return required parameters.
    switch param
     case 'V'
      MM(1:4,1:4,freqIdx) = V;
     case 'S'
      MM(1:4,1:4,freqIdx) = Sdirect;
     case 'Z'
      MM(1:4,1:4,freqIdx) = Z;
     case 'Y'
      MM(1:4,1:4,freqIdx) = inv( Z );
     otherwise
      error( 'unknown parametisation' );
    end % switch

  end % for

end % function

