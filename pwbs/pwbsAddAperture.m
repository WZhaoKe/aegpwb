function [ pwbm ] = pwbsAddAperture( pwbm , tag ,  cavity1Tag , cavity2Tag , multiplicity , type , parameters )
%
% pwbsAddAperture - Add an aperture to a PWB model.
%
% [ pwbm ] = pwbsAddAperture(  pwbm , tag ,  cavity1Tag , cavity2Tag , multiplicity , type , parameters )
%
% Inputs:
%
% pwbm         - structure, model state 
% tag          - string, aperture name
% cavity1Tag   - string, name of cavity on first side of aperture
% cavity2Tag   - string, name of cavity on second side of aperture
% multiplicity - integer scalar, number of (identical) apertures to add
% type         - string, type of aperture
% parameters   - cell array, type specific parameter list
%
% If the aperture couples into the external environment then `cavity2Tag` should 
% be given as `'EXT'`.
%
% Outputs:
%
% pwbm         - structure, model state 
%
% The supported aperture types are:
%
% type`               | parameters`
% --------------------|:-------------------------------------------
% 'TCS'               | { area , TCS }
% 'TE'                | { area , TE  }
% 'FileTCS'           | { area , fileName }
% 'FileTE'            | { area , fileName }
% 'Generic'           | { area , alpha_mxx , alpha_myy , alpha_ezz }
% 'Circular'          | { radius }
% 'Elliptical'        | { a_x , a_y }
% 'Square'            | { side }
% 'Rectangular'       | { side_x , side_y }
% 'LucentWall'        | { area , thickness , eps_r , sigma , mu_r }
% 'LucentWallCCS'     | { area , ACS1 , ACS2 , TCS }
% 'LucentWallCE'      | { area , AE1 , AE2 , TE }
% 'LucentWallFileCCS' | { area , fileName }
% 'LucentWallFileCE'  | { area , fileName }
%
% with parameters
%
% parameter    | type         | unit | description
% -------------|:------------:|:----:|:---------------------------------------------------
% area        | double scalar | m^2  | area of aperture
% TCS         | double vector | m^2  | average TCS of aperture
% TE          | double vector | -    | average TE of aperture
% fileName    | string        | -    | name of ASCII file containing TCS/TE data
% alpha_mxx   | double scalar | m^3  | x-component of magnetic polarisability tensor
% alpha_myy   | double scalar | m^3  | y-component of magnetic polarisability tensor
% alpha_ezz   | double scalar | m^3  | z-component of electric polarisability tensor
% radius      | double scalar | m    | radius of circular aperture
% a_x         | double scalar | m    | semi-axis of elliptical aperture in x-direction
% a_y         | double scalar | m    | semi-axis of elliptical aperture in y-direction
% side        | double scalar | m    | side length of square aperture
% side_x      | double scalar | m    | side length of rectangular aperture in x-direction
% side_y      | double scalar | m    | side length of rectangular aperture in y-direction
% area        | double scalar | m^2  | area of aperture
% thicknesses | double vector | m    | thicknesses of each layer of laminate
% epcs_r      | complex array | -    | complex relative permittivity of layers
% sigma       | double array  | S/m  | conductivity of each layers
% mu_r        | double array  | -    | relative permeability of layers
% ACS1/ACS2   | double vector | m^2  | average ACS side1/side2 of lossy aperture
% AE1/AE2     | double vector | -    | average AE side1/side2 of lossy aperture
% fileName    | string        | -    | file name for external CCS data
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft
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
% Author: I. D Flintoft
% Date: 19/08/2016
% Version: 1.0.0
  % Function to estimate cutoff frequency by fitting high pass response to TCS/TE.
  function [ f_c ] = estimateCutoffFreq( f , TCS )
    if( length( TCS ) > 1 )
      fitFcn = @(p,x) x.^4 ./ ( x.^2 + p.^2 ).^2;
      settings = optimset( 'inequc' , { 1 , 0 } );
      [ f_c , model_values, cvg, outp] = nonlin_curvefit( fitFcn , pwbm.f(floor(end/2)) , pwbm.f , TCS ./ TCS(end) , settings );  
    else
      f_c = NaN;
    end % if  
  end % function 
  
  % Basic checks on validity of parameters.
  validateattributes( tag , { 'char' } , {} , 'pwbsAddAperture' , 'tag' , 2 );
  validateattributes( cavity1Tag , { 'char' } , {} , 'pwbsAddAperture' , 'cavity1tag' , 3 );
  validateattributes( cavity2Tag , { 'char' } , {} , 'pwbsAddAperture' , 'cavity2tag' , 4 ); 
  validateattributes( multiplicity , { 'double' } , { 'scalar' , 'positive' } , 'pwbsAddAperture' , 'tag' , 5 );
  validateattributes( type , { 'char' } , {} , 'pwbsAddAntenna' , 'type' , 6 );
  validateattributes( parameters , { 'cell' } , {} , 'pwbsAddAntenna' , 'parameters' , 7 );

  % Check tag is a valid variable name.
  if( ~isvarname( tag ) )
    error( 'aperture tag %s is not a valid variable name' , tag );  
  end %if

  % Check if tag already used.
  if( mapIsKey( pwbm.apertureMap , tag ) )
    error( 'aperture with tag %s already exists' , tag );
  end % if

  % Check if cavity tags exists.
  if( ~mapIsKey( pwbm.cavityMap , cavity1Tag ) )
    error( 'unknown cavity with tag %s' , cavity1Tag );
  end % if
  if( ~mapIsKey( pwbm.cavityMap , cavity2Tag ) )
    error( 'unknown cavity with tag %s' , cavity2Tag );
  end % if
  if( strcmp( cavity1Tag , cavity2Tag ) )
    error( 'aperture %s cannot couple cavity %s to itself!' , tag , cavity1Tag );
  end % if
   
  if( rem( multiplicity , 1 ) ~= 0 )
    error( 'multiplicity must be an integer' ); 
  end % if
  
  % Default polarisabilities and cutoff frequency.
  alpha_mxx = NaN;
  alpha_myy = NaN;
  alpha_ezz = NaN;
  f_c = NaN;
    
  % Select actons based on aperture type.
  switch( type )
  case 'TCS'
    if( length( parameters ) ~= 2 )
      error( 'TCS aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TCS' , 2 );
    area = parameters{1};
    TCS = parameters{2};
    TE = 4.0 .* TCS / area;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );
  case 'TE'
    if( length( parameters ) ~= 2 )
      error( 'TE aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TE' , 2 );
    area = parameters{1};
    TE = parameters{2};
    TCS = 0.25 .* TE .* area;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );
  case 'FileTCS'
    if( length( parameters ) ~= 2 )
      error( 'FileTCS aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'char' } , {} , 'parameters{}' , 'fileName' , 2 );
    area = parameters{1};
    if( ~exist( parameters{2} , 'file' ) )
      error( 'cannot open TCS file %s' , parameters{2} );
    else
      [ data ] = pwbImportAndInterp( pwbm.f , parameters{2} );
      TCS = data(:,1);
    end % if
    TE = 4.0 .* TCS / area;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );
  case 'FileTE'
    if( length( parameters ) ~= 2 )
      error( 'FileTE aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'char' } , {} , 'parameters{}' , 'fileName' , 2 );
    area = parameters{1};
    if( ~exist( parameters{2} , 'file' ) )
      error( 'cannot open TE file %s' , parameters{2} );
    else
      [ data ] = pwbImportAndInterp( pwbm.f , parameters{2} );
      TE = data(:,1);
    end % if 
    TCS = 0.25 .* area .* TE;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );
  case 'Generic'
    if( length( parameters ) ~= 4 )
      error( 'Generic aperture type requires four parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_mxx' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_myy' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_ezz' , 4 );    
    alpha_ezz = parameters{2};
    alpha_mxx = parameters{3}; 
    alpha_myy = parameters{4};
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );
  case 'Circular'
    if( length( parameters ) ~= 1 )
      error( 'Circular aperture type requires one parameter' );
    end % if 
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'radius' , 1 );
    [ alpha_ezz , alpha_mxx , alpha_myy , area ] = pwbApertureCircularPol( parameters{1} );
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , alpha_ezz , alpha_mxx , alpha_myy , area );
  case 'Elliptical'
    if( length( parameters ) ~= 2 )
      error( 'Elliptical aperture type requires two parameters' );
    end % if 
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'a_x' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'a_y' , 2 );
    [ alpha_ezz , alpha_mxx , alpha_myy , area ] = pwbApertureEllipticalPol( parameters{1} , parameters{2} );
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , alpha_ezz , alpha_mxx , alpha_myy , area );
  case 'Square'
    if( length( parameters ) ~= 1 )
      error( 'Square aperture type requires one parameter' );
    end % if 
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side' , 1 );
    [ alpha_ezz , alpha_mxx , alpha_myy , area ] = pwbApertureSquarePol( parameters{1} );
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , alpha_ezz , alpha_mxx , alpha_myy , area );
  case 'Rectangular'
    if( length( parameters ) ~= 2 )
      error( 'Rectangular aperture type requires two parameters' );
    end % if 
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side_x' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side_y' , 2 );
    [ alpha_ezz , alpha_mxx , alpha_myy , area ] = pwbApertureRectangularPol( parameters{1} , parameters{2} );
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , alpha_ezz , alpha_mxx , alpha_myy , area );    
  case 'LucentWallCCS'
    if( length( parameters ) ~= 4 )
      error( 'LucentWallCCS aperture type requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'ACS1' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'ACS2' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TCS' , 4 );
    area = parameters{1};
    ACS1 = parameters{2};
    ACS2 = parameters{3};
    TCS = parameters{4};
    TE = 4.0 .* TCS / area;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , ACS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , ACS2 } );
    tag = [ tag , '_T' ];
  case 'LucentWallCE'
    if( length( parameters ) ~= 4 )
      error( 'LucentWallCE aperture type requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'AE1' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'AE2' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TE' , 4 );
    area = parameters{1};
    ACS1 = 0.25 .* area .* parameters{2};
    ACS2 = 0.25 .* area .* parameters{3};
    TE = parameters{4};
    TCS = 0.25 .* area .* TE;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , ACS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , ACS2 } );  
    tag = [ tag , '_T' ];
  case 'LucentWallFileCCS'
    if( length( parameters ) ~= 2 )
      error( 'LucentWallFileCCS aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'char' } , {} , 'parameters{}' , 'fileName' , 2 );
    area = parameters{1};
    if( ~exist( parameters{2} , 'file' ) )
      error( 'cannot open CCS file %s' , parameters{2} );
    else
      [ CCS ] = pwbImportAndInterp( pwbm.f , parameters{2} );
      ACS1 = CCS(:,1);
      ACS2 = CCS(:,2);
      TCS = CCS(:,3);
    end % if
    TE = 4.0 .* TCS / area;  
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , ACS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , ACS2 } );  
    tag = [ tag , '_T' ];
  case 'LucentWallFileCE'
    if( length( parameters ) ~= 2 )
      error( 'LucentWallFileCE aperture type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'char' } , {} , 'parameters{}' , 'fileName' , 2 );
    area = parameters{1};
    if( ~exist( parameters{2} , 'file' ) )
      error( 'cannot open CE file %s' , parameters{2} );
    else
      [ CE ] = pwbImportAndInterp( pwbm.f , parameters{2} );
      AE1 = CE(:,1);
      AE2 = CE(:,2);
      TE = CE(:,3);
    end % if
    ACS1 = 0.25 .* area .* AE1;
    ACS2 = 0.25 .* area .* AE1;
    TCS = 0.25 .* area .* TE;    
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , ACS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , ACS2 } );    
    tag = [ tag , '_T' ];
  case 'LucentWall'
    error( 'unimplemented aperture type' , type );    
  otherwise
    error( 'unknown aperture type' , type );
  end % switch
   
  % Change state.
  pwbm.state = 'init';
  
  % Factor in  multiplicity.
  TCS = TCS .* multiplicity;
  
  % Set attributes.
  pwbm.numApertures = pwbm.numApertures + 1;
  pwbm.apertureMap = mapSet( pwbm.apertureMap , tag , pwbm.numApertures );
  pwbm.apertures(pwbm.numApertures).tag = tag;
  pwbm.apertures(pwbm.numApertures).type = type;
  pwbm.apertures(pwbm.numApertures).multiplicity = multiplicity;
  pwbm.apertures(pwbm.numApertures).parameters = parameters;
  pwbm.apertures(pwbm.numApertures).cavityIdx = [ mapGet( pwbm.cavityMap , cavity1Tag ) , mapGet( pwbm.cavityMap , cavity2Tag ) ];  
  pwbm.apertures(pwbm.numApertures).area = area;
  pwbm.apertures(pwbm.numApertures).alpha_mxx = alpha_mxx;
  pwbm.apertures(pwbm.numApertures).alpha_myy = alpha_myy;
  pwbm.apertures(pwbm.numApertures).alpha_ezz = alpha_ezz;
  pwbm.apertures(pwbm.numApertures).f_c = f_c;
  pwbm.apertures(pwbm.numApertures).TCS = TCS;
  pwbm.apertures(pwbm.numApertures).TE = TE;
  volume1 = pwbm.cavities(pwbm.apertures(pwbm.numApertures).cavityIdx(1)).volume;
  volume2 = pwbm.cavities(pwbm.apertures(pwbm.numApertures).cavityIdx(2)).volume;
  [ Q1 , decayRate1 , timeConst1 ] = pwbEnergyParamsFromCCS( pwbm.f , TCS , volume1 );
  [ Q2 , decayRate2 , timeConst2 ] = pwbEnergyParamsFromCCS( pwbm.f , TCS , volume2 );
  pwbm.apertures(pwbm.numApertures).Q1 = Q1;
  pwbm.apertures(pwbm.numApertures).decayRate1 = decayRate1;     
  pwbm.apertures(pwbm.numApertures).timeConst1 = timeConst1;
  pwbm.apertures(pwbm.numApertures).Q2 = Q2;
  pwbm.apertures(pwbm.numApertures).decayRate2 = decayRate2;     
  pwbm.apertures(pwbm.numApertures).timeConst2 = timeConst2;
  
  % These attributes are set in the init phase. 
  pwbm.apertures(pwbm.numApertures).isSource = false;
  pwbm.apertures(pwbm.numApertures).sourceIdx = NaN;
  
  % These attributes are set in the solution phase. 
  pwbm.apertures(pwbm.numApertures).coupledPower = [];

  % Add to edges list.
  pwbm.edges{end+1,1} = cavity1Tag;  
  pwbm.edges{end,2} = cavity2Tag;
  pwbm.edges{end,3} = tag;
  pwbm.edges{end,4} = 'Aperture';
    
  if( strcmp( cavity1Tag , 'EXT' ) || strcmp( cavity2Tag , 'EXT' ) )
    pwbm.isExtCavity = true;
  end % if
  
end % function
