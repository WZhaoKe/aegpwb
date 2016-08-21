function [ pwbm ] = pwbsAddCavity( pwbm , tag , type , parameters )
%
% pwbsAddCavity - Add a cavity to a PWB model.
%
% Inputs:
%
% pwbm       - structure, model state 
% tag        - string, cavity name
% type       - string, type of cavity
% parameters - cell array, type specific parameter list
%
% Outputs:
%
% pwbm       - structure, model state
%
%The supported cavity types are
%
% type             | parameters
% -----------------|:----------------------------------
% 'Cuboid'         | { a , b , c , sigma , mu_r }
% 'Generic'        | { area , volume , sigma , mu_r }
% 'GenericACS'     | { area , volume , wallACS }
% 'GenericFileACS' | { area , volume , fileName }
%
% with parameters
%
% parameter | type          | unit | description
% :---------|:-------------:|:----:|:--------------------------------
% a         | double scalar | m    | first side length
% b         | double scalar | m    | second side length
% c         | double scalar | m    | third side length
% area      | double scalar | m^2  | area of closed bounding surface
% volume    | double scalar | m^3  | volume
% sigma     | double vector | S/m  | wall conductivity
% mu_r      | double vector | -    | wall relative permeability
% wallACS   | double vector | m^2  | ACS of cavity walls
% fileName  | string        | -    | file name for external ACS data
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

  % Basic checks on validity of parameters.
  validateattributes( tag , { 'char' } , {} , 'pwbsAddCavity' , 'tag' , 2 );
  validateattributes( type , { 'char' } , {} , 'pwbsAddCavity' , 'type' , 3 );
  validateattributes( parameters , { 'cell' } , { 'vector' } , 'pwbsAddCavity' , 'parameters' , 4 );

  % Check tag is a valid variable name.
  if( ~isvarname( tag ) )
    error( 'cavity tag %s is not a valid variable name' , tag );  
  end %if

  % Check it tag already used.
  if( mapIsKey( pwbm.cavityMap , tag ) )
    error( 'cavity with tag %s already exists' , tag );
  end % if

  % Select actons based on cavity type.
  switch( type )
  case 'Cuboid'
    if( length( parameters ) ~= 5 )
      error( 'cuboid cavity requires five parameters' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'a' , 1 );
    a = parameters{1};    
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'b' , 2 );  
    b = parameters{2};
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'c' , 3 );
    c = parameters{3};
    validateattributes( parameters{4} , { 'double' } , { 'vector' , 'positive' } , 'parameters{}' , 'sigma' , 4 );
    sigma = ones( size( pwbm.f ) ) .* parameters{4}(:);    
    validateattributes( parameters{5} , { 'double' } , { 'vector' , '>=' , 1.0 } , 'parameters{}' , 'mu_r' , 5 );
    mu_r = ones( size( pwbm.f ) ) .* parameters{5}(:);
    area = 2.0 * ( a * b + b * c + c * a );
    volume = a * b * c;
    [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesLiu( pwbm.f , a , b , c );
  case 'Generic'
    if( length( parameters ) ~= 4 )
      error( 'generic cavity requires four parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'area' , 1 );
    area = parameters{1};    
    validateattributes( parameters{2} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'volume' , 2 );  
    volume = parameters{2};
    validateattributes( parameters{3} , { 'double' } , { 'scalar' , 'positive' } , 'parameters{}' , 'sigma' , 3 );
    sigma = ones( size( pwbm.f ) ) .* parameters{3}(:);
    validateattributes( parameters{4} , { 'double' } , { 'scalar' , '>=' , 1.0 } , 'parameters{}' , 'mu_r' , 4 );
    mu_r = ones( size( pwbm.f ) ) .* parameters{4}(:);    
    [ numModes , modeDensity , f_1 , f_60 ] = pwbGenericCavityModesWeyl( pwbm.f , volume ); 
  case 'GenericACS'
  case 'GenericFileACS'
    error( 'unimplemented cavity type %s' , type );
  otherwise
    error( 'unknown cavity type %s' , type );
  end % switch
  
  % Change state.
  pwbm.state = 'init';

  % Update tag hash.
  pwbm.numCavities = pwbm.numCavities + 1;                                      % Number of cavities.
  pwbm.cavityMap = mapSet( pwbm.cavityMap , tag , pwbm.numCavities );           % Mapping of tags to indices.
  
  % Set attributes.
  pwbm.cavities(pwbm.numCavities).tag = tag;                                    % Cavity tag.
  pwbm.cavities(pwbm.numCavities).type = type;                                  % Cavity type.
  pwbm.cavities(pwbm.numCavities).parameters = parameters;                      % Raw input parameters.
  pwbm.cavities(pwbm.numCavities).f_1 = f_1;                                    % Frequency of first mode.
  pwbm.cavities(pwbm.numCavities).f_60  = f_60;                                 % Frequency of sixtifh mode.
  pwbm.cavities(pwbm.numCavities).area = area;                                  % Area of bounding surface. 
  pwbm.cavities(pwbm.numCavities).volume = volume;                              % Volume.
  pwbm.cavities(pwbm.numCavities).sigma = sigma;                                % Wall conductivity.
  pwbm.cavities(pwbm.numCavities).mu_r = mu_r;                                  % Wall relative permeability.
  pwbm.cavities(pwbm.numCavities).numModes = numModes;                          % Cumulative number of modes.
  pwbm.cavities(pwbm.numCavities).modeDensity = modeDensity;                    % Mode density.
  
  % These attributes are set in the setup phase.
  pwbm.cavities(pwbm.numCavities).wallArea = [];                                % Total wall area of cavity, excluding apertures.
  pwbm.cavities(pwbm.numCavities).apertureArea = 0.0;                           % Total aperture area of cavity.
  pwbm.cavities(pwbm.numCavities).wallACS = [];                                 % ACS of walls.
  pwbm.cavities(pwbm.numCavities).wallAE = [];                                  % AE of walls.
  pwbm.cavities(pwbm.numCavities).wallDecayRate = [];                           % Energy decay rate or antenna.
  pwbm.cavities(pwbm.numCavities).wallTimeConst = [];                           % Energy decay time constant of antenna.
  pwbm.cavities(pwbm.numCavities).wallQ = [];                                   % Partial Q-factor antenna.
  pwbm.cavities(pwbm.numCavities).totalACS = zeros( size( pwbm.f ) );           % Total ACS of absorbers in cavity.
  pwbm.cavities(pwbm.numCavities).totalQ = zeros( size( pwbm.f ) );             % Total Q factor of cavity.
  pwbm.cavities(pwbm.numCavities).totalDecayRate = [];                          % total decay time constant of cavity.
  pwbm.cavities(pwbm.numCavities).totalTimeConst = [];                          % Total decay time constant of cavity.
  pwbm.cavities(pwbm.numCavities).totalTCS = zeros( size( pwbm.f ) );           % Total TCS of apertures in cavity.
  
  % These attributes are set in the solution phase.
  pwbm.cavities(pwbm.numCavities).powerDensity = [];                            % Power density.  
  pwbm.cavities(pwbm.numCavities).energyDensity = [];                           % Energy density.
  pwbm.cavities(pwbm.numCavities).modeBandwidth = [];                           % Mode bandwidth.
  pwbm.cavities(pwbm.numCavities).specificModeDensity = [];                     % Specific mode density .
  pwbm.cavities(pwbm.numCavities).f_Schroeder = [];                             % Schroeder frequency of cavity
  pwbm.cavities(pwbm.numCavities).wallPower = [];                               % Power absobred in walls.
  pwbm.cavities(pwbm.numCavities).totalSourcePower = zeros( size( pwbm.f ) );   % Total source ppower injected into cavity.
  pwbm.cavities(pwbm.numCavities).totalAbsorbedPower = zeros( size( pwbm.f ) ); % Total power absorbed in cavity.
  pwbm.cavities(pwbm.numCavities).totalCoupledPower = zeros( size( pwbm.f ) );  % Total power coupled out of cavity through apertures.
  pwbm.cavities(pwbm.numCavities).NindPaddle = zeros( size( pwbm.f ) );         % Number of independent paddle samples.
  pwbm.cavities(pwbm.numCavities).NindFreq = zeros( size( pwbm.f ) );           % Number of independent frequency stirring samples.
  
  % Add to edges list.
  pwbm.edges{end+1,1} = tag;  
  pwbm.edges{end,2} = 'REF';
  pwbm.edges{end,3} = tag;
  pwbm.edges{end,4} = 'Absorber';
  
end % function
