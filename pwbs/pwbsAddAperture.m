function [ pwbm ] = pwbsAddAperture( pwbm , tag ,  cavity1Tag , cavity2Tag , multiplicity , type , parameters )
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
% 'GenericArray'      | arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , 
%                     | thickness , area , alpha_mxx , alpha_myy , alpha_ezz
% 'CircularArray'     | arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , 
%                     | thickness , radius
% 'EllipticalArray'   | arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , 
%                     | thickness , a_x , a_y
% 'SquareArray'       | arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , 
%                     | thickness , side
% 'RectangularArray'  | arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , 
%                     | thickness , side_x , side_y
% 'LucentWall'        | { area , thickness , eps_r , sigma , mu_r }
% 'LucentWallCCS'     | { area , RCS1 , RCS2 , TCS }
% 'LucentWallCE'      | { area , RE1 , RE2 , TE }
% 'LucentWallFileCCS' | { area , fileName }
% 'LucentWallFileCE'  | { area , fileName }
%
% with parameters
%
% parameter    | type         | unit | description
% -------------|:------------:|:----:|:---------------------------------------------------
% area         | double scalar | m^2 | area of aperture
% TCS          | double vector | m^2 | average TCS of aperture
% TE           | double vector | -   | average TE of aperture
% fileName     | string        | -   | name of ASCII file containing TCS/TE data
% alpha_mxx    | double scalar | m^3 | x-component of magnetic polarisability tensor
% alpha_myy    | double scalar | m^3 | y-component of magnetic polarisability tensor
% alpha_ezz    | double scalar | m^3 | z-component of electric polarisability tensor
% radius       | double scalar | m   | radius of circular aperture
% a_x          | double scalar | m   | semi-axis of elliptical aperture in x-direction
% a_y          | double scalar | m   | semi-axis of elliptical aperture in y-direction
% side         | double scalar | m   | side length of square aperture
% side_x       | double scalar | m   | side length of rectangular aperture in x-direction
% side_y       | double scalar | m   | side length of rectangular aperture in y-direction
% area         | double scalar | m^2 | area of aperture
% arrayArea    | double scalar | m^2 | area of whole array
% arrayPeriodX | double scalar | m   | period of the primitive unit cell in x-direction
% arrayPeriodY | double scalar | m   | period of the primitive unit cell in y-direction
% unitCellArea | double scalar | m^2 | area of primitive unit cell
% thickness    | double scalar | m   | thickness of plate
% thicknesses  | double vector | m   | thicknesses of each layer of laminate
% epcs_r       | complex array | -   | complex relative permittivity of layers
% sigma        | double array  | S/m | conductivity of each layers
% mu_r         | double array  | -   | relative permeability of layers
% RCS1/RCS2    | double vector | m^2 | average RCS of side1/side2 of lossy aperture
% RE1/RE2      | double vector | -   | average RE of side1/side2 of lossy aperture
% fileName     | string        | -   | file name for external CCS data
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

  % Physical consts.
  c0 = 299792458;
  
  % Function to estimate cutoff frequency by fitting high pass response to TCS/TE.
  function [ f_c ] = estimateCutoffFreq( f , TCS )
    if( length( TCS ) > 1 )
      highPassFcn = @(p,x) x.^4 ./ ( x.^2 + p.^2 ).^2;
      fitFcn=@(f_c) sum( abs( highPassFcn( f_c , f ) - TCS ).^2 );
      f_c = fminunc( fitFcn , pwbm.f(floor(end/2)) );
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
    area = parameters{1};
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
    validateattribute
    s( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side_y' , 2 );
    [ alpha_ezz , alpha_mxx , alpha_myy , area ] = pwbApertureRectangularPol( parameters{1} , parameters{2} );
    [ TCS , TE , f_c ] = pwbApertureTCS( pwbm.f , alpha_ezz , alpha_mxx , alpha_myy , area );
  case 'GenericArray'
    if( length( parameters ) ~= 9 && length( parameters ) ~= 10 )
      error( 'Generic array aperture type requires nine or ten parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayArea' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodX' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodY' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'unitCellArea' , 4 );    
    validateattributes( parameters{5} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'thickness' , 5 );
    validateattributes( parameters{6} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 6 ); 
    validateattributes( parameters{7} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_mxx' , 7 );
    validateattributes( parameters{8} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_myy' , 8 );
    validateattributes( parameters{9} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'alpha_ezz' , 9 );
    arrayArea = parameters{1};
    arrayPeriodX = parameters{2};
    arrayPeriodY = parameters{3};
    unitCellArea = parameters{4};
    thickness = parameters{5};
    area = parameters{6};
    alpha_mxx = parameters{7}; 
    alpha_myy = parameters{8};
    alpha_ezz = parameters{9};
    [ ~ , ~ , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );    
    if( length( parameters ) == 9 )
      [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                          area , alpha_mxx  , alpha_myy , alpha_ezz );    
    else
      validateattributes( parameters{10} , { 'double' } , { 'scalar' , 'nonnegative' } , 'parameters{}' , 'cutOffFreq' , 10 );    
      cutOffFreq = parameters{10};
      [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                          area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );          
    end % if
  case 'CircularArray'
    if( length( parameters ) ~= 6 )
      error( 'Circular array aperture type requires six parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayArea' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodX' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodY' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'unitCellArea' , 4 );    
    validateattributes( parameters{5} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'thickness' , 5 );
    validateattributes( parameters{6} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'radius' , 6 ); 
    arrayArea = parameters{1};
    arrayPeriodX = parameters{2};
    arrayPeriodY = parameters{3};
    unitCellArea = parameters{4};
    thickness = parameters{5};
    radius = parameters{6};
    [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureCircularPol( radius );
    [ ~ , ~ , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );    
    cutOffFreq = 3.682 * c0 / 4.0 / pi / radius;
    [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                        area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );          
  case 'EllipticalArray'
    if( length( parameters ) ~= 7 )
      error( 'Elliptical array aperture type requires seven parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayArea' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodX' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodY' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'unitCellArea' , 4 );    
    validateattributes( parameters{5} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'thickness' , 5 );
    validateattributes( parameters{6} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'a_x' , 6 ); 
    validateattributes( parameters{7} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'a_y' , 7 );     
    arrayArea = parameters{1};
    arrayPeriodX = parameters{2};
    arrayPeriodY = parameters{3};
    unitCellArea = parameters{4};
    thickness = parameters{5};
    a_x = parameters{6};
    a_y = parameters{7};
    [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureEllipticalPol( a_x , a_y );
    [ ~ , ~ , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );    
    cutOffFreq = 0.29 * c0 / max( [ a_x , a_y ] );
    [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                        area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );   
  case 'SquareArray'
    if( length( parameters ) ~= 6 )
      error( 'Square array aperture type requires six parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayArea' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodX' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodY' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'unitCellArea' , 4 );    
    validateattributes( parameters{5} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'thickness' , 5 );
    validateattributes( parameters{6} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side' , 6 ); 
    arrayArea = parameters{1};
    arrayPeriodX = parameters{2};
    arrayPeriodY = parameters{3};
    unitCellArea = parameters{4};
    thickness = parameters{5};
    side = parameters{6};
    [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureSquarePol( side );
    [ ~ , ~ , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );    
    cutOffFreq = c0 / 2.0 / side;
    [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                        area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );                                      
  case 'RectangularArray'
    if( length( parameters ) ~= 7 )
      error( 'Rectangular array aperture type requires seven parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayArea' , 1 ); 
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodX' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'arrayPeriodY' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'unitCellArea' , 4 );    
    validateattributes( parameters{5} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'thickness' , 5 );
    validateattributes( parameters{6} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side_x' , 6 ); 
    validateattributes( parameters{7} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'side_y' , 7 );     
    arrayArea = parameters{1};
    arrayPeriodX = parameters{2};
    arrayPeriodY = parameters{3};
    unitCellArea = parameters{4};
    thickness = parameters{5};
    side_x = parameters{6};
    side_y = parameters{7};
    [ area , alpha_mxx , alpha_myy , alpha_ezz ] = pwbApertureRectangularPol( side_x , side_y );
    [ ~ , ~ , f_c ] = pwbApertureTCS( pwbm.f , area , alpha_mxx , alpha_myy , alpha_ezz );    
    cutOffFreq = 0.29 * c0 / max( [ side_x , side_y ] );
    [ TCS , TE ] = pwbApertureArrayTCS( pwbm.f , arrayArea , arrayPeriodX , arrayPeriodY , unitCellArea , thickness , ...
                                        area , alpha_mxx  , alpha_myy , alpha_ezz , cutOffFreq );
  case 'LucentWallCCS'
    if( length( parameters ) ~= 4 )
      error( 'LucentWallCCS aperture type requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'RCS1' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'RCS2' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TCS' , 4 );
    area = parameters{1};
    RCS1 = parameters{2};
    RCS2 = parameters{3};
    TCS = parameters{4};
    TE = 4.0 .* TCS / area;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , 1.0 - RCS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , 1.0 - RCS2 } );
    tag = [ tag , '_T' ];
  case 'LucentWallCE'
    if( length( parameters ) ~= 4 )
      error( 'LucentWallCE aperture type requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'RE1' , 2 );
    validateattributes( parameters{3} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'RE2' , 3 );
    validateattributes( parameters{4} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'TE' , 4 );
    area = parameters{1};
    RCS1 = 0.25 .* area .* parameters{2};
    RCS2 = 0.25 .* area .* parameters{3};
    TE = parameters{4};
    TCS = 0.25 .* area .* TE;
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , 1.0 - RCS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , 1.0 - RCS2 } );  
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
      RCS1 = CCS(:,1);
      RCS2 = CCS(:,2);
      TCS = CCS(:,3);
    end % if
    TE = 4.0 .* TCS / area;  
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , 1.0 - RCS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , 1.0 - RCS2 } );  
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
      RE1 = CE(:,1);
      RE2 = CE(:,2);
      TE = CE(:,3);
    end % if
    RCS1 = 0.25 .* area .* RE1;
    RCS2 = 0.25 .* area .* RE1;
    TCS = 0.25 .* area .* TE;    
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , 1.0 - RCS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , 1.0 - RCS2 } );    
    tag = [ tag , '_T' ];
  case 'LucentWall'
    if( length( parameters ) ~= 5 )
      error( 'Lucent wall aperture type requires five parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'nonnegative' } , 'parameters{}' , 'area' , 1 );
    area = parameters{1};
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'positive' } , 'parameters{}' , 'thicknesses' , 2 );
    thicknesses = parameters{2};
    validateattributes( parameters{3} , { 'double' } , {} , 'parameters{}' , 'epsc_r' , 3 );
    epsc_r = parameters{3};
    validateattributes( parameters{4} , { 'double' } , { 'real' } , 'parameters{}' , 'sigma' , 4 );
    sigma = parameters{4};
    validateattributes( parameters{5} , { 'double' } , { 'real' } , 'parameters{}' , 'mu_r' , 5 );
    mu_r = parameters{5};
    numLayer = length( thicknesses );
    if( size( epsc_r , 2 ) ~= numLayer || size( sigma , 2 ) ~= numLayer ||  size( mu_r , 2 ) ~= numLayer )
      error( 'epsc_r, sigma and mu_r must have number columns equal to number of layers' );
    end % if
    if( size( epsc_r , 1 ) ~= 1 && size( epsc_r ,1 ) ~= numFreq )
      error( 'epsc_r must be a scalar or the same size as f' );
    end % if
    if( size( sigma , 1 ) ~= 1 && size( sigma , 1 ) ~= numFreq )
      error( 'sigma must be a scalar or the same size as f' );
    end % if
    if( size( mu_r , 1 ) ~= 1 && size( mu_r , 1 ) ~= numFreq )
      error( 'mu_r must be a scalar or the same size as f' );
    end % if
    [ ACS1 , ACS2 , RCS1 , RCS2 , TCS , AE1 , AE2 , RE1 , RE2 , TE ] = pwbLucentWall( pwbm.f , area , thicknesses , epsc_r , sigma , mu_r );
    [ f_c ] = estimateCutoffFreq( pwbm.f , TE );  
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A1' ] ,  cavity1Tag , multiplicity , 'ACS' , { area , ACS1 } );
    [ pwbm ] = pwbsAddAbsorber( pwbm , [ tag , '_A2' ] ,  cavity2Tag , multiplicity , 'ACS' , { area , ACS2 } ); 
    tag = [ tag , '_T' ];
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
