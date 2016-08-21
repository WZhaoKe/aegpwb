
%graphics_toolkit ('gnuplot');

[ c0 , eps0 , mu0 , eta0 ] = emConst();

%f = logspace( log10( 1e9 ) , log10( 19e9 ) , 5000 );
f = linspace( 5e9 , 15e9 , 10001 );
%f = linspace( 1e9 , 20e9 , 200001 );

w = 2 * pi .* f;
lambda = c0 ./ f;
df = f(2) - f(1);

% Number of paddle steps.
N_step = 400 .* ones( size( f ) );

% Frequency stirring bandwidth.
df_FS = 100e6;

% Whether to limit statistical bandwidth to measurement parameters.
%isLimitSB = false;
isLimitSB = true;

% Chamber dimensions.
a_RC = 2.37;
b_RC = 3.00;
c_RC = 4.70;
a_NRC = 0.6;
b_NRC = 0.7;
c_NRC = 0.8;

% Stirrer dimensions
h_s_RC = 2.00;
r_s_RC = 1.00;
h_s_NRC = 0.30;
r_s_NRC = 0.26;

% Effective condictivity of walls.
sigma_eff_RC = 0.16e6;
sigma_eff_NRC = 0.35e6;

% Measured Q data.
dataQRC = readDataFile( 'RC_Q_meas.dat' );
Q_total_meas_RC = interp1( dataQRC(:,1) , dataQRC(:,2) , f );
dataQNRC = readDataFile( 'NRC_Q_meas.dat' );
Q_total_meas_NRC = interp1( dataQNRC(:,1) , dataQNRC(:,2) , f );

% Chamber model - effective conductivity.
[ N_M_RC , n_M_RC , ACS_walls_RC , ACS_Tx_RC , ACS_Rx_RC , ACS_total_RC , ...
  Q_walls_RC , Q_Tx_RC , Q_Rx_RC , Q_total_RC , G_Rx_RC , G_Tx_RC , tau_RC , ...
  df_MB_RC , M_s_RC , f_Schroeder_RC ] = rcChamberModel( f , a_RC , b_RC , c_RC , sigma_eff_RC );
[ N_M_NRC , n_M_NRC , ACS_walls_NRC , ACS_Tx_NRC , ACS_Rx_NRC , ACS_total_NRC , ...
  Q_walls_NRC , Q_Tx_NRC , Q_Rx_NRC , Q_total_NRC , G_Rx_NRC , G_Tx_NRC , tau_NRC , ...
  df_MB_NRC , M_s_NRC , f_Schroeder_NRC ] = rcChamberModel( f , a_NRC , b_NRC , c_NRC , sigma_eff_NRC );
  
% Mode stirring efficiency.
[ N_ind_RC , N_ind_MS_RC , N_ind_FS_RC , f_MS_200_RC , df_CB_RC ] = ...
  rcStirringEfficiency( f , a_RC , b_RC , c_RC , h_s_RC , r_s_RC , Q_total_RC , df_FS );
[ N_ind_NRC , N_ind_MS_NRC , N_ind_FS_NRC , f_MS_200_NRC , df_CB_NRC ] = ...
  rcStirringEfficiency( f , a_NRC , b_NRC , c_NRC , h_s_NRC , r_s_NRC , Q_total_NRC , df_FS );  

if( isLimitSB )
  N_ind_MS_RC = ( N_ind_MS_RC < N_step ) .*  N_ind_MS_RC + ( N_ind_MS_RC >= N_step ) .* N_step;
  N_ind_FS_RC = ( df_CB_RC < df ) .* ( df_FS ./ df ) + ( df_CB_RC >= df ) .* ( df_FS ./ df_CB_RC );
  N_ind_RC = N_ind_MS_RC .* N_ind_FS_RC;
  N_ind_MS_NRC = ( N_ind_MS_NRC < N_step ) .*  N_ind_MS_NRC + ( N_ind_MS_NRC >= N_step ) .* N_step;
  N_ind_FS_NRC = ( df_CB_NRC < df ) .* ( df_FS ./ df ) + ( df_CB_NRC >= df ) .* ( df_FS ./ df_CB_NRC );
  N_ind_NRC = N_ind_MS_NRC .* N_ind_FS_NRC;  
