function [ pwbm ] = pwbsSetupModel( pwbm )
%
% pwbsSetupModel - Setup model linkages.
%
% [ pwbm ] = pwbsSetupModel( pwbm )
%
% Inputs:
%
% pwbm   - structure, contains the model state.
%
% Outputs:
%
% pwbm   - structure, contains the updated model state.
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
  
  if( ~strcmp( pwbm.state , 'init' ) )
    error( 'PWB model is not initialised' );
  end % if
  
  %
  % Antennas.
  %
  
  for antennaIdx=1:pwbm.numAntennas
    % Set ACS of antenna depending on whether or not it is a source.
    isSource = pwbm.antennas(antennaIdx).isSource;
    AE = pwbm.antennas(antennaIdx).AE;
    ACS = pwbm.antennas(antennaIdx).multiplicity .* pwbAntenna( pwbm.f , isSource , AE );
    pwbm.antennas(antennaIdx).ACS = ACS;
    % Set Q, decay rate and time constant.
    cavityIdx = pwbm.antennas(antennaIdx).cavityIdx(1);
    volume = pwbm.cavities(cavityIdx).volume;
    [ Q , decayRate , timeConst ] = pwbEnergyParamsFromCCS( pwbm.f , ACS , volume );
    pwbm.antennas(antennaIdx).Q = Q;
    pwbm.antennas(antennaIdx).decayRate = decayRate;     
    pwbm.antennas(antennaIdx).timeConst = timeConst;
    % Add ACS to total ACS of associated cavity. 
    pwbm.cavities(cavityIdx).totalACS = pwbm.cavities(cavityIdx).totalACS + ACS;
  end % for
  
  %
  % Apertures.
  %

  % Accumulators for total aperture area in each cavity.
  apertureArea = zeros( 1 , pwbm.numCavities );
  
  % Iterate over aperture.
  for apertureIdx=1:pwbm.numApertures
    % Get indices of coupled cavitites.
    cavity1Idx = pwbm.apertures(apertureIdx).cavityIdx(1);
    cavity2Idx = pwbm.apertures(apertureIdx).cavityIdx(2);
    % Add areas to accummulators.
    apertureArea(cavity1Idx) = apertureArea(cavity1Idx) + pwbm.apertures(apertureIdx).area;
    apertureArea(cavity2Idx) = apertureArea(cavity2Idx) + pwbm.apertures(apertureIdx).area;
    pwbm.cavities(cavity1Idx).totalTCS = pwbm.cavities(cavity1Idx).totalTCS + pwbm.apertures(apertureIdx).TCS;
    pwbm.cavities(cavity2Idx).totalTCS = pwbm.cavities(cavity2Idx).totalTCS + pwbm.apertures(apertureIdx).TCS;
  end % for

  % Add total aperture area to each cavity object.
  for cavityIdx=1:pwbm.numCavities
    pwbm.cavities(cavityIdx).apertureArea = apertureArea(cavityIdx);
  end % for
  
  %
  % Sources.
  %
  for sourceIdx=1:pwbm.numSources
    switch( pwbm.sources(sourceIdx).type )
    case 'Antenna'
      % Delivered power from antenna is source power reduced by efficiency.
      pwbm.sources(sourceIdx).sourcePower = pwbm.antennas(pwbm.sources(sourceIdx).objectIdx).AE .* pwbm.sources(sourceIdx).parameters{1};
    end % switch
    % Add to total source power in associated cavity.
    cavityIdx = pwbm.sources(sourceIdx).cavityIdx(1);
    pwbm.cavities(cavityIdx).totalSourcePower = pwbm.cavities(cavityIdx).totalSourcePower + pwbm.sources(sourceIdx).sourcePower;  
  end % for
  
  %
  % Cavities
  %

  % Iterate over cavities.
  for cavityIdx=2:pwbm.numCavities
    % Determine cavity wall area as nominal area minus aperutre area.
    pwbm.cavities(cavityIdx).wallArea = pwbm.cavities(cavityIdx).area - pwbm.cavities(cavityIdx).apertureArea;
    % Get required parameters.
    area = pwbm.cavities(cavityIdx).area;
    volume = pwbm.cavities(cavityIdx).volume;
    sigma = pwbm.cavities(cavityIdx).sigma;
    mu_r = pwbm.cavities(cavityIdx).mu_r;
    % Determine ACS and AE of cavity walls and insert in cavity object.
    [ wallACS , wallAE ] = pwbGenericCavityWallACS( pwbm.f , area , volume , sigma , mu_r );
    pwbm.cavities(cavityIdx).wallACS = wallACS;
    pwbm.cavities(cavityIdx).wallAE = wallAE;
    volume = pwbm.cavities(cavityIdx).volume;
    % Set Q, decay rate and time constant of cavity walls.
    [ wallQ , wallDecayRate , wallTimeConst ] = pwbEnergyParamsFromCCS( pwbm.f , wallACS , volume );
    pwbm.cavities(cavityIdx).wallQ = wallQ;
    pwbm.cavities(cavityIdx).wallDecayRate = wallDecayRate;     
    pwbm.cavities(cavityIdx).wallTimeConst = wallTimeConst;
    % Add wall ACS to total cavity ACS.
    pwbm.cavities(cavityIdx).totalACS = pwbm.cavities(cavityIdx).totalACS + pwbm.cavities(cavityIdx).wallACS;   
    % Add total cavity ACS and TCS to give total CCS.
    totalCCS = pwbm.cavities(cavityIdx).totalACS + pwbm.cavities(cavityIdx).totalTCS;
    % Set total Q, decay rate and time constant of cavity.
    [ totalQ , totalDecayRate , totalTimeConst ] = pwbEnergyParamsFromCCS( pwbm.f , totalCCS , volume );
    pwbm.cavities(cavityIdx).totalQ = totalQ;
    pwbm.cavities(cavityIdx).totalDecayRate = totalDecayRate;     
    pwbm.cavities(cavityIdx).totalTimeConst = totalTimeConst;
    % Use total ACS to estimate mode bandwidth and associated quantitites.
    pwbm.cavities(cavityIdx).modeBandwidth = c0 .* pwbm.cavities(cavityIdx).totalACS ./ 2.0 ./ pi ./ volume;
    pwbm.cavities(cavityIdx).specificModeDensity = pwbm.cavities(cavityIdx).modeBandwidth .* pwbm.cavities(cavityIdx).modeDensity;
    idx = find( pwbm.cavities(cavityIdx).specificModeDensity >= 3 , 1 );
    if( isempty( idx) )
      pwbm.cavities(cavityIdx).f_Schroeder = NaN;
    else
      pwbm.cavities(cavityIdx).f_Schroeder = pwbm.f(idx);
    end % if
  end % for
  
  pwbm.state = 'setup';
  
end % function
