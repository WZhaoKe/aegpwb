function [ isPass ] = emTestMultiRefAniso1()
%
% emTestMultiRefAniso1 -
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft <ian.flintoft@googlemail.com>
%
% aeggpwb is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% aeggpwb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with aeggpwb.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: Ian Flintoft <ian.flintoft@googlemail.com>
% Date: 19/08/2016
% Version: 1.0.0

  tol = 1e-3;
  isValid=@(x,y) all( abs( x - y ) < tol );
  isPass = true;
  
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );
  
  db20=@(x) 20.0 .* log10( x );
  
  %
  % EWA Fig 8.3.2, p308.
  %

  M = 1;
  L1 = 0.5;
  la0 = 1.0;
  f0 = c0 / la0;
  eps_r1 = 2.25;
  mu_r1 = 1.0;
  sig1 = 0.0;
  eps_ra = 1;
  eps_rb = 1;

  n1 = sqrt( eps_r1 );
  na = sqrt( eps_ra );
  nb = sqrt( eps_rb );

  f = linspace( 1e-6 , 3 * f0 , 401 );
  la = c0 ./ f;

  S11_te_0  = multidiel( [ na , n1 , nb ] , L1 , la/la0 ,  0.0 , 'te' );
  S11_te_75 = multidiel( [ na , n1 , nb ] , L1 , la/la0 , 75.0 , 'te' );
  S11_te_85 = multidiel( [ na , n1 , nb ] , L1 , la/la0 , 85.0 , 'te' );
  S11_tm_0  = multidiel( [ na , n1 , nb ] , L1 , la/la0 ,  0.0 , 'tm' );
  S11_tm_75 = multidiel( [ na , n1 , nb ] , L1 , la/la0 , 75.0 , 'tm' );
  S11_tm_85 = multidiel( [ na , n1 , nb ] , L1 , la/la0 , 85.0 , 'tm' );

  [ S_0  ] = emMultiRefAniso( f ,  0.0 , [L1/n1] , [0.0] , 1.0 , 1.0 , [eps_r1] , [0] , [mu_r1] , 'S' );
  [ S_75 ] = emMultiRefAniso( f , 75.0 , [L1/n1] , [0.0] , 1.0 , 1.0 , [eps_r1] , [0] , [mu_r1] , 'S' );
  [ S_85 ] = emMultiRefAniso( f , 85.0 , [L1/n1] , [0.0] , 1.0 , 1.0 , [eps_r1] , [0] , [mu_r1] , 'S' );
 
  isPass = isPass && isValid( S11_te_0(:) , squeeze(S_0(3,3,:)) );
  isPass = isPass && isValid( S11_te_75(:) , squeeze(S_75(3,3,:)) );
  isPass = isPass && isValid( S11_te_85(:) , squeeze(S_85(3,3,:)) );
  isPass = isPass && isValid( S11_tm_0(:)  , squeeze(S_0(1,1,:)) );
  isPass = isPass && isValid( S11_tm_75(:) , squeeze(S_75(1,1,:)) );
  isPass = isPass && isValid( S11_tm_85(:) , squeeze(S_85(1,1,:)) );

  figure();
  plot( f/f0 , abs( S11_te_0 ).^2 , 'r-' );
  hold on;
  plot( f/f0 , abs( squeeze( S_0(1,1,:) ) ).^2 , 'r*' );
  plot( f/f0 , abs( S11_te_75 ).^2 , 'b-' );
  plot( f/f0 , abs( squeeze( S_75(3,3,:) ) ).^2 , 'b*' );
  plot( f/f0 , abs( S11_tm_75 ).^2  , 'g-' );
  plot( f/f0 , abs( squeeze( S_75(1,1,:) ) ).^2 , 'g*' );
  xlabel( 'f/f_0' );
  ylabel( '|T(f)|^2' );
  axis( [ 0 3 0 1 ] );
  legend( 'Normal - EWA' , 'Normal - emMultiRefAniso' , 'TE - EWA' , 'TE - emMultiRefAniso' , 'TM -EWA' , 'TM - emMultiRefAniso' );
  print( 'emTestMultiRefAniso2-ewa8.3.2a.eps' , '-depsc2' );
  hold off;
  close();
  
  figure();
  plot( f/f0 , abs( S11_te_0 ).^2 , 'r-' );
  hold on;
  plot( f/f0 , abs( squeeze( S_0(1,1,:) ) ).^2 , 'r*' );
  plot( f/f0 , abs( S11_te_85 ).^2 , 'b-' );
  plot( f/f0 , abs( squeeze( S_85(3,3,:) ) ).^2 , 'b*' );
  plot( f/f0 , abs( S11_tm_85 ).^2  , 'g-' );
  plot( f/f0 , abs( squeeze( S_85(1,1,:) ) ).^2 , 'g*' );
  xlabel( 'f/f_0' );
  ylabel( '|T(f)|^2' );
  axis( [ 0 3 0 1 ] );
  legend( 'Normal - EWA' , 'Normal - emMultiRefAniso' , 'TE - EWA' , 'TE - emMultiRefAniso' , 'TM -EWA' , 'TM - emMultiRefAniso' );
  print( 'emTestMultiRefAniso2-ewa8.3.2b.eps' , '-depsc2' );
  hold off;
  close();
  
  %
  % Fig 8.7.1, p329.
  %

  M = 2;
  L1 = 0.3294;
  L2 = 0.0453;
  la0 = 550e-9;
  f0 = c0 / la0;
  eps_ra = 1.0;
  eps_r1 = 1.38^2;
  eps_r2 = 2.45^2;
  eps_rb = 1.5^2;
  mu_ra = 1.0;
  mu_r1 = 1.0;
  mu_r2 = 1.0;
  mu_rb = 1.0;
  sig1 = 0.0;
  sig2 = 0.0;
  na = sqrt( eps_ra );
  n1 = sqrt( eps_r1 );
  n2 = sqrt( eps_r2 );
  nb = sqrt( eps_rb );

  la = linspace( 400e-9, 700e-9 , 101 );
  f = c0 ./ la;

  S11_te_0  = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0 ,  0.0 , 'te' );
  S11_te_20 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 20.0 , 'te' );
  S11_te_30 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 30.0 , 'te' );
  S11_te_40 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 40.0 , 'te' );
  S11_tm_0  = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  ,  0.0 , 'tm' );
  S11_tm_20 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 20.0 , 'tm' );
  S11_tm_30 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 30.0 , 'tm' );
  S11_tm_40 = multidiel( [ na , n1 , n2 , nb ] , [ L1 , L2 ] , la / la0  , 40.0 , 'tm' );

  [ S_0  ] = emMultiRefAniso( f ,  0.0 , [la0*L1/n1,la0*L2/n2] , [0.0;0.0] , eps_ra , eps_rb , [eps_r1,eps_r2] , [0,0] , [mu_r1,mu_r2] , 'S' );
  [ S_20 ] = emMultiRefAniso( f , 20.0 , [la0*L1/n1,la0*L2/n2] , [0.0;0.0] , eps_ra , eps_rb , [eps_r1,eps_r2] , [0,0] , [mu_r1,mu_r2] , 'S' );
  [ S_30 ] = emMultiRefAniso( f , 30.0 , [la0*L1/n1,la0*L2/n2] , [0.0;0.0] , eps_ra , eps_rb , [eps_r1,eps_r2] , [0,0] , [mu_r1,mu_r2] , 'S' );
  [ S_40 ] = emMultiRefAniso( f , 40.0 , [la0*L1/n1,la0*L2/n2] , [0.0;0.0] , eps_ra , eps_rb , [eps_r1,eps_r2] , [0,0] , [mu_r1,mu_r2] , 'S' );

  isPass = isPass && isValid( S11_te_0(:)   , squeeze(S_0(3,3,:)) );
  isPass = isPass && isValid( S11_te_20(:)  , squeeze(S_20(3,3,:)) );
  isPass = isPass && isValid( S11_te_30(:)  , squeeze(S_30(3,3,:)) );
  isPass = isPass && isValid( S11_te_40(:)  , squeeze(S_40(3,3,:)) );
  isPass = isPass && isValid( S11_tm_0(:)   , squeeze(S_0(1,1,:)) );
  isPass = isPass && isValid( S11_tm_20(:)  , squeeze(S_20(1,1,:)) );
  isPass = isPass && isValid( S11_tm_30(:)  , squeeze(S_30(1,1,:)) );
  isPass = isPass && isValid( S11_tm_40(:)  , squeeze(S_40(1,1,:)) );

  figure();
  plot( la/1e-9 , 100*abs( S11_te_0 ).^2 , 'r-' );
  hold on;
  plot( la/1e-9 , 100*abs( squeeze( S_0(3,3,:) ) ).^2 , 'r*' );
  plot( la/1e-9 , 100*abs( S11_te_20 ).^2 , 'b-' );
  plot( la/1e-9 , 100*abs( squeeze( S_20(3,3,:) ) ).^2 , 'b*' );
  plot( la/1e-9 , 100*abs( S11_te_30 ).^2  , 'g-' );
  plot( la/1e-9 , 100*abs( squeeze( S_30(3,3,:) ) ).^2 , 'g*' );
  plot( la/1e-9 , 100*abs( S11_te_40 ).^2  , 'c-' );
  plot( la/1e-9 , 100*abs( squeeze( S_40(3,3,:) ) ).^2 , 'c*' );
  xlabel( '\lambda (mm)'  );
  ylabel( '|T(f)|^2 (%)' );
  axis( [ 400 700 0 4 ] );
  legend( '0^o - EWA' , '0^o - emMultiRefAniso' , '20^o - EWA'  , '20^o - emMultiRefAniso' , '30^o - EWA'  , '30^o - emMultiRefAniso', '40^o - EWA' , '40^o - emMultiRefAniso' );
  print( 'emTestMultiRefAniso2-ewa8.7.1a.eps' , '-depsc2' );
  hold off;
  close();
  
  figure();
  plot( la/1e-9 , 100*abs( S11_tm_0 ).^2 , 'r-' );
  hold on;
  plot( la/1e-9 , 100*abs( squeeze( S_0(1,1,:) ) ).^2 , 'r*' );
  plot( la/1e-9 , 100*abs( S11_tm_20 ).^2 , 'b-' );
  plot( la/1e-9 , 100*abs( squeeze( S_20(1,1,:) ) ).^2 , 'b*' );
  plot( la/1e-9 , 100*abs( S11_tm_30 ).^2  , 'g-' );
  plot( la/1e-9 , 100*abs( squeeze( S_30(1,1,:) ) ).^2 , 'g*' );
  plot( la/1e-9 , 100*abs( S11_tm_40 ).^2  , 'c-' );
  plot( la/1e-9 , 100*abs( squeeze( S_40(1,1,:) ) ).^2 , 'c*' );
  xlabel( '\lambda (mm)' );
  ylabel( '|T(f)|^2 (%)' );
  axis( [ 400 700 0 4 ] );
  legend( '0^o - EWA' , '0^o - emMultiRefAniso' , '20^o - EWA'  , '20^o - emMultiRefAniso' , '30^o - EWA'  , '30^o - emMultiRefAniso', '40^o - EWA' , '40^o - emMultiRefAniso' );
  print( 'emTestMultiRefAniso2-ewa8.7.1b.eps' , '-depsc2' );
  hold off;
  close();
  
  %
  % Check against Planar SE.
  %

  thick = 0.5e-3;
  sig   = 10e3;
  sigm  = 0.0;
  eps_r = 1.0;
  mu_r = 1.0;

  f = 1e6 .* logspace( 0 , 4 , 100 );

  [ SE , R , A , M ] = emPlanarSE( f , eps_r , sig , mu_r , sigm , thick );

  [ S1 ] = emMultiRefAniso( f , 0.0 , [thick] , [0.0] , 1.0 , 1.0 , [eps_r] , [sig] , [mu_r] , 'S' );
  [ S2 ] = emMultiRef( f , eta0 , eta0 , [eps_r] , [sig] , [mu_r] , [0.0] , [thick] , 'S' );

  isPass = isPass && isValid( SE(:) , -db20( squeeze( abs( S1(1,2,:) ) ) ) );
  isPass = isPass && all( all( all( abs( S1(1:2,1:2,:) - S2 ) < tol ) ) );
  isPass = isPass && all( all( all( abs( S1(3:4,3:4,:) - S2 ) < tol ) ) );

  figure();
  semilogx( f / 1e6 , SE , 'r-' );
  hold on;
  semilogx( f / 1e6 , -db20( squeeze( S1(1,2,:) ) ) , 'r*' )
  semilogx( f / 1e6 , -db20( squeeze( S2(1,2,:) ) ) , 'r*' )
  xlabel( 'f (MHz)' );
  ylabel( 'SE (dB)' );
  legend( 'Normal - emPlanarSE' , 'Normal - emMutliRefAniso' , 'Normal - emMutliRef' );
  print( 'emTestMultiRefAniso2-se_10kSm.eps' , '-depsc2' );
  hold off;
  close();
  
  %
  % Check against MultiRef.
  %

  thick1 = 0.5e-3;
  thick2 = 2e-3;
  eps_r1 = 10.0;
  eps_r2 = 40.0;
  sig1   = 0.1;
  sig2   = 1.0;
  mu_r1  = 1.0;
  mu_r2  = 1.0;

  f = 1e6 .* logspace( 0 , 5 , 200 );

  [ S1 ] = emMultiRefAniso( f , 0.0 , [thick1, thick2] , [0.0,0.0] , 1.0 , 1.0 , [eps_r1,eps_r2] , [sig1,sig2] , [mu_r1,mu_r2] , 'S' );
  [ S2 ] = emMultiRef( f , eta0, eta0 , [eps_r1;eps_r2] , [sig1;sig2] , [mu_r1;mu_r2] , [0.0;0.0] , [thick1,thick2] , 'S' );

  isPass = isPass && isValid( S1(1:2,1:2,:)  , S2 );
  isPass = isPass && isValid( S1(3:4,3:4,:)  , S2 );

  figure();
  semilogx( f / 1e6 , -db20( squeeze( S1(1,2,:) ) ) , 'r-' );
  hold on;
  semilogx( f / 1e6 , -db20( squeeze( S2(1,2,:) ) ) , 'r*' );
  xlabel( 'f (MHz)' );
  ylabel( 'S12 (dB)' );
  legend( 'Normal - emMutliRefAniso' , 'Normal - emMutliRef' );
  print( 'emTestMultiRefAniso2-twolayer.eps' , '-depsc2' );
  hold off;
  close();
  
  %
  % Check against FresnelCoeff.
  %

  thick1 = 2.0;
  eps_r1 = 10.0;
  sig1   = 0.1;
  mu_r1  = 1.0;

  f = 100e6;
  epsc_r1 = eps_r1 + sig1 / ( j * 2 * pi * f * eps0 );
  na = 1.0;
  nb = sqrt( epsc_r1 * mu_r1);
  theta = linspace( 0.1 , pi/2-0.1 , 40 );

  [ rhoTE , rhoTM , tauTE , tauTM ] = emFresnelCoeff( na , nb , theta );

  for k=1:length( theta )
    [ S1 ] = emMultiRefAniso( f , 180*theta(k)/pi , [thick1] , [0.0] , 1.0 , 1.0 , [eps_r1] , [sig1] , [mu_r1] , 'S' );
    rhoTMb(k) = squeeze( S1(1,1,1) ); 
    rhoTEb(k) = squeeze( S1(3,3,1) );
  end % for

  isPass = isPass && isValid( rhoTM , rhoTMb );
  isPass = isPass && isValid( rhoTE , rhoTEb );

  figure();
  plot( 180 * theta / pi , db20( rhoTE ) , 'r-' );
  hold on;
  plot( 180 * theta / pi , db20( rhoTM ) , 'b-' );
  plot( 180 * theta / pi , db20( rhoTEb ) , 'ro' );
  plot( 180 * theta / pi , db20( rhoTMb ) , 'b*' );
  xlabel( 'Angle of Incidence (degrees)' );
  ylabel( 'Reflection Coefficient (dB)' );
  legend( 'emFresnelCoeff - TE' , 'emFresnelCoeff - TM' , 'emMultiRefAniso - TE ' , 'emMultiRefAniso - TM');
  print( 'emTestMultiRefAniso2-fresnel.eps' , '-depsc2' );
  hold off;
  close();
  
end % function