end % if

%
% Proposed measurement
%

% Aperture radius. 

% Electrically small 1-20 GHz.
radius_small = 0.002;

% Electrically medium (resonant) 1-20 GHz.
radius_medium = 0.008;

% Electrically large 1-20 GHz.
radius_large = 0.050;

% OUT ACS.
ACS_OUT = 1e-2;

% Number of indepenent samples? 
N_ind = min( [ N_ind_RC ; N_ind_NRC ] , [] , 1 );

[ sigma_t_small , f_c_small ] = pwbCircularAperture2( f , radius_small );
D_loaded_small = ( ACS_total_RC + sigma_t_small ) .* ( ACS_total_NRC + ACS_OUT + sigma_t_small ) - sigma_t_small.^2;
IL_RC_small_loaded = 4.0 .* pi .* D_loaded_small ./ lambda.^2 ./ ( ACS_total_NRC + ACS_OUT + sigma_t_small );
IL_NRC_small_loaded = 4.0 .* pi .* D_loaded_small ./ lambda.^2 ./ sigma_t_small;
D_unloaded_small = ( ACS_total_RC + sigma_t_small ) .* ( ACS_total_NRC + sigma_t_small ) - sigma_t_small.^2;
IL_RC_small_unloaded = 4.0 .* pi .* D_unloaded_small ./ lambda.^2 ./ ( ACS_total_NRC + sigma_t_small );
IL_NRC_small_unloaded = 4.0 .* pi .* D_unloaded_small ./ lambda.^2 ./ sigma_t_small;
SR_loaded_small = IL_NRC_small_loaded ./ IL_RC_small_loaded;
SR_unloaded_small = IL_NRC_small_unloaded ./ IL_RC_small_unloaded;
ACS_small = sigma_t_small .* ( SR_loaded_small - SR_unloaded_small );
assert( all( abs( ACS_small - ACS_OUT ) < 10 * eps  ) );
SR_REF_small = 1 + ( ACS_total_NRC ) ./ sigma_t_small;
SR_OUT_small = 1 + ( ACS_total_NRC + ACS_OUT ) ./ sigma_t_small;
SR_rel_small = SR_OUT_small ./ SR_REF_small;
CV_ACS_OUT_small = sqrt( 2 ./ N_ind ) .* sqrt( SR_rel_small.^2 + 1 ) ./ ( SR_rel_small - 1 ); 

[ sigma_t_medium , f_c_medium ] = pwbCircularAperture2( f , radius_medium );
D_loaded_medium = ( ACS_total_RC + sigma_t_medium ) .* ( ACS_total_NRC + ACS_OUT + sigma_t_medium ) - sigma_t_medium.^2;
IL_RC_medium_loaded = 4.0 .* pi .* D_loaded_medium ./ lambda.^2 ./ ( ACS_total_NRC + ACS_OUT + sigma_t_medium );
IL_NRC_medium_loaded = 4.0 .* pi .* D_loaded_medium ./ lambda.^2 ./ sigma_t_medium;
D_unloaded_medium = ( ACS_total_RC + sigma_t_medium ) .* ( ACS_total_NRC + sigma_t_medium ) - sigma_t_medium.^2;
IL_RC_medium_unloaded = 4.0 .* pi .* D_unloaded_medium ./ lambda.^2 ./ ( ACS_total_NRC + sigma_t_medium );
IL_NRC_medium_unloaded = 4.0 .* pi .* D_unloaded_medium ./ lambda.^2 ./ sigma_t_medium;
SR_loaded_medium = IL_NRC_medium_loaded ./ IL_RC_medium_loaded;
SR_unloaded_medium = IL_NRC_medium_unloaded ./ IL_RC_medium_unloaded;
ACS_medium = sigma_t_medium .* ( SR_loaded_medium - SR_unloaded_medium );
assert( all( abs( ACS_medium - ACS_OUT ) < 10 * eps  ) );
SR_REF_medium = 1 + ( ACS_total_NRC ) ./ sigma_t_medium;
SR_OUT_medium = 1 + ( ACS_total_NRC + ACS_OUT ) ./ sigma_t_medium;
SR_rel_medium = SR_OUT_medium ./ SR_REF_medium;
CV_ACS_OUT_medium = sqrt( 2 ./ N_ind ) .* sqrt( SR_rel_medium.^2 + 1 ) ./ ( SR_rel_medium - 1 ); 

