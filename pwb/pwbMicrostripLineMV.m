function [ ACS , ACS_1 , ACS_2 ] = pwbMicrostripLineMV( f , length , width , height , eps_r , thickness , R_0 , R_l )
%pwbMicrostripLineSimple - Absorption by a microstrip transmission line. Uses equivalanet
%                          two-wire line model with effective parameters.
%
% Usage:
%
% [ ACS , ACS_1 , ACS_2 ] = pwbMicrostripLineMV( f , length , width , height , eps_r , thickness , R_0 , R_l )
%
% Inputs:
%
% f         - real vector, frequency [Hz].
% length    - real scalar, length of line [m].
% width     - real scalar, width of line [m].
% height    - real scalar, line height [m].
% thickness - real scalar, metalisation thickness [m].
% eps_r     - real scalar or vector, substrate relative permittivity [-]
% R_0       - real scalar or vector, terminal resistance at end 0 [ohms].
%             Defaults to line characteristic impedance.
% R_l       - real scalar or vector, terminal resistance at end l [ohms].
%             Defaults to line characteristic impedance.
%
% Outputs:
%
% ACS   - real vector, average absorption cross-section [m^2].
% ACS_1 - real vector, average absorption cross-section into load one [m^2].
% ACS_2 - real vector, average absorption cross-section into load two [m^2].
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2017 Ian Flintoft <ian.flintoft@googlemail.com>
%
% aegpwb is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% aegpwb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with aegpwb.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: Ian Flintoft <ian.flintoft@googlemail.com>
% Date: 18/01/2017

  % Determine microstrip parameters.
  [ Z_c , eps_r_eff , vp ] = tlModelMicroStrip( f , width , height , eps_r , thickness );

  % Low frequency height correction.
  %height = height .* sqrt( 0.5 .* ( 1.0 + eps_r_eff ./ eps_r.^2 ) );
  %eps_r_TWL = 0.5 .* ( 1.0 + eps_r_eff ./ eps_r.^2 );
  %h_TWL = height;
  eps_r_TWL = eps_r_eff;
  h_TWL = height .* sqrt( 0.5 .* ( 1.0 ./ eps_r_eff  + 1.0 ./ eps_r.^2  ) );
  h_TWL = height .* sqrt( 0.5 .* ( 1.0 + eps_r_eff ./ eps_r.^2  ) / sqrt( eps_r_eff ) );  

  % Effective wire diameter [1]. Not used.
  %d0 = 2 * height * exp( -Z_c * sqrt( eps_r_eff ) / 60.0 );

  % Set default terminal impedances if required.
  if( nargin < 7 )
    R_0 = Z_c;
  end % if
  if( nargin < 8 )
    R_l = Z_c;
  end % if

  % Model microstrip line as single wire over ground. Matching characteristic impedance and 
  % propagation constant along line => embed in medium with permittivity eps_r_eff.
  % Use image theory to map single with over ground to two wire line - double impedances. 
  [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineZc( f , length , 2.0 * h_TWL , Z_c , eps_r_TWL , R_0 , R_l );
  %[ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineDiameter( f , length , 2.0 * height , d0 , eps_r_eff , 2.0 * R_0 , 2.0 * R_l );
  
  % Need to half the powers (acs) to get the single wire over ground values.
  ACS = 0.5 .* ACS;
  ACS_1 = 0.5 .* ACS_1;
  ACS_2 = 0.5 .* ACS_2;

end % function
