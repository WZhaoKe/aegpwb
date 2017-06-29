function [ ACS , AE ] = pwbSubstrate( f , area , height , eps_r , tand )
%pwbSubstrate - Absorption by a PEC backed lossy dielectric substrate.
%
% Usage:
%
% [ ACS , AE ] = pwbSubstrate( f , subHeight , subArea , subEpsc_r , subTand )
%
% Inputs:
%
% f      - real vector, frequency [Hz].
% area   - real scalar, area of substrate [m^2].
% height - real scalar, height of substrate [m].
% eps_r  - real scalar or vector, substrate relative permittivity [-].
% tand   - real scalar or vector, substrate loss tangent [-].
%
% Outputs:
%
% ACS   - real vector, average absorption cross-section [m^2].
% AE    - real vector, average absorption efficiency [-].
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2017 Ian Flintoft <ian.flintoft@googlemail.com>
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
% Date: 18/01/2017

  epsc_r = ones( length( f ) , 2 );
  epsc_r(:,1) = eps_r .* ( 1 - 1j .* tand );
  sigma = zeros( length( f ) , 2 );
  sigma(:,1) = 0.0;
  sigma(:,2) = 1e6 .* ones( length( f ) , 1 );
  [ ACS , AE ] = pwbLaminatedSurface( f , area , [ height ] , epsc_r , sigma , [ 1.0 , 1.0 ] , [ 0.0 , 0.0 ] );
  
end % function
