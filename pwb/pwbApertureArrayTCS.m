function [ TCS , TE ] = pwbApertureArrayTCS( f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                             apertureArea , alpha_mxx , alpha_myy , alpha_ezz , cutOffFreq )
%pwbApertureArray - Determine average transmission cross-section of a large periodic array of apertures.
%
% [ TCS , TE ] = pwbApertureArray( f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
%                                  , apertureArea , alpha_mxx , alpha_myy , alpha_ezz [ , cutOffFreq ]  )
%
% Determine the average transmission cross-section of a large array of apertures from its area and the 
% electric and magnetic polarisabiltites, pitch and area of the individual apertures [1,2,3]. 
%
% Note: The TCS and TE follow convention of including the factor of half from the 
% half-space illumination in the cross-section itself.

% Inputs:
%
% f                 - real vector, frequenciy [Hz].          
% arrayArea         - real scalar, area of whole array [m^2].
% arrayPeriodX      - real scalar, period of the primitive unit cell in x direction [m].
% arrayPeriodY      - real scalar, period of the primitive unit cell in y direction [m].
% unitCellArea      - real scalar, area of primitive unit cell [m^2]. 
% thickness         - real scalar, thickness of plate [m].   
% apertureArea      - real scalar, area of a single aperture [m^2].
% alpha_mxx         - real scalar, magnetic polarisability of an aperture in x-direction [m^3].
% alpha_myy         - real scalar, magnetic polarisability of an aperture in y-direction [m^3].
% alpha_ezz         - real scalar, electric polarisability of an aperture in z-direction [m^3].
% cutOffFreq        - real scalar, cut-off frequency of fundamental waveguide mode of aperture [Hz].
%
% Outputs:
%
% TCS - real vector, average transmission cross-section of the array [m^2].
% TE  - real vector, average transmission efficiency of the array [-].
%
% Notes:
%
% (1) The model is valid when the ratio of the largest aperture dimension to the smallest array
%     period is less than about 0.7 and when the array periods are less than half a wavelength.
%
% (2) The model interpolation of the TCS in the frequency range where the aperture is supra-resonant
%     but the lattice period is still less than half a wavelength is uncertain.
%
% References:
%
% [1] U. Paoletti, T. Suga and H. Osaka, 
%     "Average transmission cross section of aperture arrays in electrically large complex enclosures",
%     2012 Asia-Pacific Symposium on Electromagnetic Compatibility, Singapore, 2012, pp. 677-680.
%     DOI: 10.1109/APEMC.2012.6237888
%
% [2] C. L. Holloway, M. A. Mohamed, E. F. Kuester and A. Dienstfrey,
%     "Reflection and transmission properties of a metafilm: with an application to a controllable 
%     surface composed of resonant particles",
%     IEEE Transactions on Electromagnetic Compatibility, vol. 47, no. 4, pp. 853-865, Nov. 2005.
%     DOI: 10.1109/TEMC.2005.853719
%
% [3] E. F. Kuester, M. A. Mohamed, M. Piket-May and C. L. Holloway,
%     "Averaged transition conditions for electromagnetic fields at a metafilm",
%     IEEE Transactions on Antennas and Propagation, vol. 51, no. 10, pp. 2641-2651, Oct. 2003.
%     DOI: 10.1109/TAP.2003.817560
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
% Date: 12/01/2017

  % Physical consts.
  c0 = 299792458;

  % Function to calculate TCS for a given angle of incidence. Kernels from [1, eqn. (8)].
  function [ TCS_TE , TCS_TM ] = kernel( theta , k , arrayArea , alpha_ezz , alpha_mxx , alpha_myy )
 
    costheta = cos( theta );
    sintheta = sin( theta );
    costheta2 = costheta.^2;
    sintheta2 = sintheta.^2;
    bracketA2 = 4.0 .* k.^2 .* alpha_mxx.^2 .* costheta2;
    TCS_TE = arrayArea .* costheta .* bracketA2 ./ ( 1.0 + bracketA2 );
    bracketB2 = 4.0 .* k.^2 .* ( alpha_myy - alpha_ezz .* sintheta2 ).^2;
    TCS_TM = arrayArea .* costheta .* bracketB2 ./ ( costheta2 + bracketB2 );

  end % function
  
  % Function to estimate the Epstein Zeta function to about three significant figures.
  function [ R ] = EpsteinZeta( a , b )
  
    % Sledgehammer algorithm - sample all possible values up to some maximum.
    max_mn = 2000;
    m = -max_mn:max_mn;
    n = m;
    [ mm , nn ] = meshgrid( m , n );
    denom = ( ( mm .* a ./ 2 ).^2 + ( nn .* b ./ 2 ).^2 ).^-(3/2);
    
    % Ref [1] gives this, but its not consistent with [2] and gives wrong result.
    idx = find( rem( mm + nn , 2 ) == 0 & ( nn ~= 0 | mm ~= 0 ) );
    %idx = find( nn ~= 0 | mm ~= 0 );
    
    % Ref [1] has a 4 here but its not consistent with [].
    R = 4.0 * pi / a / b / sum( denom(idx) );
    %R = 4.0 *  4.0 * pi / a / b / sum( denom(idx) );
    
  end % function
  
  % Wavenumber and wavelength.
  k = 2.0 .* pi .* f ./ c0;
  lambda = c0 ./ f;
    
  % Check validity of model [1, Section II.B].
  if( sqrt( apertureArea / unitCellArea ) > 0.7 )
    warning( 'spacing is small compared to array period' );
  end % if
  
  mask = ( arrayPeriodX > lambda / 2 ) | ( arrayPeriodY > lambda / 2 );
  if( any( mask ) )
    idx = find( mask , 1 );
    warning( 'array period too small above %g GHz' , f(idx) ./ 1e9 );
  end % if

   % Find cut-off frequency of apertures. 
  [ ~ , ~ , f_c ] = pwbApertureTCS( f , apertureArea , alpha_mxx , alpha_myy , alpha_ezz );
  if( f_c < f(end ) )
    warning( 'aperture cut-off frequency %g GHz below highest frequency' , f_c / 1e9 );  
  end % if
  
  % Averaging range parameter.
  [ R ] = EpsteinZeta( arrayPeriodX , arrayPeriodY );

  % Number of apertures per unit area.
  n = 1.0 / unitCellArea;

  % Polarisabilitites, corrected for mutual coupling.
  alpha_mxx = n * alpha_mxx / ( 1.0 + 0.25 * n * alpha_mxx / R );
  alpha_myy = n * alpha_myy / ( 1.0 + 0.25 * n * alpha_myy / R );
  alpha_ezz = n * alpha_ezz / ( 1.0 + 0.5  * n * alpha_ezz / R );

  % Use GLQ over hemisphere to get averages.
  %order = 2 * ceil( pi * sqrt( arrayArea ) * f(end) / c0 );
  order = 12;
  [ theta , phi , psi , weight ] = pwbGaussLegendreAngles( order , true , true , false );

  % Sample plane-wave cross-sections.
  for idx = 1:size( theta , 2 )
    [ A , B ] = kernel( theta(1,idx,1) , k , arrayArea , alpha_ezz , alpha_mxx , alpha_myy );
    TCS_TE(:,idx) = A;
    TCS_TM(:,idx) = B;
  end % for  

  % This gives mathematical average over hemisphere.
  [ TCS ] = pwbGaussLegendreAverage( [ TCS_TE , TCS_TM ]  , order , weight , true , true );
  
  % Normalise for half-space cross-section convention.
  TCS = 0.5 .* TCS;

  % Estimate attenuation due to finite thickness from fundamental waveguide mode cut-off frequency. 
  if( nargin == 10 )
    % [FIXME] If frequency not given estimate from PWB asymptotic GO frequency.
    cutOffFreq = f_c * 2;
  end % if
  apertureAttnConst = 2.0 .* pi ./ c0 .* sqrt( cutOffFreq.^2 - f.^2 );
  mask = imag( apertureAttnConst ~= 0 );
  TCS = ( TCS .* exp( -2.0 .* apertureAttnConst .* thickness ) ) .* ~mask + TCS .* mask;
  
  % High frequency asymptote.
  TCS_GO = 0.25 * arrayArea * apertureArea / unitCellArea;
  mask = TCS >= TCS_GO;
  TCS = TCS .* ~mask + TCS_GO .* mask;
  
  % Efficiency of whole array.
  TE = 4.0 .* TCS / arrayArea;

end % function