[ sigma_t_large , f_c_large ] = pwbCircularAperture2( f , radius_large );
D_loaded_large = ( ACS_total_RC + sigma_t_large ) .* ( ACS_total_NRC + ACS_OUT + sigma_t_large ) - sigma_t_large.^2;
IL_RC_large_loaded = 4.0 .* pi .* D_loaded_large ./ lambda.^2 ./ ( ACS_total_NRC + ACS_OUT + sigma_t_large );
IL_NRC_large_loaded = 4.0 .* pi .* D_loaded_large ./ lambda.^2 ./ sigma_t_large;
D_unloaded_large = ( ACS_total_RC + sigma_t_large ) .* ( ACS_total_NRC + sigma_t_large ) - sigma_t_large.^2;
IL_RC_large_unloaded = 4.0 .* pi .* D_unloaded_large ./ lambda.^2 ./ ( ACS_total_NRC + sigma_t_large );
IL_NRC_large_unloaded = 4.0 .* pi .* D_unloaded_large ./ lambda.^2 ./ sigma_t_large;
SR_loaded_large = IL_NRC_large_loaded ./ IL_RC_large_loaded;
SR_unloaded_large = IL_NRC_large_unloaded ./ IL_RC_large_unloaded;
ACS_large = sigma_t_large .* ( SR_loaded_large - SR_unloaded_large );
assert( all( abs( ACS_large - ACS_OUT ) < 10 * eps  ) );
SR_REF_large = 1 + ( ACS_total_NRC ) ./ sigma_t_large;
SR_OUT_large = 1 + ( ACS_total_NRC + ACS_OUT ) ./ sigma_t_large;
SR_rel_large = SR_OUT_large ./ SR_REF_large;
CV_ACS_OUT_large = sqrt( 2 ./ N_ind ) .* sqrt( SR_rel_large.^2 + 1 ) ./ ( SR_rel_large - 1 ); 

% Chamber model - measured Q.
[ ~ , ~ , ACS_walls_meas_NRC , ~ , ~ , ACS_total_meas_NRC , Q_walls_meas_NRC , ~ , ~ , Q_total_meas_NRC , ...
  ~ , ~ , tau_meas_NRC , df_MB_meas_NRC , M_s_meas_NRC , f_Schroeder_meas_NRC ] = rcChamberModel2( f , a_NRC , b_NRC , c_NRC , Q_total_meas_NRC );
[ ~ , ~ , ACS_walls_meas_RC , ~ , ~ , ACS_total_meas_RC , Q_walls_meas_RC , ~ , ~ , Q_total_meas_RC , ...
  ~ , ~ , tau_meas_RC , df_MB_meas_RC , M_s_meas_RC , f_Schroeder_meas_RC ] = rcChamberModel2( f , a_RC , b_RC , c_RC , Q_total_meas_RC );
  
%  % Mode stirring efficiency.
%  [ N_ind_meas , N_ind_MS_meas , N_ind_FS_meas , f_MS_200_meas , df_CB_meas ] = rcStirringEfficiency( f_meas , a , b , c , h_s , r_s , Q_total_meas , df_FS );
%  
%  if( isLimitSB )
%    N_ind_MS_meas = ( N_ind_MS_meas < N_step_meas ) .*  N_ind_MS_meas + ( N_ind_MS_meas >= N_step_meas ) .* N_step_meas;
%    N_ind_FS_meas = ( df_CB_meas < df_meas ) .* ( df_FS ./ df_meas ) + ( df_CB_meas >= df_meas ) .* ( df_FS ./ df_CB_meas );
%    N_ind_meas = N_ind_MS_meas .* N_ind_FS_meas;
%  end % if

%
% Plots.
%

