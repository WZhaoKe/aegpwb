function [ pwbm ] = pwbsInitModel( f , modelName )
%
% pwbsInitModel - Initialise a PWB model.
%
% [ pwbm ] = pwbsInitModel( f , modelName )
%
% Inputs:
%
% f         - real vector, frequencies to evaluate the solution [Hz].
% modelName - string, name of model.
%
% Outputs:
%
% pwbm   - structure, contains the model state.
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

  pwbm.version = 0.1;
  
  validateattributes( f , { 'double' } , { 'positive' , 'vector' , 'increasing' } , 'pwbsInitModel' , 'f' , 1 );
  validateattributes( modelName , { 'char' } , { 'vector' } , 'pwbsInitModel' , 'modelName' , 2 );
  
  pwbm.f = f(:);
  pwbm.modelName = modelName;
 
  %
  % Cavities.
  %
  
  % Number of cavities.
  pwbm.numCavities = 0;
  
  % Hash table for cavity tags.
  pwbm.cavityMap = [];  
  
  % cs-list for cavity objects.
  pwbm.cavities = [];
  
  % Units of valid output parameters.
  pwbm.cavityUnits.tag = '-';
  pwbm.cavityUnits.type = '-';
  pwbm.cavityUnits.f_1 = 'Hz';
  pwbm.cavityUnits.f_60  = 'Hz';
  pwbm.cavityUnits.area = 'm^2';
  pwbm.cavityUnits.volume = 'm^3';
  pwbm.cavityUnits.numModes = '-';
  pwbm.cavityUnits.modeDensity = '/Hz';
  pwbm.cavityUnits.wallArea = 'm^2';
  pwbm.cavityUnits.apertureArea = 'm^2';
  pwbm.cavityUnits.wallACS = 'm^2';
  pwbm.cavityUnits.wallAE = '-';
  pwbm.cavityUnits.wallQ = '-';
  pwbm.cavityUnits.wallDecayRate = '/s';
  pwbm.cavityUnits.wallTimeConst = 's';
  pwbm.cavityUnits.totalACS = 'm^2';
  pwbm.cavityUnits.totalQ = '-';
  pwbm.cavityUnits.totalTCS = 'm^2';
  pwbm.cavityUnits.totalDecayRate = '/s';     
  pwbm.cavityUnits.totalTimeConst = 's';  
  pwbm.cavityUnits.powerDensity = 'W/m^2';
  pwbm.cavityUnits.energyDensity = 'W/m^3';  
  pwbm.cavityUnits.modeBandwidth = 'Hz';
  pwbm.cavityUnits.specificModeDensity = '-';
  pwbm.cavityUnits.f_Schroeder = 'Hz';
  pwbm.cavityUnits.wallPower = 'W';
  pwbm.cavityUnits.totalSourcePower = 'W';
  pwbm.cavityUnits.totalAbsorbedPower = 'W';
  pwbm.cavityUnits.totalCoupledPower = 'W';
  pwbm.cavityUnits.NindPaddle = '-';
  pwbm.cavityUnits.NindFreq = '-';

  % List of all valid output parameters.
  pwbm.cavityOutputs = fieldnames( pwbm.cavityUnits );

  % Add virtual cavity for the external space. May be unsed.
  pwbm.numCavities = 1;
  pwbm.cavityMap = mapSet( pwbm.cavityMap , 'EXT' , 1 );
  pwbm.cavities(1).tag = 'EXT';
  pwbm.cavities(1).type = 'ExternalSpace';
  pwbm.cavities(1).parameters = {};
  pwbm.cavities(1).f_1 = NaN;
  pwbm.cavities(1).f_60  = NaN;
  pwbm.cavities(1).area = NaN;
  pwbm.cavities(1).volume = NaN;
  pwbm.cavities(1).sigma = [];
  pwbm.cavities(1).mu_r = [];
  pwbm.cavities(1).numModes = [];
  pwbm.cavities(1).modeDensity = [];
  pwbm.cavities(1).wallArea = NaN;
  pwbm.cavities(1).apertureArea = 0.0;
  pwbm.cavities(1).wallACS = [];
  pwbm.cavities(1).wallAE = [];
  pwbm.cavities(1).f_Schroeder = NaN;
  pwbm.cavities(1).modeBandwidth = [];
  pwbm.cavities(1).specificModeDensity = [];
  pwbm.cavities(1).powerDensity = [];
  pwbm.cavities(1).wallPower = [];
  pwbm.cavities(1).totalACS = zeros( size( pwbm.f ) );
  pwbm.cavities(1).totalQ = zeros( size( pwbm.f ) );
  pwbm.cavities(1).totalTCS = zeros( size( pwbm.f ) );
  pwbm.cavities(1).totalSourcePower = zeros( size( pwbm.f ) );
  pwbm.cavities(1).totalAbsorbedPower = zeros( size( pwbm.f ) );
  pwbm.cavities(1).totalCoupledPower = zeros( size( pwbm.f ) );  
      
  % Whether there is an external environment cavity.
  pwbm.isExtCavity = false;
  
  %
  % Apertures.
  %
  
  % Number of apertures.
  pwbm.numApertures = 0;
  
  % Hash table of aperture tags.
  pwbm.apertureMap = [];  
  
  % cs-list for aperture objects.
  pwbm.apertures = [];

  % Units of valid output parameters.
  pwbm.apertureUnits.tag = '-';
  pwbm.apertureUnits.type = '-';
  pwbm.apertureUnits.multiplicity = '-';
  pwbm.apertureUnits.area = 'm^2';
  pwbm.apertureUnits.f_c = 'Hz';
  pwbm.apertureUnits.TCS = 'm^2';
  pwbm.apertureUnits.TE = '-';
  pwbm.apertureUnits.Q1 = '-';
  pwbm.apertureUnits.Q2 = '-';
  pwbm.apertureUnits.decayRate1 = '/s';
  pwbm.apertureUnits.decayRate2 = '/s';
  pwbm.apertureUnits.timeConst1 = 's';
  pwbm.apertureUnits.timeConst2 = 's';
  pwbm.apertureUnits.coupledPower = 'W';
  pwbm.apertureUnits.isSource = '-';
  
  % List of all valid output parameters.
  pwbm.apertureOutputs = fieldnames( pwbm.apertureUnits );
 
  %
  % Absorbers.
  %
  
  % Number of absorbers.
  pwbm.numAbsorbers = 0;
  
  % Hash table for absorber names.
  pwbm.absorberMap = [];  
  
  % cs-list for absorber objects.
  pwbm.absorbers = [];
  
  % Units of valid output parameters.
  pwbm.absorberUnits.tag = '-';
  pwbm.absorberUnits.type = '-';
  pwbm.absorberUnits.multiplicity = '-';
  pwbm.absorberUnits.area = 'm^2';
  pwbm.absorberUnits.ACS = 'm^2';
  pwbm.absorberUnits.AE = '-';
  pwbm.absorberUnits.Q = '-';
  pwbm.absorberUnits.decayRate = '/s';
  pwbm.absorberUnits.timeConst = 's';
  pwbm.absorberUnits.absorbedPower = 'W';
  
  % List of all valid output parameters.
  pwbm.absorberOutputs = fieldnames( pwbm.absorberUnits );
  
  %
  % Antennas.
  %
  
  % Number of antennas.
  pwbm.numAntennas = 0;
  
  % Hash table for antennas.
  pwbm.antennaMap = [];
  
  % cs-list for antenna objects.
  pwbm.antennas = [];

  % Units of valid output parameters.
  pwbm.antennaUnits.tag = '-';
  pwbm.antennaUnits.type = '-';
  pwbm.antennaUnits.multiplicity = '-';
  pwbm.antennaUnits.loadResistance = 'ohm';
  pwbm.antennaUnits.ACS = 'm^2';
  pwbm.antennaUnits.AE = '-';
  pwbm.antennaUnits.Q = '-';
  pwbm.antennaUnits.decayRate = '/s';
  pwbm.antennaUnits.timeConst = 's';
  pwbm.antennaUnits.absorbedPower = 'W';
  pwbm.antennaUnits.isSource = '-';
  
  % List of all valid output parameters.
  pwbm.antennaOutputs = fieldnames( pwbm.antennaUnits );
  
  %
  % Sources.
  %
  
  % Number of sources.
  pwbm.numSources = 0;
  
  % Hash table for source names.
  pwbm.sourceMap = [];  
  
  % cs-list for source objects.
  pwbm.sources = [];

  % Units of valid output parameters.
  pwbm.sourceUnits.tag = '-';
  pwbm.sourceUnits.type = '-';
  pwbm.sourceUnits.sourcePower = 'W';
  
  % List of all valid output parameters.
  pwbm.sourceOutputs = fieldnames( pwbm.sourceUnits );
    
  % Whether there is a power density source.
  pwbm.powerDensitySource.exists = false;
  pwbm.powerDensitySource.powerDensity = zeros( size( pwbm.f ) );
    
  %
  % Misc.
  %
  
  % Edges for plotting graph.
  pwbm.edges = {};
  
  % Boolena indicating if solution is valid.
  pwbm.state = 'init';

end % function
