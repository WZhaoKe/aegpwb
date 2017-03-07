function [ theta , phi , psi , weight ] = pwbGaussLegendreAngles( order , isCylindircal , isHemisphere , isPlot )
%pwbGaussLegendreAngles - Determine spherical polar angles and polarisation angle for integrating
%                         over the surface of a sphere or hemi-sphere.
%
% Usage:
%
% [ theta , phi , psi , weight ] = pwbGaussLegendreAngles( order , isCylindircal , isHemisphere , isPlot )
%
% Inputs:
%
% order         - integer scalar, positive integer giving the order of the quadrature [-].
% isCylindircal - boolean scalar, true if problem has cylindrical symmetry.
% isHemisphere  - boolean scalar, true if only z > 0 hemisphere is included.
% isPlot        - boolean scalar, true is plot of angles is required.
%
% Outputs:
%
% theta - real array, polar sampling angles [rad].
% phi   - real array, azimuthal sampling angles [rad].
% psi - real array, polarisation sampling angles [rad].
% weight - real array, Gauss-Legendre weights [-].
%
% Notes:
%
% 1. Physics convention spherical coordinates are used with theta being
%    the polar angles measured from the z-axis to the direction vector,
%    phi being the azimuthal angles between the x-axis and the projection of
%    the direction vector in the x-y plane. 
%
% 2. The polarisation angle is measured from the minus theta direction 
%    according to the right-hand rule.
%
% 3. All the return values are N_theta x N_phi x N_psi arrays. So, for 
%    example theta(i,j,k) is the value of the the polar angles for the
%    sample corresponding to the i-th theta direction, j-th psi direction
%    and k-th psi polarisation. Vectors of sampling angles can be obtained from:
%
%    theta = squeeze( theta(:,1,1,) );
%    psi = squeeze( psi(1,:,1) );
%    psi  = squeeze( psi(1,1,:) )
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
% Date: 19/01/2017

  % Calculate polar angles and weights for Gauss Legendre sampling.
  [ costheta , weights ] = GaussLegendre( order );
  thetas = acos( costheta );
  
  % If cylindrical symmetry only use phi = 2 * pi.
  if( isCylindircal )
    phis = 2.0 * pi;
  else
    phis = pi .* (1:(2*order)) ./ order;
  end % if
  
  % For z > 0 hemisphere only integrate over theta from 0 to pi/2 radians.
  if( isHemisphere )
    idx = find( costheta >= 0.0 -10 * eps );
    thetas = thetas(idx);
    weights = weights(idx);
    if( rem( order , 2 ) == 1 )
      weights(1) = 0.5 * weights(1);
    end % if
  end % if
  
  % Polarisations.
  psis = [ 0 , pi / 2 ];
  N_psi = length( psis );

  % Assemble angles.
  [ theta , phi , psi ] = meshgrid( thetas , phis , psis );
  [ weight , ~ , ~ ] = meshgrid( weights , phis , psis );
  
  % Validate using unit sphere.
  [ avgSurfIntegral ] = pwbGaussLegendreAverage( ones( 1 , numel( theta ) ) , order , weight , isCylindircal , isHemisphere );  
  relError = avgSurfIntegral - 1.0;
  assert( abs( relError ) < 1e-3 );

  if( isPlot )
  
    [ k_x , k_y , k_z , E_x , E_y , E_z ] = pwbPlaneWaveFields( 1.0 , theta , phi , psi );
  
    figure()
    hl1 = plot3( [ -k_x(:)' ; zeros(1,length(k_x(:))) ], [ -k_y(:)' ; zeros(1,length(k_y(:))) ] , [ -k_z(:)' ; zeros(1,length(k_z(:))) ] , 'lineWidth' , 4 , 'color' , 'blue' );
    hold on;
    magE = 0.2;
    plot3( [ -k_x(:)' ; -k_x(:)' + magE * E_x(:)' ], [ -k_y(:)' ; -k_y(:)' + magE * E_y(:)' ] , [ -k_z(:)' ; -k_z(:)' + magE * E_z(:)' ] , 'lineWidth' , 4 , 'color' , 'red' );
    xlim( [ -1 , 1 ] );
    ylim( [ -1 , 1 ] ); 
    zlim( [ -1 , 1 ] );
    grid( 'on' );
    hxl = xlabel( 'x' );
    hyl = ylabel( 'y' );
    hzl = zlabel( 'z' );
    hold off;
  end % if
  
end % function
