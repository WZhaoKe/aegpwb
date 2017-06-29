function pwbTestTwoWireLineDiameter1()

  [ c0 , eps0 , mu0 , eta0 ] = emConst();

  f = linspace( 10e6 , 3e9 , 200)';
  lambda = c0 ./ f;

  E_0 = 1.0;
  length = 40e-2;
  spacing = 10e-3;
  diameter = 1e-3;
  R_1 = 359;
  R_2 = 359;

  S_inc = 0.5 * E_0^2 / eta0;

  [ ACS , ACS_1 , ACS_2 ] = pwbTwoWireLineDiameter( f , length , spacing , diameter , 1 , R_1 , R_2 );

  Pa_1 = ACS_1 .* S_inc;
  I_1_squared = 2.0 .* Pa_1 ./ R_1;
  
  figure();
  plot( length  ./ lambda  , I_1_squared , 'r-' );
  hold on;
  plot( length  ./ lambda  , I_1_squared , 'b-' );
  xlabel( 'Line length, l / \lambda (-)'  );
  ylabel( '<|I(0)|^2> (A^2)' );
  xlim( [ 0 , 2 ] );
  ylim( [ 0 , 3e-10 ] );
  grid( 'on' );
  print( '-depsc2' , 'pwbTestTwoWireLineDiameter1.eps' );
  hold off;
  
end % function
