function [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineDiameter( f , length , spacing , diameter , eps_r , R_1 , R_2 )
% pwbTwoWireLineDiameter - Average absorption cross-section of a two-wire transmission line
%                          taking the wire diameter as a parameter.
%
% Usage:
%
% [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineDiameter( f , length , spacing , diameter [ , eps_r  [ , R_1 [ , R_2 ] ] ] )
%
% Inputs:
%
% f        - real vector, frequency [Hz].
% length   - real scalar, length of line [m].
% spacing  - real scalar, separation of wires [m].
% diameter - real scalar, wire diameter [m].
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

  % Characteristic impedance of the line.
  Z_c = eta0 / pi / sqrt( eps_r ) * acosh( spacing / diameter );

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

  [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineZc( f , length , spacing , Z_c , eps_r , R_1 , R_2 ); 
 
end % function
