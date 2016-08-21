function [ x , y , meanQuantity , stdQuantity quantQuantity ] = pwbsProbDists( pwbm , objectType , objectTag , freq , quantity , dist )
%
% pwbsProbDists - Get probability distributions and statistics for object.
%
% [ x , y , meanQuantity , stdQuantity quantQuantity ] = pwbsProbDists( pwbm ,  objectType , objectTag , quantity , dist )
%
% Inputs:
%
% pwbm         - structure, contains the model state.
% objectType   - string, type of object to get distributions for.
% objectTag    - string, name of object to get data for.
% freq         - real scalar, frequency to get data for.
% quantity     - string, physical quantity to determine distribution for.
%                Valid values are:
%
%                cavity type:
%
%                'Eir'            - real or imaginary part of electric field component [V/m].
%                'Ei'             - magnitude of electric field component [V/m].
%                'Ei2'            - squared magnitude of electric field component [V^2/m^2].
%                'E'              - total electric field magnitude [V/m].             
%                'E2'             - square of total electric field magnitude [V^2/m^2].
%                'Hir'            - real or imaginary part of magnetic field component [A/m].
%                'Hi'             - magnitude of magnetic field component [A/m].
%                'Hi2'            - squared magnitude of magnetic field component [A^2/m^2].
%                'H'              - total magnetic field magnitude [A/m].             
%                'H2'             - square of total magnetic vfield magnitude [A^2/m^2].
%                'powerDensity'   - scalar power density [W/m^2].
%                'energyDensity'  - energy density [J/m^3].
%
%                antenna type:
%
%                'Vr'    - real or imaginary part of voltage [V].
%                'V'     - magnitude of voltage [V].
%                'V2'    - squared magnitude of voltage [V^2].
%                'Ir'    - real or imaginary part of current [A].
%                'I'     - magnitude of current [A].
%                'I2'    - squared magnitude of current [A^2].
%                'power' - power [W].
%
% dist         - string, required probability distribution.
%                Valid values are:
%
%                'CDF'  - cumulative distribution
%                'CCDF' - complementary cumulative distribution, reliability function
%                'PDF'  - probability density function
%
% Output:
%
% x             - real vector, quantity requested []
% y             - real vector, distribution of quantity requrested [].
% meanQuantity  - real scalar, mean of quantity requested [].
% stdQuantity   - real scalar, standard deviation of quantity requested [].
% quantQuantity - real array, quantiles  of quantity requested [].
%                 The first row give values of the CDF the and the second row gives the 
%                 quantiles. THe 25-th, 50-th (median), 75-th, 95-th and 99-th 
%                 quantiles are returned.
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft
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
% Author: I. D Flintoft
% Date: 19/08/2016
% Version: 1.0.0

  c0 = 299792458;                  
  mu0 = 4 * pi * 1e-7;             
  eps0 = 1.0 / ( mu0 * c0 * c0 );
  eta0 = sqrt( mu0 / eps0 );
  
  if( ~strcmp( pwbm.state , 'solved' ) )
    error( 'pwb model has not been solved yet!' );
  end % if
  
  validateattributes( objectType , { 'char' } , {} , 'pwbsProbDists' , 'objectType' , 2 ); 
  validateattributes( objectTag , { 'char' } , {} , 'pwbsProbDists' , 'objectTag' , 3 ); 
  validateattributes( freq , { 'double' } , { 'scalar' , 'positive' } , 'pwbsProbDists' , 'powerDensity' , 4 )  
  validateattributes( quantity , { 'char' } , {} , 'pwbsProbDists' , 'quantity' , 5 );
  validateattributes( dist , { 'char' } , {} , 'pwbsProbDists' , 'dist' , 6 );
  validatestring( dist , { 'CDF' , 'CCDF' , 'PDF' } );
  
  % Get nearest frequency index.
  if( freq < pwbm.f(1) || freq > pwbm.f(end) )
    error( 'Frequency %g Hz is out of simulation range' ,freq );
  end % if  
  switch( objectType )
  case 'Cavity'
    validatestring( quantity , { 'Eir' , 'Ei' , 'Ei2' , 'E' , 'E2' , 'Hir' , 'Hi' , 'Hi2' , 'H' , 'H2' , 'PD' , 'ED' } );
    % Get cavity index.
    if( mapIsKey( pwbm.cavityMap , objectTag ) )
      cavityIdx = mapGet( pwbm.cavityMap , objectTag );
    else
      error( 'unknown cavity %s' , objectTag );
    end % if  
    % Average power density in cavity at required frequency.
    powerDensity = interp1( pwbm.f , pwbm.cavities(cavityIdx).powerDensity , freq );
    % Statistics and distributions.
    switch( quantity )
    case 'Eir'
      refValue = sqrt( 2.0 .* eta0 .* powerDensity ./ 6.0 );
      refQuantity = 'Fir';
    case 'Ei'
      refValue = sqrt( 2.0 .* eta0 .* powerDensity ./ 3.0 );     
      refQuantity = 'Fi';      
    case 'Ei2'
      refValue = 2.0 .* eta0 .* powerDensity ./ 3.0;    
      refQuantity = 'Fi2';     
    case 'E'
      refValue = sqrt( 2.0 .* eta0 .* powerDensity );   
      refQuantity = 'F';
    case 'E2'
      refQuantity = 'F2';
      refValue = 2.0 .* eta0 .* powerDensity; 
      case 'Hir'
      refValue = sqrt( 2.0 .* powerDensity ./ eta0 ./ 6.0 );
      refQuantity = 'Fir';
    case 'Hi'
      refValue = sqrt( 2.0 .* powerDensity ./ eta0 ./ 3.0 );     
      refQuantity = 'Fi';      
    case 'Hi2'
      refValue = 2.0 .* powerDensity ./ eta0 ./ 3.0;    
      refQuantity = 'Fi2';     
    case 'H'
      refValue = sqrt( 2.0 .* powerDensity ./ eta0 );   
      refQuantity = 'F';
    case 'H2'
      refQuantity = 'F2';
      refValue = 2.0 .* powerDensity ./ eta0;    
    case 'powerDensity'
      refQuantity = 'F2';
      refValue = powerDensity;
    case 'energyDensity'
      refQuantity = 'F2';
      refValue = powerDensity ./ c0;      
    end % switch 
    [ x , y , meanQuantity , stdQuantity , quantQuantity ] = pwbDistDiffuse( refQuantity , dist , refValue );
  case 'Antenna'
    validatestring( quantity , { 'Vir' , 'Vi' , 'Vi2' , 'Iir' , 'Ii' , 'Ii2'  , 'P' } );
    % Get antenna index.
    if( mapIsKey( pwbm.antennaMap , objectTag ) )
      antennaIdx = mapGet( pwbm.antennaMap , objectTag );
    else
      error( 'unknown antenna %s' , objectTag );
    end % if  
    % Average power received by single antenna at required frequency.
    power = interp1( pwbm.f , pwbm.antennas(antennaIdx).power , freq ) ./ pwbm.antennas(antennaIdx).multiplicity;
    Z0 = pwbm.antennas(antennaIdx).loadResistance;
    switch( quantity )
    case 'Vr'
      refValue = sqrt( 2.0 .* Z0 .* power / 2.0 );
      refQuantity = 'Fir';
    case 'V'
      refValue = sqrt( 2.0 .* Z0 .* power );     
      refQuantity = 'Fi';      
    case 'V2'
      refValue = 2.0 .* Z0 .* power;    
      refQuantity = 'Fi2';     
    case 'Ir'
      refValue = sqrt( 2.0 .* power ./ Z0 ./ 2.0 );
      refQuantity = 'Fir';
    case 'I'
      refValue = sqrt( 2.0 .* power ./ Z0 );     
      refQuantity = 'Fi';      
    case 'I2'
      refValue = 2.0 .* power ./ Z0;    
      refQuantity = 'Fi2';      
    case 'power'
      refQuantity = 'Fi2';
      refValue = power;      
    end % switch     
    % Statistics and distributions.
    [ x , y , meanQuantity , stdQuantity , quantQuantity ] = pwbDistDiffuse( refQuantity , dist , refValue );        
  otherwise
    error( 'unsupported object type %s' , objectType );
  end % switch
  
end % function
