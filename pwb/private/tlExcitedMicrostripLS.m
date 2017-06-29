function [ V_0 , V_l ] = tlExcitedMicrostripLS( f , h , l , eps_r , Z_c , eps_r_eff , Z_0 , Z_l , E_0 , theta , phi , gamma )
%tlExcitedMicrostripLS - Calculate terminal voltages of microstrip line illuminated by
%                        a plane electromagnetic wave.
%
% Usage:
%
% [ V_0 , V_l ] = tlExcitedMicrostripLS( f , h , l , eps_r , Z_c , eps_r_eff , ...
%                                        Z_0 , Z_l , E_0 , theta , phi , gamma )
%
% Inputs:
% 
% f         - real vector, frequency [Hz].
% h         - real scalar, height of substrate [m].
% l         - real scalar, length of trace [m].
% eps_r     - real scalar or vector, relative permittivty of substrate [-].
% Z_c       - real scalar or vector, characteristic impedance of line [ohms]. 
% eps_r_eff - real scalar or vector, effective permittivity of line [-].
% Z_0       - complex scalar or vector, terminal impedance at end 0 [ohms].
% Z_l       - complex scalar or vector, terminal impedance at end l [ohms].
% E_0       - complex scalar or vector, amplitude of plane-wave [V/m].
% theta     - real scalar, angle of incidence [degrees].
% phi       - real scalar, plane of incidence [degrees].
% gamma     - real scalar, polarisation angle [degrees].
%
% Outputs:
%
% V_0 - real vector, terminal voltage at end 0 [V].
% V_l - real vector, terminal voltage at end l [V].
%
% Notes:
%
% 1. Implements the calculation given in [1].
%
% 2. External microstrip model must be used to consistently determine Z_c and eps_r_eff
%    from h, l and eps_r.
%
% 3. eps_r, Z_c, eps_r_eff, Z_0, Z_l and E_0 can be scalars or vectors with the same length as f. 
%
% References:
%
% [1] M. Leone and H. L. Singer, "On the coupling of an external electromagnetic field to a
%     printed circuit board trace", IEEE Transactions on Electromagnetic Compatibility,
%     vol. 41, no. 4, pp. 418-424 , November 1999.
%

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );

  % Angular frequency and free-space wave-number.
  w = 2.0 .* pi .* f;
  k_0 = w ./ c0;
  
  % Location of terminal planes.
  x_0 = 0.0;
  x_l = l;

  % Trignometirc functions for plane-wave angles.
  costheta = cosd( theta );  
  sintheta = sind( theta );
  cosphi = cosd( phi );
  sinphi = sind( phi );
  cosgamma = cosd( gamma );
  singamma = sind( gamma );

  % u_k = -e_r(r,theta,phi+180)
  cosphi180 = cosd( phi + 180 );
  sinphi180 = sind( phi + 180 );
  u_k_x = -sintheta * cosphi180;
  u_k_y = -sintheta * sinphi180;
  u_k_z = -costheta;
  %E_i = -cosgamma * e_theta(r,theta,phi+180) + singamma * e_phi(r,theta,phi+180)
  e_x = -cosgamma * costheta * cosphi180 - singamma * sinphi180;
  e_y = -cosgamma * costheta * sinphi180 + singamma * cosphi180;
  e_z =  cosgamma * sintheta;
  %fprintf( 'k: [%g,%g,%g]\n' , -u_k_x , -u_k_y , -u_k_z );
  %fprintf( 'E: [%g,%g,%g]\n' , e_x , e_y , e_z );

  % Interfacial reflection coefficients, eqn. (6).
  rho_0 = ( Z_0 - Z_c ) ./ ( Z_0 + Z_c );
  rho_l = ( Z_l - Z_c ) ./ ( Z_l + Z_c );
  
  % Line propagation constant, eqn. (7), and associated phase factors.
  beta = k_0 .* sqrt( eps_r_eff );
  bl = beta .* l;
  jb = 1j .* beta;
  jbl = 1j .* bl;
  expjbl = exp( jbl );
  exp2jbl = expjbl.^2;
  jbx0 = jb .* x_0;
  jbxl = jb .* x_l;
  expjbx0 = exp( jbx0 );
  expjbxl = exp( jbxl );

  % Wave vector componentseqns. (16) and (22), and associated phase factors.
  k_x = k_0 .* sintheta .* cosphi;
  k_2z = k_0 .* sqrt( eps_r - sintheta.^2 );
  jk2z = 1j .* k_2z;
  jpbmkx = 1j .* (  beta - k_x );
  jmbmkx = 1j .* ( -beta - k_x );
  expjpbmkxl = exp( jpbmkx .* l );
  expjmbmkxl = exp( jmbmkx .* l );  

  % Fresnel coefficients, eqns. (23) and (24).
  epsrcostheta = eps_r .* costheta;
  sqrtepsrsin2theta = sqrt( eps_r - sintheta.^2 );
  r_TE = ( costheta - sqrtepsrsin2theta ) ./ ( costheta + sqrtepsrsin2theta ); 
  r_TM = ( epsrcostheta - sqrtepsrsin2theta ) ./ ( epsrcostheta + sqrtepsrsin2theta ); 

  % Generalised Fresnel coefficients, eqn. (21).
  expm2jk2zh = exp( -2.0 .* jk2z .* h );
  R_TE = ( r_TE - expm2jk2zh ) ./ ( 1.0 - r_TE .* expm2jk2zh );
  R_TM = ( r_TM + expm2jk2zh ) ./ ( 1.0 + r_TM .* expm2jk2zh );

  % Horizontal and vertical field excitations, eqns (20) and (30). 
  f_x = costheta .* cosphi .* cosgamma .* ( 1.0 - R_TM ) + sinphi .* singamma .* ( 1.0 + R_TE );  
  f_z = sintheta .* cosgamma ./ eps_r .* ( 1.0 + r_TM ) ./ ( 1.0 + r_TM .* expm2jk2zh );

  % Overall excitation terms, eqn. (35).
  last_term = ( 1 - exp( -2.0 .* jk2z .* h ) ) ./ jk2z;
  S_1 =  0.5 .* E_0 .* expjbx0 .* ( expjpbmkxl - 1.0 ) ./ jpbmkx .* ( f_x - jpbmkx .* f_z .* last_term );
  S_2 = -0.5 .* E_0 .* expjbxl .* ( expjmbmkxl - 1.0 ) ./ jmbmkx .* ( f_x - jmbmkx .* f_z .* last_term );

  % Terminal voltages. eqn. (36).
  denom = exp2jbl - rho_0 .* rho_l;
  V_0 = ( 1.0 + rho_0 ) .* ( rho_l .* S_1 + expjbl .* S_2 ) ./ denom; 
  V_l = ( 1.0 + rho_l ) .* ( expjbl .* S_1 + rho_0 .* S_2 ) ./ denom; 

end % function
