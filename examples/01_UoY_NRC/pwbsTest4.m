
f = logspace( log10( 1e9 ) , log10( 19e9 ) , 100 );

% Large RC dimensions.
a_RC = 2.37;
b_RC = 3.00;
c_RC = 4.70;

% Large RC wall condictivity.
sigma_eff_RC = 0.16e6;
mu_r_RC = 1.0;

% Small RC dimensions.
a_NRC = 0.6;
b_NRC = 0.7;
c_NRC = 0.8;

% Small RC wall condictivity.
sigma_eff_NRC = 0.35e6;
mu_r_NRC = 1.0;

% Electrically medium (resonant) 1-20 GHz.
radius = 0.008;

pwbm = pwbsInitModel( f , 'Test4' );
pwbm = pwbsAddCavity( pwbm , 'RC' , 'Cuboid'  , { a_RC , b_RC , c_RC , sigma_eff_RC , mu_r_RC } );
pwbm = pwbsAddCavity( pwbm , 'NRC' , 'Cuboid'  , { a_NRC , b_NRC , c_NRC , sigma_eff_NRC , mu_r_NRC } );
pwbm = pwbsAddAperture( pwbm , 'A1' , 'RC' , 'NRC' , 1 , 'Circular' , { radius } );
pwbm = pwbsAddAntenna( pwbm , 'Tx' , 'RC' , 1 , 'Matched' , { 50.0 } );
pwbm = pwbsAddAntenna( pwbm , 'Rx_RC' , 'RC' , 1 , 'Matched' , { 50.0 } );
pwbm = pwbsAddAntenna( pwbm , 'Rx_NRC' , 'NRC' , 1 , 'Matched' , { 50.0 } );
pwbm = pwbsAddSource( pwbm , 'S1' , 'Antenna' , 'Tx' , { 1 } );
% pwbm = pwbsAddAbsorber( pwbm , 'Cube110' , 'RC' , 'Sphere' , { [ 76e-3 ] , eps_r_LS22 , sigma_LS22 } );

pwbm = pwbsSolveModel( pwbm );

pwbsExportAll( pwbm );
pwbsDrawEMT( pwbm )

data = pwbsGetOutput( pwbm , 'Cavity' , 'RC' , { 'wallACS' , 'totalACS' , 'totalQ' , 'numModes' , 'modeDensity' , ...
                                                 'modeBandwidth' , 'specificModeDensity' , 'f_Schroeder' , 'totalDecayRate' , ...
                                                 'wallQ' } );
ACS_walls_RC = data{1};
ACS_total_RC = data{2};
Q_total_RC = data{3};
N_M_RC = data{4};
n_M_RC = data{5};
df_MB_RC = data{6};
M_s_RC = data{7};
f_Schroeder_RC = data{8};
tau_RC = data{9};
Q_walls_RC = data{10};

data = pwbsGetOutput( pwbm , 'Cavity' , 'NRC' , { 'wallACS' , 'totalACS' , 'totalQ' , 'numModes' , 'modeDensity' , ...
                                                 'modeBandwidth' , 'specificModeDensity' , 'f_Schroeder' , 'totalDecayRate' , ...
                                                 'wallQ' } );
ACS_walls_NRC = data{1};
ACS_total_NRC = data{2};
Q_total_NRC = data{3};
N_M_NRC = data{4};
n_M_NRC = data{5};
df_MB_NRC = data{6};
M_s_NRC = data{7};
f_Schroeder_NRC = data{8};
tau_NRC = data{9};
Q_walls_NRC = data{10};

data = pwbsGetOutput( pwbm , 'Antenna' , 'Tx' , { 'ACS' , 'absorbedPower' , 'Q' } );
ACS_Tx_RC = data{1};
Pa_Tx_RC = data{2};
Q_Tx_RC = data{3};

data = pwbsGetOutput( pwbm , 'Antenna' , 'Rx_RC' , { 'ACS' , 'absorbedPower' , 'Q' } );
ACS_Rx_RC = data{1};
Pa_Rx_RC = data{2};
Q_Rx_RC= data{3};

data = pwbsGetOutput( pwbm , 'Antenna' , 'Rx_NRC' , { 'ACS' , 'absorbedPower' , 'Q' } );
ACS_Rx_NRC = data{1};
Pa_Rx_NRC = data{2};
Q_Rx_NRC= data{3};

data = pwbsGetOutput( pwbm , 'Aperture' , 'A1' , { 'TCS' , 'f_c' } );
sigma_t = data{1};
f_c_medium = data{2};
 