figure( 1 );
hl1 = loglog( f / 1e9 , Q_total_RC );
hold on;
hl2 = loglog( f / 1e9 , Q_total_NRC );
hl3 = loglog( f / 1e9 , Q_total_meas_RC );
hl4 = loglog( f / 1e9 , Q_total_meas_NRC );
xlim( [ 1 , 20 ] );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Q-factor, Q (-)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 ] , ...
              'RC model' , ...
              'NRC model' , ...
              'RC measurement' , ...
              'NRC measurement' , ...
              'location' , 'southeast' );
hti = [];%title( sprintf( 'UOY RC: Contributions to the total Q-factor, \\sigma_{eff} = %g MS/m' , sigma / 1e6 ) );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 );
printFigure( 'UoY_NRC_Q_total' );
hold off;

figure( 2 );
hl1 = loglog( f /1e9 , N_M_RC );
hold on;
hl2 = loglog( f /1e9 , N_M_NRC );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Cumulative number of modes, N_M (-)' );
hti = []; %title( 'UOY RC: Number of modes' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 );
printFigure( 'UoY_NRC_NN_M' );
hold off;

figure( 3 );
hl1 = loglog( f /1e9 , n_M_RC * 1e6 );
hold on;
hl2 = loglog( f /1e9 , n_M_NRC * 1e6 );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Mode density , n_M (MHz^{-1})' );
hti = []; %title( 'UOY RC: Mode density' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 );
printFigure( 'UoY_NRC_n_M' );
hold off;

figure( 4 );
hl1 = loglog( f / 1e9 , M_s_RC );
hold on;
hl2 = loglog( f / 1e9 , M_s_NRC );
hl3 = loglog( f / 1e9 , 3 .* ones( size( f ) ) );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Specific mode density , M_s (-)' );
hti = []; %title( sprintf( 'UOY RC: Specific mode density: f_{SCH}=%.1f GHz' , f_Schroeder / 1e9 ) );
hlg = legend( [ hl1 , hl2 , hl3 ] , ...
              'RC' , ...
              'NRC' , ...
              'Schroeder criterion, M_s = 3' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );              
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 );
printFigure( 'UoY_NRC_M_s' );
hold off;

figure( 5 );
hl1 = loglog( f / 1e9 , df_MB_RC / 1e6 );
hold on;
hl2 = loglog( f / 1e9 , df_MB_NRC / 1e6 );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Mode bandwidth (MHz)' );
hti = []; %title( 'UOY RC: Mode bandwidth' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 );
printFigure( 'UoY_NRC_MB' );
hold off;

figure( 6 );
hl1 = loglog( f /1e9 , N_ind_MS_RC );
hold on;
hl2 = loglog( f /1e9 , N_ind_MS_NRC );
hl3 = loglog( f /1e9 , N_ind_FS_RC );
hl4 = loglog( f /1e9 , N_ind_FS_NRC );
hl5 = loglog( f /1e9 , N_ind_RC );
hl6 = loglog( f /1e9 , N_ind_NRC );
%hl3 = loglog( f /1e9 , N_ind_FS_meas );
%hl4 = loglog( f /1e9 , N_ind_meas );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Number of independent samples, N_{ind} (-)' );
hti = []; %title( 'UOY RC: Number of independent samples' );
hlg = legend( 'RC, N_{ind;MS}' , ...
              'NRC, N_{ind;MS}' , ...
              sprintf( 'RC, N_{ind;FS} (\\Deltaf_{FS} = %.0f MHz)' , df_FS / 1e6 ) , ...
              sprintf( 'NRC, N_{ind;FS} (\\Deltaf_{FS} = %.0f MHz)' , df_FS / 1e6 ) , ...              
              'RC, N_{ind}' , ...
              'NRC, N_{ind}' , ...              
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 , hl6 );
printFigure( 'UoY_NRC_Nind' );
hold off;

