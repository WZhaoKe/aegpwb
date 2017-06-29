function [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineZc( f , length , spacing , Z_c , eps_r , R_1 , R_2 )
%pwbTwoWireLineZc - Average absorption cross-section of a two-wire transmission line
%                   taking the characteristic impedance as a parameter.
%
% Usage:
%
% [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineZc( f , length , spacing , Z_c [ , eps_r  [ , R_1 [ , R_2 ] ] ] )
%
% Inputs:
%
% f        - real vector, frequency [Hz].
% length   - real scalar, length of line [m].
% spacing  - real scalar, separation of wires [m].
% Z_c      - real scalar, line impedance [ohms].
% eps_r    - real vector, relative permittivty of medium [-].
%            Defaults to unity.
% R_1      - real vector, load resistance at end one [ohms].
%            Defaults to line characteristic impedance.
% R_2      - real vector, load resistance at end two [ohms].
%            Defaults to line characteristic impedance.
%
% Outputs:
%
% ACS   - real vector, total average absorption cross-section [m^2].
% ACS_1 - real vector, average absorption cross-section into load one [m^2].
% ACS_2 - real vector, average absorption cross-section into load two [m^2].
%
% References:
%
% [1] M. Magdowski and R. Vick, "Closed form formulas for the stochastic electromagnetic
%     field coupling to a transmission line with arbitrary loads", IEEE Transactions on
%     Electromagnetic Compatibility, vol. 54, no. 5, pp. 1147-1152, October 2012.
%

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );

  % Set defaults if required.
  if( nargin < 5 )
    eps_r = 1.0;
  end % if  
  if( nargin < 6 )
    R_1 = Z_c;
  end % if
  if( nargin < 7 )
    R_2 = Z_c;
  end % if
  
  % Wave-number.
  k = 2 .* pi .* f ./ c0 .* sqrt( eps_r );
  kl = k .* length;
  
  % Line height above symmetry plane. 
  height = 0.5 * spacing;
  
  % Terminal reflection coefficients, [1, eqn. (11)].
  A_1 = ( Z_c - R_1 ) ./ ( Z_c + R_1 );  
  A_2 = ( Z_c - R_2 ) ./ ( Z_c + R_2 );  

  % Denominator term, [1, eqn. (10)].
  D = 1.0 + A_1.^2 .* A_2.^2 - 2.0 .* A_1 .* A_2 .* cos( 2.0 .* kl ) ;

  % Common term.
  common = eta0 / sqrt( eps_r ) .* height.^2 ./ Z_c .* ( 2.0 - sin( 2.0 .* kl ) ./ kl );

  % Contribution to ACS of each terminal, [1, eqn. (29)-(30)].
  ACS_1 = 0.5 ./ D .* ( 1 + A_1 ).^2 .* ( 1 + A_2.^2 ) .* common;
  ACS_2 = 0.5 ./ D .* ( 1 + A_2 ).^2 .* ( 1 + A_1.^2 ) .* common;
  
  % Overall ACS.
  ACS = ACS_1 + ACS_2;

end % function
