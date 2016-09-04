function [ CCS ] = pwbsCompactModel( pwbm , objectType , objectTag , parameters )
% pwbsSolveModel - reduce part of EMT to single CCS.
%
% [ CCS ] = pwbsCompactModel( pwbm , objectType , objectTag , parameters )
%
% Inputs:
%
% pwbm       - structure, contains the model state.
% objectType - string, type of object
% objectTag  - string, tag of object
% parameters - cell array, type specific parameter list
%
% Outputs:
%
% CCS - double vector, CCS of compacted EMT
%
%The supported object types are
%    
% objectType | CCS | parameters
% -----------|:---:|:----------------------------------------------
% Aperture   | ACS | { apertureSide }
%
% with parameters
%
% parameter    | type           | unit | description
% :------------|:--------------:|:----:|:--------------------------------
% apertureSide | integer scalar | -    | side of aperture (1 or 2)
%
% The CCS of the compacted EMT is also written to an ASCII output file called
% modelName_objectType_objectTag_compacted.asc.
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

  c0 = 299792458;
  
  options.isUseCholesky = false;
  options.isUseAMD = false;
    
  % Setup model.
  [ pwbm ] = pwbsSetupModel( pwbm );
  
  if( ~strcmp( pwbm.state , 'setup' ) )
    error( 'PWB model is not set up' );
  end % if
  
  validateattributes( objectType , { 'char' } , {} , 'pwbsCompactModel' , 'objectType' , 2 );
  validateattributes( objectTag , { 'char' } , {} , 'pwbsCompactModel' , 'objectTag' , 3 ); 
  validateattributes( parameters , { 'cell' } , {} , 'pwbsCompactModel' , 'parameters' , 4 );
  
  %
  switch( objectType )
  case 'Aperture'
    if( length( parameters ) ~= 1 )
      error( 'aperture compaction type requires one parameter' );
    end % if  
    validateattributes( parameters{1} , { 'double' } , { 'scalar' , 'integer' , '>=' , 1 , '<=' , 2 } , 'parameters{}' , 'apertureSide' , 1 );
    apertureSide = parameters{1};
    % Check if cavity tags exists.
    if( ~mapIsKey( pwbm.apertureMap , objectTag ) )
      error( 'unknown aperture with tag %s' , objectTag );
    else
      apertureIdx = mapGet( pwbm.apertureMap , objectTag );
      cavity1Idx = pwbm.apertures(apertureIdx).cavityIdx(apertureSide);
      cavity2Idx = pwbm.apertures(apertureIdx).cavityIdx(3-apertureSide);
      apertureTCS = pwbm.apertures(apertureIdx).TCS;
    end % if
  otherwise
    error( 'unsupported object type' , objectType );
  end % switch
  
  % Initialise array to hold CCS of compacted EMT.
  CCS = zeros( size( pwbm.f ) );
  
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
    
    % Add unit (1 W/m^2) power density source to side 1 cavity.
    % This adds constitutive relation of "voltage source to MNA matrices.
    Sigma(cavity1Idx,pwbm.numCavities+1) = 1.0;
    Sigma(pwbm.numCavities+1,cavity1Idx) = 1.0;
    P(pwbm.numCavities+1) = 1.0;
    
    if( ~pwbm.isExtCavity )
      Sigma = Sigma(2:end,2:end);
      P = P(2:end);
    end % if
    
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
  
    if( ~pwbm.isExtCavity )
      S = [ 0 ; S ];
    end % if
    
    % Remove constitutive relation row from MNA matrices.
    S(pwbm.numCavities+1)=[];

    % Store all power densities.
    PD = full( S );
    
    % Determine effective CCS looking through aperture.
    CCS(freqIdx) = apertureTCS(freqIdx) * ( 1.0 - PD(cavity2Idx) );
  
  end % for
  
  % Export compacted EMT.
  fileName = [ pwbm.modelName , '_' , objectType , '_' , objectTag , sprintf( '_compaction%d.asc' , apertureSide) ];
  dlmwrite( fileName , [ pwbm.f , CCS ]  , '-append' , 'delimiter' , ' ' , 'precision' , '%12.5e' );

end % function
