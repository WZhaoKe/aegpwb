function [ ACS , AE ] = pwbLaminatedSurface( f , area , thicknesses , eps_r , sigma , mu_r , sigmam )
%
% pwbLaminatedSurface - lossy multilayer surface absorption cross-section.
%
% [ ACS , AE ] = pwbLaminatedSurface( f , area , thicknesses , eps_r , sigma , mu_r , sigmam )
%
%             |   |   |       |
%             |   |   |       |
%  cavity     | 1 | 2 | ..... | numLayer -> oo
%             |   |   |       | 
%  eps0 , m0  |   |   |       |
%             |   |   |       |
%
% Parameters:
%
% f           - vector (numFreq) of required frequencies [Hz].
% area        - real scalar, area of surface [m^2].
% thicknesses - vector (numLayer-1) of layer thicknesses [m].
% eps_r       - array (numFreq x numLayer) of relative permittivities [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigma       - array (numFreq x numLayer) of electrical conductivities [S/m].
%               If first dimension is 1 assumed same for all frequencies.
% mu_r        - array (numFreq x numLayer) of relative permeabilities [-].
%               If first dimension is 1 assumed same for all frequencies.
% sigmam      - array (numFreq x numLayer) of magnetic conductivities [ohm/m].
%               If first dimension is 1 assumed same for all frequencies.
%         
% Outputs:
%
% ACS - average absorption cross-section [m^2].
% AE  - average absorption efficiency [-].
%

  function [ kernel ] = pwbLaminatedSurfaceKernel( f , theta , thicknesses ,  eps_r , sigma , mu_r , sigmam ) 

    for idx=1:length( theta )
      [ rhoTE(idx) , rhoTM(idx) , ~ , ~ ] = emMultiRefG( f , 180 * theta(idx) / pi , thicknesses , eps_r , sigma , mu_r , sigmam );
    end % for
    
    kernel = ( 1 - 0.5 .* ( abs( rhoTE ).^2 + abs( rhoTM ).^2 ) ) .* cos( theta ) .* sin( theta ); 
    
  end %function
 
  % Get number of frequencies and layers.
  f = f(:);
  numFreq = length( f );
  numLayer = length( thicknesses ) + 1;
  
  % Check and expand material arrays.
  [ eps_r ] = expandMaterialArray( eps_r , numFreq , numLayer , 'epsc_r' );
  [ sigma ] = expandMaterialArray( sigma , numFreq , numLayer , 'sigma' );
  [ mu_r ] = expandMaterialArray( mu_r , numFreq , numLayer , 'mu_r' );
  [ sigmam ] = expandMaterialArray( sigmam , numFreq , numLayer , 'sigmam' ); 

  % Iterate over frequencies integrating over angles of incidence.
  ACS = zeros( size( f ) );
  AE = zeros( size( f ) );
  for freqIdx=1:length( f )  
    AE(freqIdx) = 2.0 * quad( ...
      @(theta) pwbLaminatedSurfaceKernel( f(freqIdx) , theta ,  thicknesses , [1.0,eps_r(freqIdx,:)] , [0.0,sigma(freqIdx,:)] , [1.0,mu_r(freqIdx,:)] , [0.0,sigmam(freqIdx,:)] ) , ...
      0.0 , pi / 2.0 - 1e-4 );
    ACS(freqIdx) = 0.25 * AE(freqIdx) * area;
  end %for

end %function
