function [ pwbm ] = pwbsAddAntenna( pwbm , tag ,  cavityTag , multiplicity , type , parameters )
%
% pwbsAddAntenna - Add an antenna to a PWB model.
%
% [ pwbm ] = pwbsAddAntenna( pwbm , tag , cavityTag , multiplicity , type , parameters )
%
% Inputs:
%
% pwbm         - structure, model state 
% tag          - string, antenna name
% cavityTag    - string, name of cavity containing the antenna
% multiplicity - integer, number of (identical) antennas to add
% type         - string, type of antenna
% parameters   - cell array, type specific parameter list
%
% Outputs:
%
% pwbm         - structure, model state 
%
% The supported antenna types are:
%
% `type`             | parameters`
% :------------------|:---------------------------------------------
% 'Matched'          | { loadResistance }
% 'MismatchedAE'     | { AE , loadResistance }
% 'MismatchedFileAE' | { fileName , loadResistance }
% 'Monopole'         | { length , radius , sigma , loadResistance }
% 'Dipole'           | { length , radius , sigma , loadResistance }
%
% with parameters
%
% parameter      | type          | unit | description
% :--------------|:-------------:|:----:|:-------------------------------------
% AE             | double vector | -    | average AE of antenna
% fileName       | string        | -    | name of ASCII file containing AE data
% length         | double scalar | m    | total length of monopole/dipole
% radius         | double scalar | m    | radius of monopole/dipole
% sigma          | double vector | -    | conductivity of monopole/dipole metal
% loadResistance | double scalar | ohm  | load resistance
%
% AE file format:
%
% # Optional header/comment using initial # character. 
% # Two columns of real data
% # Column 1: Frequency [Hz].
% # Column 2: Total radiation efficiency [-]
% # f [Hz]   AE [-] 
%    ft(1)    AE(1)
%    .....    ......
%    ft(N)    AE(N)
%
% The first frequency, ft(1), must less than or equal to the 
% lowest frequency in the model and the last frequency, ft(N),
% must greater than or equal to the highest frequency in the model.
% The data at the frequencies given in the file are interpolated 
% onto the frequencies requested in th model. 
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

  % Basic checks on validity of parameters.
  validateattributes( tag , { 'char' } , {} , 'pwbsAddAntenna' , 'tag' , 2 );
  validateattributes( cavityTag , { 'char' } , {} , 'pwbsAddAntenna' , 'tag' , 3 );
  validateattributes( multiplicity , { 'double' } , { 'positive' } , 'pwbsAddAntenna' , 'tag' , 4 );
  validateattributes( type , { 'char' } , {} , 'pwbsAddAntenna' , 'type' , 5 );
  validateattributes( parameters , { 'cell' } , {} , 'pwbsAddAntenna' , 'parameters' , 6 );

  % Check tag is a valid variable name.
  if( ~isvarname( tag ) )
    error( 'antenna tag %s is not a valid variable name' , tag );  
  end %if

  % Check if tag already used.
  if( mapIsKey( pwbm.antennaMap , tag ) )
    error( 'antenna with tag %s already exists' , tag );
  end % if

  % Check if cavity tag exisits.
  if( ~mapIsKey( pwbm.cavityMap , cavityTag ) )
    error( 'unknown cavity with tag %s' , cavityTag );
  end % if
  
  if( strcmp( cavityTag , 'EXT' ) )
    error( 'antenna cannot be in "EXT" cavity' );
  end % if
  
  if( rem( multiplicity , 1 ) ~= 0 )
    error( 'multiplicity must be an integer' ); 
  end % if
  
  % Select actons based on antenna type.
  switch( type )
  case 'Matched'
    if( length( parameters ) ~= 1 )
      error( 'matched antenna requires one parameter' );
    end % if
    validateattributes( parameters{1} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'loadResistance' , 1 );
    loadResistance = parameters{1};
    AE = ones( size( pwbm.f ) );
  case 'MismatchedAE'
    if( length( parameters ) ~= 2 )
      error( 'Mismatched antenna type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'vector' , 'nonnegative' , '<=' , 1.0 } , 'parameters{}' , 'AE' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'loadResistance' , 2 );
    AE = ones( size( pwbm.f ) ) .* parameters{1}(:);
    loadResistance = parameters{2};
  case 'MismatchedFileAE'
    if( length( parameters ) ~= 2 )
      error( 'MismatchedFile antenna type requires two parameters' );
    end % if  
    validateattributes( parameters{1} , { 'char' } , {} , 'parameters{}' , 'fileName' , 1 );
    validateattributes( parameters{2} , { 'double' } , { 'vector' , 'nonnegative' } , 'parameters{}' , 'loadResistance' , 2 );
    if( ~exist( parameters{1} , 'file' ) )
      error( 'cannot open AE file %s' , parameters{1} );
    else
      [ data ] = pwbImportAndInterp( pwbm.f , parameters{1} );
      AE = data(:,1);
    end % if
    loadResistance = parameters{2};
  case 'Monopole'
  case 'Dipole'
    error( 'unimplemented absorber type' , type );
  otherwise
    error( 'unknown antennas type' , type );
  end % switch
  
  % Change state.
  pwbm.isSolved = false;
  
  % Set attributes.
  pwbm.numAntennas = pwbm.numAntennas + 1;
  pwbm.antennaMap = mapSet( pwbm.antennaMap , tag , pwbm.numAntennas );
  pwbm.antennas(pwbm.numAntennas).tag = tag;
  pwbm.antennas(pwbm.numAntennas).type = type;
  pwbm.antennas(pwbm.numAntennas).multiplicity = multiplicity;
  pwbm.antennas(pwbm.numAntennas).loadResistance = loadResistance;
  pwbm.antennas(pwbm.numAntennas).parameters = parameters;
  pwbm.antennas(pwbm.numAntennas).AE = AE;
  pwbm.antennas(pwbm.numAntennas).cavityIdx = mapGet( pwbm.cavityMap , cavityTag );
  
  % These attributes are set in the initialisation phase.
  pwbm.antennas(pwbm.numAntennas).isSource = false;
  pwbm.antennas(pwbm.numAntennas).sourceIdx = NaN;
  pwbm.antennas(pwbm.numAntennas).ACS = [];
  pwbm.antennas(pwbm.numAntennas).decayRate = [];
  pwbm.antennas(pwbm.numAntennas).timeConst = [];
  pwbm.antennas(pwbm.numAntennas).Q = [];
    
  % These attributes are set in the solution phase.
  pwbm.antennas(pwbm.numAntennas).absorbedPower = [];
  
  % Add to edges list.
  pwbm.edges{end+1,1} = cavityTag;  
  pwbm.edges{end,2} = 'REF';
  pwbm.edges{end,3} = tag;
  pwbm.edges{end,4} = 'Antenna';
  
end % function
