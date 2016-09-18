function [ pwbm ] = pwbsAddSource( pwbm , tag , type , objectTag , parameters )
% pwbsAddSource - Add a power source to an antenna or aperture in a PWB model.
%
% [ pwbm ] = pwbsAddSource( pwbm , tag , type , objectTag , parameters )
%
% Inputs:
%
% pwbm       - structure, model state 
% tag        - string, source name
% objectType - string, type of object acting as source
% objectTag  - string, name of object acting as source
% parameters - cell array, type specific parameter list
%
% Outputs:
%
% pwbm       - structure, model state 
%
% The supported source types are:
%
% type`               | objectType              | parameters
% --------------------|:-----------------------:|:-------------------------------------
% 'Direct'            | cavity                  | { sourcePower }
% 'Antenna'           | antenna                 | { sourcePower }
% 'DiffuseAperture'   | aperture                | { powerDensity }
% 'PlanewaveAperture' | aperture                | { powerDensity , theta , phi , psi }
% 'PowerDensity'      | 'EXT' cavity            | { powerDensity }
% 'Thermal'           | cavity/absorber/antenna | { temperature , bandwidth }
%
% The parameters are:
%
% parameter     | type          | unit   | description
% :-------------|:-------------:|:------:|:---------------------------------------
% sourcePower   | double vector | W      | power of source
% powerDensity  | double vector | W/m^2  | power density illuminating the aperture
% theta         | double scalar | degree | angle of incidence on aperture
% phi           | double scalar | degree | plane of incidence on aperture
% psi           | double scalar | degree | polarisation of electric field
% `temperature` | double scalar | K      | temperature of object
% `bandwidth`   | double scalar | Hz     | bandwidth for thermal source
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

  % Boltzmann's contant.
  k = 1.38064852e-23;
    
  % Basic checks on validity of parameters.
  validateattributes( tag , { 'char' } , {} , 'pwbsAddSource' , 'tag' , 2 );
  validateattributes( type , { 'char' } , {} , 'pwbsAddAntenna' , 'type' , 3 );
  validateattributes( objectTag , { 'char' } , {} , 'pwbsAddSource' , 'objectTag' , 4 );
  validateattributes( parameters , { 'cell' } , {} , 'pwbsAddSource' , 'parameters' , 5 );

  % Check tag is a valid variable name.
  if( ~isvarname( tag ) )
    error( 'Source tag %s is not a valid variable name' , tag );  
  end %if

  % Check if tag already used.
  if( mapIsKey( pwbm.sourceMap , tag ) )
    error( 'Source with tag %s already exists' , tag );
  end % if

  sourcePowerDensity = nan( size( pwbm.f ) );

  % Select actions based on power source type.
  switch( type )
  case 'Direct'
    if( length( parameters ) ~= 1 )
      error( 'Direct source requires one parameter' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'power' , 1 );  
    sourcePower = ones( size( pwbm.f ) ) .* parameters{1}(:); 
    objectType = 'cavity';
    % Check if cavity tags exists.
    if( ~mapIsKey( pwbm.cavityMap , objectTag ) )
      error( 'unknown cavity with tag %s' , objectTag );
    end % if  
    if( strcmp( objectTag , 'EXT' ) )
      error( 'power source inject into "EXT" cavity' );
    end % if
    objectIdx = mapGet( pwbm.cavityMap , objectTag ); 
    cavityIdx = objectIdx;
  case 'Antenna'  
    if( length( parameters ) ~= 1 )
      error( 'Antenna source requires one parameter' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'power' , 1 );  
    sourcePower = ones( size( pwbm.f ) ) .* parameters{1}(:);     
    if( mapIsKey( pwbm.antennaMap , objectTag ) )
      objectType = 'antenna';
      objectIdx = mapGet( pwbm.antennaMap , objectTag );
      power = NaN; % Must be done after antennas init'ed
      cavityIdx = pwbm.antennas(objectIdx).cavityIdx;
    else
      error( 'cannot find antenna with tag %s' , objectTag );
    end % if
  case 'DiffuseAperture'
    if( length( parameters ) ~= 1 )
      error( 'Diffuse aperture source requires one parameter' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'powerDensity' , 1 );  
    if( mapIsKey( pwbm.apertureMap , objectTag ) )
      objectType = 'apertureDiffuse';
      objectIdx = mapGet( pwbm.apertureMap , objectTag );
      if( pwbm.aperture(objectIdx).cavityIdx(1) ~= 1 && pwbm.aperture(objectIdx).cavityIdx(2) ~= 1 )
        error( 'diffuse aperture source must attached to aperture with one side in "EXT" cavity' );
      elseif( pwbm.aperture(objectIdx).cavityIdx(1) == 1 && pwbm.aperture(objectIdx).cavityIdx(2) ~= 1 )
        cavityIdx = pwbm.apertures(objectIdx).cavityIdx(2);  
      elseif( pwbm.aperture(objectIdx).cavityIdx(1) ~= 1 && pwbm.aperture(objectIdx).cavityIdx(2) == 1 )
        cavityIdx = pwbm.apertures(objectIdx).cavityIdx(1);  
      else
        % Should have prevented attaching both sides of aperture to same cavity elsewhere. 
        assert( false);
      end % if
      sourcePower = pwbm.aperture(objectIdx).ACS .* parameters{1}(:);
      cavityIdx = pwbm.antennas(objectIdx).cavityIdx;
    else
      error( 'cannot find aperture with tag %s' , objectTag );
    end % if   
  case 'PlaneWaveAperture'
    if( length( parameters ) ~= 4 )
      error( 'Planewave aperture source requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'vector' , 'positive' } , 'parameters{}' , 'powerDensity' , 1 );  
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' , '<=' , 180.0 } , 'parameters{}' , 'theta' , 2 );  
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' , '<=' , 360.0 } , 'parameters{}' , 'phi' , 3 );  
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , 'positive' , '<=' , 180.0 } , 'parameters{}' , 'psi' , 4 );  
    if( mapIsKey( pwbm.apertureMap , objectTag ) )
      objectType = 'aperturePlaneWave';
      objectIdx = mapGet( pwbm.apertureMap , objectTag );
      if( pwbm.aperture(objectIdx).cavityIdx(1) ~= 1 && pwbm.aperture(objectIdx).cavityIdx(2) ~= 1 )
        error( 'planewave aperture source must attached to aperture with one side in "EXT" cavity' );
      elseif( pwbm.aperture(objectIdx).cavityIdx(1) == 1 && pwbm.aperture(objectIdx).cavityIdx(2) ~= 1 )
        cavityIdx = pwbm.apertures(objectIdx).cavityIdx(2);  
      elseif( pwbm.aperture(objectIdx).cavityIdx(1) ~= 1 && pwbm.aperture(objectIdx).cavityIdx(2) == 1 )
        cavityIdx = pwbm.apertures(objectIdx).cavityIdx(1);  
      else
        % Should have prevented attaching both sides of aperture to same cavity elsewhere. 
        assert( false);
      end % if
      cavityIdx = pwbm.antennas(objectIdx).cavityIdx;
      E = sqrt(  2.0 .* eta0 .* ones( size( pwbm.f ) ) .* parameters{1}(:) ) ;
      theta = pi / 180 * parameters{2};
      phi = pi / 180 * parameters{3};      
      psi = pi / 180 * parameters{4};
      if( isnan( pwbm.aperture(objectIdx).alpha_ezz ) )
        error( 'plane-wave source not supported for %s aperture type ' , pwbm.aperture(objectIdx).type );
      end % if
      alpha_ezz = pwbm.aperture(objectIdx).alpha_ezz;
      alpha_mxx = pwbm.aperture(objectIdx).alpha_mxx;
      alpha_myy = pwbm.aperture(objectIdx).alpha_myy;
      area = pwbm.aperture(objectIdx).area;
      f_c = pwbm.aperture(objectIdx).f_c;      
      [ c0 , eps0 , mu0 , eta0 ] = emConst();
      %Ex = E .* ( cos( psi ) * cos( theta ) * cos( phi ) - sin( psi ) * sin( phi ) );
      %Ex = E .* ( cos( psi ) * cos( theta ) * sin( phi ) + sin( psi ) * cos( phi ) );
      Ez = E .* ( -cos( psi ) * sin( theta ) );
      H = E ./ eta0;
      Hx = H .* ( sin( psi ) * cos( theta ) * cos( phi ) + cos( psi ) * sin( phi ) );
      Hy = H .* ( sin( psi ) * cos( theta ) * sin( phi ) - cos( psi ) * cos( phi ) );
      %Hz = H * ( -sin( psi ) * sin( theta ) );
      Sz = 0.5 .* E .* H .* cos( theta );
      Cx = eta0 * alpha_mxx^2 / ( 3 * pi * c0^4 );
      Cy = eta0 * alpha_myy^2 / ( 3 * pi * c0^4 );
      Cz = alpha_ezz^2 / ( 3 * pi * c0^4 * eta0 );  
      w = 2 .* pi .* f;
      power_LF = w.^4 .* ( Cx .* Hx.^2 + Cy .* Hy.^2 + Cz .* Ez.^2 );
      power_inf = area .* Sz;
      sourcePower = ( f < f_c ) .* C .* f.^4 + ( f >= f_c ) .* power_inf;   
    else
      error( 'cannot find antenna with tag %s' , objectTag );
    end % if 
  case 'PowerDensity'
    validateattributes( parameters{1} , { 'double' } , { 'vector' , 'positive' } , 'parameters{}' , 'powerDensity' , 1 );
    powerDensitySource = parameters{1};
    if( pwbm.powerDensitySource.exists )
      error( 'only one power density source is allowed' );
    end % if
    pwbm.powerDensitySource.exists = true;
    % Check if cavity tags exists.
    if( ~strcmp( 'EXT' , objectTag ) )
      error( 'power density source can only attach to "EXT" cavity' );
    end % if
    pwbm.powerDensitySource.powerDensity = parameters{1}; 
  case { 'FileShortCircuitField' , 'ShortCircuitField' }
    error( 'unimplemented source type' , type );
  case 'Thermal'
    if( length( parameters ) ~= 2 )
      error( 'Thermal source requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'temperature' , 1 );
    temperature = parameters{1};
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'bandwidth' , 2 );
    bandwidth = parameters{2};
    if( mapIsKey( pwbm.cavityMap , objectTag ) )
      objectIdx = mapGet( pwbm.cavityMap , objectTag ); 
      cavityIdx = objectIdx;
      objectType = 'cavity';
      % Area and emissivity are factored in during setup.
      sourcePower = bandwidth .* bbExitance( temperature , pwbm.f ); 
    elseif( mapIsKey( pwbm.absorberMap , objectTag ) )
      objectIdx = mapGet( pwbm.absorberMap , objectTag ); 
      absorberIdx = objectIdx;
      cavityIdx = pwbm.absorbers(absorberIdx).cavityIdx;
      objectType = 'absorber';
      area = pwbm.absorbers(absorberIdx).area;
      emissivity = pwbm.absorbers(absorberIdx).AE;
      sourcePower = area .* emissivity .* bandwidth .* bbExitance( temperature , pwbm.f ); 
    elseif( mapIsKey( pwbm.antennaMap , objectTag ) )
      objectIdx = mapGet( pwbm.antennaMap , objectTag ); 
      antennaIdx = objectIdx;
      cavityIdx = pwbm.antennas(antennaIdx).cavityIdx;
      objectType = 'antenna';
      % Antenna efficiency is factored in during setup.
      sourcePower = k .* temperature .* bandwidth;
    else
      error( 'unknown object with tag %s' , objectTag );
    end % if
  otherwise
    error( 'invalid source type' , type );
  end % switch  
  
  % Change state.
  pwbm.state = 'init';
  
  % Add to edges list.
  switch( type )
  case 'PowerDensity'
    pwbm.edges{end+1,1} = 'EXT';  
    pwbm.edges{end,2} = 'REF';
    pwbm.edges{end,3} = tag;
    pwbm.edges{end,4} = 'PowerDensitySource';
  otherwise
    pwbm.edges{end+1,1} = mapGetIdx( pwbm.cavityMap , cavityIdx ); 
    pwbm.edges{end,2} = 'REF';
    pwbm.edges{end,3} = tag;
    pwbm.edges{end,4} = 'PowerSource';  
  end % switch
  
  if( strcmp( type , 'PowerDensity' ) )
    return;
  end % if
  
  % Set attributes.
  pwbm.numSources = pwbm.numSources + 1;
  pwbm.sourceMap = mapSet( pwbm.sourceMap , tag , pwbm.numSources );
  pwbm.sources(pwbm.numSources).tag = tag;
  pwbm.sources(pwbm.numSources).type = type;
  pwbm.sources(pwbm.numSources).parameters = parameters;
  pwbm.sources(pwbm.numSources).cavityIdx = cavityIdx;
  pwbm.sources(pwbm.numSources).sourcePower = sourcePower;
  pwbm.sources(pwbm.numSources).objectType = objectType;
  pwbm.sources(pwbm.numSources).objectIdx = objectIdx;

  % Set source attributes on associated objects.
  switch( type )
  case 'Antenna'
    pwbm.antennas(objectIdx).isSource = true;                                       
    pwbm.antennas(objectIdx).sourceIdx = pwbm.numSources;       
  case 'ApertureDiffuse'
    pwbm.aperture(objectIdx).isSource = true;
    pwbm.aperture(objectIdx).sourceIdx = pwbm.numSources;   
  case 'AperturePlaneWave'
    pwbm.aperture(objectIdx).isSource = true;
    pwbm.aperture(objectIdx).sourceIdx = pwbm.numSources;
  end % switch

end % function
