function [ Zc , eps_r_eff , vp , ad , ac ] = ...
  tlModelMicroStrip( f , width , height , eps_r , thickness , lossTangent , sigma )
%
% [ zc , eps_eff , vp , ad , ac ] = tlModelMicroStrip( f , width , height , ...
%                                    eps_r [, thickness [ , lossTanget [ , sigma ] ] ] )
%
% Calculate the impedance and effective dielectric constant of 
% microstrip transmission line using the empirical design 
% equations in [1].
%
% f            - real vector, frequency [Hz].
% width        - width of microstrip line [m].
% height       - substrate height thickness [m].
% eps_r        - relative permittivity of substrate [-]. 
% thickness    - thickness of metalisation [m].
%                Default: zero thickness.
% lossTangent  - loss tangent of substrate [-].
%                Default is lossless substrate.
% sigma        - conductivity of metalisation [S/m].
%                Dwfault is PEC.
%
% Outputs:
%
% Zc        - characteristic impedance of line [ohms].
% eps_r_eff - effective relative permittivity of line [-].
% vp        - phase velocity on line [m/s].
%
% References:
%
% [1] Advanced Engineering Electromagnetics, C A Balanis, John Wiley ,
%     1989. pp. 450-451. 
%

% I. D. Flintoft 17/5/1997  

  if( nargin < 4 )
    error( 'too few arguments' );
  elseif( nargin == 4 )
    thickness = 1e-14;
    lossTangent = 0.0;
    sigma = Inf;
  elseif( nargin == 5 ) 
    lossTangent = 0.0;
    sigma = Inf;
  elseif( nargin == 6 ) 
    sigma = Inf;
  elseif( nargin > 7 )
    error( 'too many arguments' );
  end % if
  
  % Constants.
  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7; 
  eps0 = 1.0 / ( mu0 * c0 * c0 );

  w = 2.0 * pi * f;
  
  woh = width / height;
  toh = thickness / height;
  
  if( woh >= 1.0 / ( 2.0 * pi ) )
    weffoh = woh + 1.25 / pi * toh * ( 1.0 + log( 2 / toh ) );
  else
    weffoh = woh + 1.25 / pi * toh * ( 1.0 + log( 4.0 * pi * width / thickness ) );
  end % if
  
  if( weffoh <= 1 )
  
    eps_r_eff = 0.5 * ( eps_r + 1.0 ) + 0.5 * ( eps_r - 1.0 ) * ...
              ( ( 1.0 + 12.0 / weffoh )^(-0.5) + 0.04 * ( 1.0 - weffoh )^2 );
    Zc = 60.0 * eps_r_eff^(-0.5) * log( 8.0 / weffoh + weffoh / 4.0 );
    vp = c0 / sqrt( eps_r_eff );

  else

    eps_r_eff = 0.5 * ( eps_r + 1.0 ) + 0.5 * ( eps_r - 1.0 ) * ...
              ( 1.0 + 12.0 / weffoh )^(-0.5);
    Zc = 120.0 * pi * ...
         eps_r_eff^(-0.5) / ( weffoh + 1.393 + 0.667 * log( weffoh + 1.444 ) );
    vp = c0 / sqrt( eps_r_eff );
    
  end % if
  
  [ skinDepth , eta , Rs ] = emGoodConductor( f , 1.0 , 1.0 , sigma );

  ad = w / vp * eps_r * ( eps_r_eff - 1.0 ) * lossTangent / ( 2.0 * sqrt( eps_r_eff ) * ( eps_r - 1.0 ) );

  ac = Rs / ( Zc * width );

end % function