IL_RC = 1.0 ./ Pa_Rx_RC;
IL_NRC = 1.0 ./ Pa_Rx_NRC;
SR = IL_NRC ./ IL_RC;

db10=@(x) 10.0 .* log10( x );

figure();
hl1 = loglog( f / 1e9 , Q_total_RC , 'r-' );
hold on;
hl2 = loglog( f / 1e9 , Q_total_NRC , 'b-' );
xlim( [ 1 , 20 ] );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Q-factor, Q (-)' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
hold off;

figure();
hl1 = loglog( f /1e9 , N_M_RC , 'r-' );
hold on;
hl2 = loglog( f /1e9 , N_M_NRC , 'b-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Cumulative number of modes, N_M (-)' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
hold off;

figure( 3 );
hl1 = loglog( f /1e9 , n_M_RC * 1e6 , 'r-' );
hold on;
hl2 = loglog( f /1e9 , n_M_NRC * 1e6 , 'b-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Mode density , n_M (MHz^{-1})' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
hold off;

figure();
hl1 = loglog( f / 1e9 , M_s_RC , 'r-' );
hold on;
hl2 = loglog( f / 1e9 , M_s_NRC , 'b-' );
hl3 = loglog( f / 1e9 , 3 .* ones( size( f ) ) , 'g-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Specific mode density , M_s (-)' );
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
hold off;

figure();
hl1 = loglog( f / 1e9 , df_MB_RC / 1e6 , 'r-' );
hold on;
hl2 = loglog( f / 1e9 , df_MB_NRC / 1e6 , 'b-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Mode bandwidth (MHz)' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , ...
              'NRC' , ...
              'location' , 'southeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
set( gca , 'YTickLabel' , num2str( get( gca , 'YTick' )' ) );
hold off;

figure();
hl1 = loglog( f / 1e9 , ACS_walls_RC , 'r-' );
hold on;
hl2 = loglog( f / 1e9 , ACS_Tx_RC , 'b-' );
hl3 = loglog( f / 1e9 , ACS_Rx_RC , 'g-' );
hl4 = loglog( f / 1e9 , ACS_total_RC , 'c-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Absorption cross-section, <\sigma> (m^2)' );
hlg = legend( [ hl1 , hl2 , hl3 , hl4 ] , 'Walls' , 'Tx antenna' , 'Rx antenna' , 'Total' , 'location' , 'southwest' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
hold off;

figure();
hl1 = loglog( f / 1e9 , ACS_walls_NRC , 'r-' );
hold on;
hl3 = loglog( f / 1e9 , ACS_Rx_NRC , 'g-' );
hl4 = loglog( f / 1e9 , ACS_total_NRC , 'c-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Absorption cross-section, <\sigma> (m^2)' );
hlg = legend( [ hl1 , hl3 , hl4 ] , 'Walls' , 'Rx antenna' , 'Total' , 'location' , 'southwest' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
set( gca , 'YMinorTick' , 'on' , 'YMinorGrid', 'on' );
hold off;

figure();
hl1 = semilogx( f / 1e9 , db10( IL_RC ) , 'r-' );
hold on;
hl2 = semilogx( f / 1e9 , db10( IL_NRC ) , 'b-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average insertion gain, <IL> (dB)' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , 'NRC' , ...
              'location' , 'northeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
hold off;

figure();
hl1 = semilogx( f / 1e9 , tau_RC / 1e-6 , 'r-' );
hold on;
hl2 = semilogx( f / 1e9 , tau_NRC / 1e-6 , 'b-' );
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Time constant (us)' );
hlg = legend( [ hl1 , hl2 ] , ...
              'RC' , 'NRC' , ...
              'location' , 'northeast' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
hold off;

figure();
hl1 = semilogx( f / 1e9 , db10( SR ) , 'r-' );
hold on;
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average relative shielding ratio, <SR_{i;r}> (dB)' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
hold off;

figure(); 
hl1 = loglog( f / 1e9 , sigma_t , 'r-' );
hold on;
hxl = xlabel( 'Frequency (GHz)' );
hyl = ylabel( 'Average tranmission cross-section, ,<\sigma^t_h> (m^2)' );
xlim( [ 1  20 ] );
set( gca , 'XMinorTick' , 'on' , 'XMinorGrid', 'on' );
set( gca , 'XTickLabel' , num2str( get( gca , 'XTick' )' ) );
hold off;
