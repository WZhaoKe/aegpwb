function [ pwbm ] = pwbsSolveModel( pwbm )
%
% pwbsSolveModel - Solve a PWB model.
%
% [ pwbm ] = pwbsSolveModel( pwbm )
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
  
  options.isUseCholesky = false;
  options.isUseAMD = false;
  
  % Setup model.
  [ pwbm ] = pwbsSetupModel( pwbm );
  
  if( ~strcmp( pwbm.state , 'setup' ) )
    error( 'PWB model is not set up' );
  end % if
    
  % Initialise array to hold all power densities.
  PD = zeros(  length( pwbm.f ) , pwbm.numCavities );
  TRP = zeros(  length( pwbm.f ) , 1 );
  externalPowerDensity = 0.0;
  
  % Iterate over frequencies.
  for freqIdx=1:length( pwbm.f )

    % Initialise NA matrices.
    Sigma = sparse( pwbm.numCavities , pwbm.numCavities );
    P = sparse( pwbm.numCavities , 1 );
  
    % Load cavities into NA matrices. Skip virtual cavity.
    for cavityIdx=2:pwbm.numCavities
      ACS = pwbm.cavities(cavityIdx).wallACS(freqIdx);
      Sigma(cavityIdx,cavityIdx) = Sigma(cavityIdx,cavityIdx) + ACS;
    end % for
    
    % Load antennas into NA matrices.
    for antennaIdx=1:pwbm.numAntennas
      cavityIdx = pwbm.antennas(antennaIdx).cavityIdx(1);
      ACS = pwbm.antennas(antennaIdx).ACS(freqIdx);
      Sigma(cavityIdx,cavityIdx) = Sigma(cavityIdx,cavityIdx) + ACS;
    end % for
    
    % Load absorbers into NA matrices.
    for absorberIdx=1:pwbm.numAbsorbers
      cavityIdx = pwbm.absorbers(absorberIdx).cavityIdx(1);
      ACS = pwbm.absorbers(absorberIdx).ACS(freqIdx);
      Sigma(cavityIdx,cavityIdx) = Sigma(cavityIdx,cavityIdx) + ACS;
    end % for
    
    % Load apertures into NA matrices.
    for apertureIdx=1:pwbm.numApertures
      cavity1Idx = pwbm.apertures(apertureIdx).cavityIdx(1);
      cavity2Idx = pwbm.apertures(apertureIdx).cavityIdx(2);      
      TCS = pwbm.apertures(apertureIdx).TCS(freqIdx);
      Sigma(cavity1Idx,cavity1Idx) = Sigma(cavity1Idx,cavity1Idx) + TCS;
      Sigma(cavity2Idx,cavity2Idx) = Sigma(cavity2Idx,cavity2Idx) + TCS;
      Sigma(cavity1Idx,cavity2Idx) = Sigma(cavity1Idx,cavity2Idx) - TCS;
      Sigma(cavity2Idx,cavity1Idx) = Sigma(cavity2Idx,cavity1Idx) - TCS;
    end % for
    
    % Load sources into NA matrices.
    for sourceIdx=1:pwbm.numSources
      switch( pwbm.sources(sourceIdx).type )
      case 'PowerDensitySource'
        externalPowerDensity = pwbm.sources(sourceIdx).sourcePowerDensity(freqIdx);
      otherwise
        cavityIdx = pwbm.sources(sourceIdx).cavityIdx(1);
        power = pwbm.sources(sourceIdx).sourcePower(freqIdx);
        P(cavityIdx) = P(cavityIdx) + power;
      end % switch
    end % for

    % Add power density source to external environment.
    % This will be short to reference if no power density source has been added.
    % This adds constitutive relation of "voltage source to MNA matrices.
    Sigma(1,pwbm.numCavities+1) = 1.0;
    Sigma(pwbm.numCavities+1,1) = 1.0;
    P(pwbm.numCavities+1) = pwbm.powerDensitySource.powerDensity(freqIdx);

    % Solve for power densities.
    if( options.isUseCholesky )
      if( options.isUseAMD )
        % Cholesky factorisation with AMD.
        p = amd( Sigma );
        Lp = chol( Sigma(p,p) );
        Sp = Lp \ ( Lp' \ P(p) );
        S(p) = Sp;
      else
        % Cholesky factorisation.
        L = chol( Sigma );
        S = L \ ( L' \ P );
      end %if
    else     
      % Direct solution.
      S = Sigma \ P;
    end % if

    % TRP is power through power density source.
    TRP(freqIdx) = full(S(pwbm.numCavities+1));
    
    % Remove constitutive relation row from MNA matrices.
    S(pwbm.numCavities+1)=[];

    % Store all power densities.
    PD(freqIdx,1:pwbm.numCavities) = full( S );
  
  end % for
    
  % Post-processes antennas.
  for antennaIdx=1:pwbm.numAntennas
    cavityIdx = pwbm.antennas(antennaIdx).cavityIdx(1);
    pwbm.antennas(antennaIdx).absorbedPower = pwbm.antennas(antennaIdx).ACS .* PD(:,cavityIdx);    
    pwbm.cavities(cavityIdx).totalAbsorbedPower = pwbm.cavities(cavityIdx).totalAbsorbedPower + pwbm.antennas(antennaIdx).absorbedPower;
  end % for
  
  % Post-processes absorbers.
  for absorberIdx=1:pwbm.numAbsorbers
    cavityIdx = pwbm.absorbers(absorberIdx).cavityIdx(1);
    pwbm.absorbers(absorberIdx).absorbedPower = pwbm.absorbers(absorberIdx).ACS .* PD(:,cavityIdx);    
    pwbm.cavities(cavityIdx).totalAbsorbedPower = pwbm.cavities(cavityIdx).totalAbsorbedPower + pwbm.absorbers(absorberIdx).absorbedPower;
  end % for
  
  % Process apertures.
  for apertureIdx=1:pwbm.numApertures
    cavity1Idx = pwbm.apertures(apertureIdx).cavityIdx(1);
    cavity2Idx = pwbm.apertures(apertureIdx).cavityIdx(2);
    pwbm.apertures(apertureIdx).coupledPower = pwbm.apertures(apertureIdx).TCS .* ( PD(:,cavity1Idx) - PD(:,cavity2Idx) );
    pwbm.cavities(cavity1Idx).totalCoupledPower = pwbm.cavities(cavity1Idx).totalCoupledPower + pwbm.apertures(apertureIdx).coupledPower;
    pwbm.cavities(cavity2Idx).totalCoupledPower = pwbm.cavities(cavity2Idx).totalCoupledPower - pwbm.apertures(apertureIdx).coupledPower;
  end % for
  
  % Process cavities.
  pwbm.cavities(1).powerDensity = PD(:,1);
  pwbm.cavities(1).energyDensity = PD(:,1) ./ c0;
  powerError = max( abs( pwbm.cavities(1).totalCoupledPower + TRP ) );
  if( powerError > 1000 * eps )
    warning( 'power balance error %g in cavity EXT' , powerError );
  end % if
    
  if( pwbm.powerDensitySource.exists )
    pwbm.cavities(1).powerDensity = pwbm.powerDensitySource.powerDensity;
  end % if
  pwbm.cavities(1).totalAbsorbedPower = TRP;
  pwbm.cavities(1).totalCoupledPower = TRP;
      
  for cavityIdx=2:pwbm.numCavities
    pwbm.cavities(cavityIdx).powerDensity = PD(:,cavityIdx);
    pwbm.cavities(cavityIdx).energyDensity = PD(:,cavityIdx) ./ c0;
    pwbm.cavities(cavityIdx).wallPower = pwbm.cavities(cavityIdx).wallACS .* PD(:,cavityIdx);
    pwbm.cavities(cavityIdx).totalAbsorbedPower = pwbm.cavities(cavityIdx).totalAbsorbedPower + pwbm.cavities(cavityIdx).wallPower;
    powerError = max( abs( pwbm.cavities(cavityIdx).totalSourcePower - pwbm.cavities(cavityIdx).totalAbsorbedPower - pwbm.cavities(cavityIdx).totalCoupledPower  ) );
    if( powerError > 1000 * eps )
      warning( 'power balance error %g in cavity %s' , powerError , pwbm.cavities(cavityIdx).tag );
    end % if
  end % for

  pwbm.state = 'solved'; 
  
end % function
