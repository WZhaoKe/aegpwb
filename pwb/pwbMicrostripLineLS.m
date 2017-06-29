function [ ACS , ACS_1 , ACS_2 ] = pwbMicrostripLineLS( f , length , width , height , eps_r , thickness , Z_0 , Z_l )
%pwbMicrostripLineLS - Absorption by a microstrip transmission line. Uses rigorous
%                      solution for microstrip line numerically integrated over angles.
%
% Usage:
%
% [  ACS , ACS_1 , ACS_2 ] = pwbMicrostripLineLS( f , length , width , height , eps_r , thickness , [ , Z_0 [ , Z_l ] ] )
%
% Inputs:
%
% f         - real vector, frequency [Hz].
% length    - real scalar, length of line [m].
% width     - real scalar, width of line [m].
% height    - real scalar, line height [m].
% thickness - real scalar, metalisation thickness [m].
% eps_r     - real scalar or vector, substrate relative permittivity [-]
% Z_0       - complex scalar or vector, terminal impedance at end 0 [ohms].
%             Defaults to line characteristic impedance.
% Z_l       - complex scalar or vector, terminal impedance at end l [ohms].
%             Defaults to line characteristic impedance.
%
% Outputs:
%
% ACS   - real vector, total average absorption cross-section [m^2].
% ACS_1 - real vector, average absorption cross-section into load one [m^2].
% ACS_2 - real vector, average absorption cross-section into load two [m^2].
%
% References:
%
% [1] 
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

  % Constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );

  % Unit amplitude plane-wave.
  E_0 = 1.0;

  % Incident power density in each plane-wave.
  S_i = 0.5 * abs( E_0 )^2 / eta0;

  % Determine microstrip parameters.
  [ Z_c , eps_r_eff , vp ] = tlModelMicroStrip( f , width , height , eps_r , thickness );

  % Set default terminal impedances if required.
  if( nargin < 7 )
    Z_0 = Z_c;
  end % if
  if( nargin < 8 )
    Z_l = Z_c;
  end % if

  % Sample angles for polarisation.
  N_gamma = 2;
  %gammas = linspace( 0.0 , 180.0 , N_gamma );
  gammas = [ 0 , 90 ];
    
  % Sample points for spherical integration using Gauss-Legendre quadrature.
  % Use Bucci estimate of spatial bandwidth.
  L = 2 * ceil( pi * length * f(end) / c0 );
  [ costheta , weight ] = GaussLegendre( L );
  thetas = acosd( costheta );
  phis = 180.0 .* (1:(2*L)) ./ L ;
  
  % Only integrate over theta from 0 to 90 degrees.
  idx = find( costheta >= 0.0 -10 * eps );
  thetas = thetas(idx);
  weight = weight(idx);
  if( rem( L , 2 ) == 1 )
    weight(1) = 0.5 * weight(1);
  end % if
 
  % Hold angular distributions.
  Pdist = zeros( numel( thetas ) , numel( phis ) , numel( f ) );

  % Accumulator for absorbed power.
  P_a_1 = zeros( size( f ) );
  P_a_2 = zeros( size( f ) );
    
  % Integrate over sphere and polarisations.
  for idxTheta=1:numel( thetas )
    theta = thetas(idxTheta);
    for idxPhi = 1:numel( phis )
      phi = phis(idxPhi);
      for idxGamma = 1:numel( gammas )
        gamma = gammas(idxGamma);
        [ V_0 , V_l ] = tlExcitedMicrostripLS( f , height , length , eps_r , Z_c , eps_r_eff , Z_0 , Z_l , E_0 , theta , phi , gamma );
        P_a_1 = P_a_1 + weight(idxTheta) .*  0.5 .* ( abs( V_0 ).^2 .* real( 1 ./ conj( Z_0 ) ) );
        P_a_2 = P_a_2 + weight(idxTheta) .*  0.5 .* ( abs( V_l ).^2 .* real( 1 ./ conj( Z_l ) ) );
      end % for
    end % for
  end % for  

  % Normalisation of total power integral.
  P_a_1 = pi ./ L .* P_a_1;
  P_a_2 = pi ./ L .* P_a_2;
    
  % Average power - relative to scalar power density in cavity centre.
  P_a_1 = P_a_1 / 4.0 / pi / N_gamma;
  P_a_2 = P_a_2 / 4.0 / pi / N_gamma;
  
  % Determine average ACS.
  ACS_1 = P_a_1 ./ S_i;
  ACS_2 = P_a_2 ./ S_i;
  ACS = ACS_1 + ACS_2;

end % function
