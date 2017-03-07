function [ surfIntegral ] = pwbGaussLegendreIntegral( kernel , order , weight , isCylindircal , isHemisphere )
%pwbGaussLegendreIntegral - Integrate over the surface of a sphere or hemi-sphere using
%                           Gauss-Legendre quadrature.
%
% Usage:
%
% [ surfIntegral ] = pwbGaussLegendreIntegral( kernel , order , weight , isCylindircal , isHemisphere )
%
% Inputs:
%
% kernel        - complex/real array, samples of the integrand, see below  [arb].
% order         - integer scalar, positive integer giving the order of the quadrature [-].
% weight        - real array, Gauss-Legendre weights [-].
% isCylindircal - boolean scalar, true if problem has cylindrical symmetry.
% isHemisphere  - boolean scalar, true if only z > 0 hemisphere is included.
%
% Outputs:
%
% surfIntegral - complex/real array, value(s) of the surface integral [arb].
%
% Notes:
%
% 1. See help for pwbGaussLegendreAngles regarding the definition of the weight arrays.
%
% 2. The kernel array can have three forms:
%
%    a. A vector with the same number of elements as weight. In this case it is assumed
%       to be a flattened array of samples with order corresponding to theta(:), phi(:),
%        and psi(:). 
%
%    b. A two-dimensional array in which each row is assumed to be a flattened array of 
%        samples with order corresponding to theta(:), phi(:), and psi(:).      
%
%    c. A three-dimensional array with the same shape as weight with the samples
%       in the corresponding positions.
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
% Date: 19/01/2017

  if( ndims( kernel ) == 1 )
    if( numel( kernel ) ~= numel( weight ) )
      error( 'one-dimensional kernel must have same number of elements as weight' );
    end % if
    surfIntegral = pi ./ order .* sum( weight(:) .* kernel(:) );   
  elseif( ndims( kernel ) == 2 )
    % Assume first index is flattened PW index.
    if( size( kernel , 2 ) ~= numel( weight ) )
      error( 'two-dimensional kernel must have same number of columns as the number of elements in weight' );
    end % if 
    surfIntegral = pi ./ order .* sum( bsxfun( @times , weight(:)' , kernel ) , 2 );
  elseif( ndims( kernel ) == 4 )
    if( all( size( kernel ) ~= size( weight ) ) )
      error( 'three-dimensional kernel must have same shape and size as weight' );
    end % if  
    surfIntegral = pi ./ order .* sum( weight(:)' .* kernel , 2 );
  else
    error( 'unsupported kernel shape' );
  end % if
  
  if( isCylindircal )
    surfIntegral = 2.0 * order * surfIntegral;
  end % if
   
end % function