figure( 7 );
hl1 = loglog( f / 1e9 , ACS_walls_RC );
hold on;
hl2 = loglog( f / 1e9 , ACS_Tx_RC );
hl3 = loglog( f / 1e9 , ACS_Rx_RC );
hl4 = loglog( f / 1e9 , ACS_total_RC );
hl5 = loglog( f / 1e9 , ACS_total_meas_RC );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Absorption cross-section, <\sigma> (m^2)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 , hl5 ] , 'Walls' , 'Tx antenna' , 'Rx antenna' , 'Total' , 'Total, measured' , 'location' , 'southwest' );
hti = [];%title( 'UOY RC: Contributions to the total absorption cross-section' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 );
printFigure( 'UoY_RC_ACS' );
hold off;

figure( 8 );
hl1 = loglog( f / 1e9 , ACS_walls_NRC );
hold on;
hl2 = loglog( f / 1e9 , ACS_Tx_NRC );
hl3 = loglog( f / 1e9 , ACS_Rx_NRC );
hl4 = loglog( f / 1e9 , ACS_total_NRC );
hl5 = loglog( f / 1e9 , ACS_total_meas_NRC );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Absorption cross-section, <\sigma> (m^2)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 , hl5 ] , 'Walls' , 'Tx antenna' , 'Rx antenna' , 'Total' , 'Total, measured' , 'location' , 'southwest' );
hti = [];%title( 'UOY RC: Contributions to the total absorption cross-section' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 );
printFigure( 'UoY_NRC_ACS' );
hold off;

