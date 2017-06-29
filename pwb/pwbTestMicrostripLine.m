function pwbTestMicrostripLine()

  f = logspace( log10( 20e6 ) , log10( 20e9 ) , 400 )';
  
  w = 2.0 .* pi .* f;
  
  height = 2.4e-3;
  width = 1e-3;
  thickness = 35e-6;
  length = 60e-3;
  eps_r = 4.2;

  [ Z_c , eps_r_eff , vp ] = tlModelMicroStrip( f , width , height , eps_r , thickness );
  Z_0 = Z_c;
  Z_l = Z_c;
  
  [ ACS_LS ] = pwbMicrostripLineLS( f , length , width , height , eps_r , thickness , 4*Z_0 , 2* Z_l );
  [ ACS_MV ] = pwbMicrostripLineMV( f , length , width , height , eps_r , thickness , 4*Z_0 , 2*Z_l );
  
  figure();
  loglog( f ./ 1e9 , ACS_MV , 'r-' );
  hold on;
  loglog( f ./ 1e9 , ACS_LS , 'b-' );  
  xlabel( 'Frequency (GHz)' );
  ylabel( 'Average absorption cross-section, <\sigma^a> (m^2)' ); 
  legend( 'Magdowski \& Vick, equivalent TWL' , ...
          'Leone \& Singer, microstrip, GLQ' , ...           
          'location' , 'southeast' );
  legend( 'boxoff' );
  xlim( [ 0.02 , 20 ] );
  set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
  set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
  set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
  %set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
  print( '-depsc2' , 'pwbTestMicrostripLine.eps' );
  hold off;

end % function
