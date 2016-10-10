function [ isPass ] = pwbTestSphere1()
% pwbTestSphere1 -
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft <ian.flintoft@googlemail.com>
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
% Date: 19/08/2016

  isValidTol=@(x,y,tol) all( abs( x - y ) < tol );
  isPass = true;
  
  data = [ 0.9125 , -0.343689320388 ; ...
           1.1 , -0.592233009709 ; ...
           1.25 , -0.732038834951 ; ...
           1.4 , -0.840776699029 ; ...
           1.5125 , -0.941747572816 ; ...
           1.68125 , -1.05048543689 ; ...
           1.8875 , -1.17475728155 ; ...
           2.1125 , -1.28349514563 ; ...
           2.31875 , -1.37669902913 ; ...
           2.58125 , -1.4854368932 ; ...
           2.88125 , -1.58640776699 ; ...
           3.18125 , -1.6640776699 ; ...
           3.51875 , -1.7572815534 ; ...
           3.78125 , -1.81165048544 ; ...
           4.15625 , -1.87378640777 ; ...
           4.60625 , -1.95145631068 ; ...
           5.01875 , -2.01359223301 ; ...
           5.65625 , -2.08349514563 ; ...
           6.14375 , -2.13786407767 ; ...
           6.575 , -2.16893203883 ; ...
           7.1375 , -2.22330097087 ; ...
           7.8125 , -2.26990291262 ; ...
           8.525 , -2.31650485437 ; ...
           9.25625 , -2.34757281553 ; ...
           9.8 , -2.3786407767 ; ...
           10.45625 , -2.41747572816 ; ... 
           11.05625 , -2.43300970874 ; ...
           11.825 , -2.4640776699 ; ...
           12.4625 , -2.48737864078 ; ...
           13.25 , -2.51067961165 ; ...
           13.68125 , -2.51844660194 ; ...
           14.00125 , -2.52621359223 ];
  
  f = linspace( 1e9 , 14e9 ,50 )';
  radius = 0.1;
  eps_r = 42;
  sigma = 0.99;

  f_val = 1e9 .* data(:,1);
  AE_val = interp1( f_val , 10.^( data(:,2) ./ 10.0 ) , f );
  ACS_val = pi * radius^2 .* AE_val;
   
  [ ACS1 , AE1 ] = pwbLaminatedSphere_PenaPal( f , radius , eps_r , sigma , 1.0 );
  isPass = isPass && isValidTol( ACS_val , ACS1 , 1e-3 );
  isPass = isPass && isValidTol( AE_val , AE1 , 1e-2 );
  [ ACS2 , AE2 ] = pwbLaminatedSphere_SPlaC( f , radius , eps_r , sigma , 1.0 );
  isPass = isPass && isValidTol( ACS1 , ACS2 , 1e-6 );
  isPass = isPass && isValidTol( AE1 , AE2 , 1e-6 );
  [ ACS3 , AE3 ] = pwbLaminatedSphere_PenaPalM( f , radius , eps_r , sigma , 1.0 );
  isPass = isPass && isValidTol( ACS1 , ACS3 , 1e-6 );
  isPass = isPass && isValidTol( AE1 , AE3 , 1e-6 );
  [ ACS4 , AE4 ] = pwbSphere_Markowicz( f , radius , eps_r , sigma , 1.0 );
  isPass = isPass && isValidTol( ACS1 , ACS4 , 1e-6 );
  isPass = isPass && isValidTol( AE1 , AE4 , 1e-6 );
  [ ACS5 , AE5 ] = pwbSphere_Matzler( f , radius , eps_r , sigma , 1.0 );
  isPass = isPass && isValidTol( ACS1 , ACS5 , 1e-6 );
  isPass = isPass && isValidTol( AE1 , AE5 , 1e-6 );
  
  %figure( 1 );
  %plot( f / 1e9 , ACS_val / pi / radius^2 , 'r-' );
  %hold on;
  %plot( f / 1e9 , ACS1 / pi / radius^2 , 'b-.' );
  %plot( f / 1e9 , ACS2 / pi / radius^2 , 'g:' );
  %plot( f / 1e9 , ACS3 / pi / radius^2 , 'k--' );
  %hxl = xlabel( 'Frequency (GHz)' );
  %hyl = ylabel( '\sigma^{a} / \pi a^2 (m^2)' );
  %xlim( [ 1 , 14  ] );
  %grid( 'on' );
  %hlg = legend( 'ONERA (Redigitised)' , 'scattnlay' ,  'SPlaC' , 'PenaPal' , 'location' , 'southwest' );
  %title( 'ACS of 100 mm radius homogeneous sphere with \epsilon_r=42 and \sigma=0.99 S/m' );
  %print( '-depsc2' , 'pwbTestSphere1.eps' );
  %hold off;
  %close();
  
end % function