figure( 9 );
hl1 = semilogx( f / 1e9 , db10( IL_NRC_small_loaded ) );
hold on;
hl2 = semilogx( f / 1e9 , db10( IL_NRC_small_unloaded ) );
hl3 = semilogx( f / 1e9 , db10( IL_NRC_medium_loaded ) );
hl4 = semilogx( f / 1e9 , db10( IL_NRC_medium_unloaded ) );
hl5 = semilogx( f / 1e9 , db10( IL_NRC_large_loaded ) );
hl6 = semilogx( f / 1e9 , db10( IL_NRC_large_unloaded ) );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average insertion loss, <IL> (dB)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 , hl5 ,hl6 ] , ...
              sprintf( '<IL_{i;o}>_{loaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<IL_{i;o}>_{unloaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<IL_{i;o}>_{loaded}, r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( '<IL_{i;o}>_{unloaded}, r_h = %.1f mm' , radius_medium / 1e-3  ) , ...
              sprintf( '<IL_{i;o}>_{loaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...
              sprintf( '<IL_{i;o}>_{unloaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...              
              'location' , 'northeast' );
hti = []; %itle( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
axis( [ 1  20 0 150 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 , hl6 );
printFigure( 'UoY_NRC_IL' );
hold off;

figure( 10 );
hl1 = semilogx( f / 1e9 , db10( IL_RC_small_loaded ) );
hold on;
hl2 = semilogx( f / 1e9 , db10( IL_RC_small_unloaded ) );
hl3 = semilogx( f / 1e9 , db10( IL_RC_medium_loaded ) );
hl4 = semilogx( f / 1e9 , db10( IL_RC_medium_unloaded ) );
hl5 = semilogx( f / 1e9 , db10( IL_RC_large_loaded ) );
hl6 = semilogx( f / 1e9 , db10( IL_RC_large_unloaded ) );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average insertion loss, <IL> (dB)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 , hl5 ,hl6 ] , ...
              sprintf( '<IL_{o;o}>_{loaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<IL_{o;o}>_{unloaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<IL_{o;o}>_{loaded}, r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( '<IL_{o;o}>_{unloaded}, r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( '<IL_{o;o}>_{loaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...
              sprintf( '<IL_{o;o}>_{unloaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...              
              'location' , 'northeast' );
hti = [] ;%title( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
axis( [ 1  20 0 120 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 , hl6 );
printFigure( 'UoY_RC_IL' );
hold off;

figure( 11 );
hl1 = semilogx( f / 1e9 , db10( SR_loaded_small ) );
hold on;
hl2 = semilogx( f / 1e9 , db10( SR_unloaded_small ) );
hl3 = semilogx( f / 1e9 , db10( SR_loaded_medium ) );
hl4 = semilogx( f / 1e9 , db10( SR_unloaded_medium ) );
hl5 = semilogx( f / 1e9 , db10( SR_loaded_large ) );
hl6 = semilogx( f / 1e9 , db10( SR_unloaded_large ) );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average shielding ratio, <SR> (dB)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 , hl5 ,hl6 ] , ...
              sprintf( '<SR_i>_{loaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<SR_i>_{unloaded}, r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( '<SR_i>_{loaded}, r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( '<SR_i>_{unloaded}, r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( '<SR_i>_{loaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...
              sprintf( '<SR_i>_{unloaded}, r_h = %.1f mm' , radius_large / 1e-3 ) , ...              
              'location' , 'northeast' );
hti = [] ; %title( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 , hl4 , hl5 , hl6 );
printFigure( 'UoY_SR' );
hold off;

figure( 12 );
hl1 = semilogx( f / 1e9 , db10( SR_rel_small ) );
hold on;
hl2 = semilogx( f / 1e9 , db10( SR_rel_medium ) );
hl3 = semilogx( f / 1e9 , db10( SR_rel_large ) );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average relative shielding ratio, <SR_{i;r}> (dB)' );
hlg = legend( [ hl1 , hl2 , hl3 ] , ...
              sprintf( 'r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( 'r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( 'r_h = %.1f mm' , radius_large / 1e-3 ) , ...           
              'location' , 'northeast' );
hti = [] ; % title( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 );
printFigure( 'UoY_NRC_SR_rel' );
hold off;

figure( 13 );
hl1 = semilogx( f / 1e9 , 100 .* CV_ACS_OUT_small );
hold on;
hl2 = semilogx( f / 1e9 , 100 .* CV_ACS_OUT_medium );
hl3 = semilogx( f / 1e9 , 100 .* CV_ACS_OUT_large );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Uncertainty in average ACS, CV[<\sigma^a_{OUT}>] (%)' );
hlg = legend( [ hl1 , hl2 , hl3 ] , ...
              sprintf( 'r_h = %.1f mm' , radius_small / 1e-3 ) , ...
              sprintf( 'r_h = %.1f mm' , radius_medium / 1e-3 ) , ...
              sprintf( 'r_h = %.1f mm' , radius_large / 1e-3 ) , ...             
              'location' , 'northeast' );
hti = [] ; % title( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 );
printFigure( 'UoY_NRC_CV' );
hold off;

figure( 14 );
xSR = logspace( log10( 1 ) , log10( 10 ) , 100 );
hl1 = loglog( xSR  , sqrt( xSR.^2 + 1 ) ./ ( xSR - 1 )  );
hold on;
hyl = ylabel( '(N_{ind}/2)^{1/2} CV[<\sigma^a_{OUT}>] (-)' );
hxl = xlabel( 'Average relative shielding ratio, <SR_{i;r}> (-)' );
hlg = [];
hti = [];
%xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 );
printFigure( 'UoY_NRC_CV_v_SR_rel' );
hold off;

figure( 15 ); 
hl1 = loglog( f / 1e9 , sigma_t_small );
hold on;
hl2 = loglog( f / 1e9 , sigma_t_medium );
hl3 = loglog( f / 1e9 , sigma_t_large );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average tranmission cross-section, ,<\sigma^t_h> (m^2)' );
hlg = legend( [ hl1 , hl2 , hl3 ] , ...
              sprintf( 'r_h = %.1f mm, f_{ap} = %.2f GHz' , radius_small / 1e-3 , f_c_small / 1e9 ) , ...
              sprintf( 'r_h = %.1f mm, f_{ap} = %.2f GHz' , radius_medium / 1e-3 , f_c_medium / 1e9 ) , ...
              sprintf( 'r_h = %.1f mm, f_{ap} = %.2f GHz' , radius_large / 1e-3 , f_c_large / 1e9 ) , ...         
              'location' , 'southeast' );
hti = [] ; % title( sprintf( 'OUT ACS %g m^2' , ACS_OUT ) );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
%set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
%set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
plotDefaults( gca , gcf , hti , hxl , hyl , hlg , hl1 , hl2 , hl3 );
printFigure( 'UoY_TCS' );
hold off;
