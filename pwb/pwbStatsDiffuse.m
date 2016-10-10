function [ meanQuantity , stdQuantity , quantQuantity ] = pwbStatsDiffuse( quantity , refValue )
% pwbStatsDiffuse - statistics for ideal reverberant environment
%
% [ meanQuantity , stdQuantity quantQuantity ] = pwbStatsDiffuse( quantity , refValue )
%
% Inputs:
%
% quantity - string, physical quantity to determine distribution for.
%            Valid values are:
%
%            'Fir' - real or imaginary part of a field component or received voltage/current
%            'Fi'  - magnitude of field component or received voltage/current
%            'Fi2' - squared magnitude of field component or received power
%            'F'   - total field magnitude.             
%            'F2'  - square of total field magnitude, power density or enegy density in cavity.
%
% refValue - real vector, reference value for quantity
%
%            quantity | required reference value
%            ---------|-----------------------------------------------------------------
%            'Fir'    | standard deviation of real or imaginary part of field component
%                     |   or received voltage/current
%            'Fi'     | mean of magnitdue of field component or received voltage/current
%            'Fi2'    | mean square of field component magnitude or received power
%            'F'      | mean of total field magnitude       
%            'F2'     | mean square of total field magnitude
%
% Output:
%
% meanQuantity  - real vector, mean of quantity requested [].
% stdQuantity   - real vector, standard deviation of quantity requested [].
% quantQuantity - real array, quantiles  of quantity requested [].
%                 The 25-th, 50-th (median), 75-th, 95-th and 99-th quantiles are 
%                 returned in the columns of the array.
%
% References:
%
% [1]) D. A. Hill, "Plane wave integral representation for fields in reverberation chambers",
%      IEEE Transactions on Electromagnetic Compatibility, vol. 40, no. 3, pp. 209-217, Aug 1998.
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
% Author: I. D. Flintoft
% Date: 16/08/2016

  validateattributes( quantity , { 'char' } , {} , 'pwbDistDiffuse' , 'quantity' , 1 );
  validateattributes( refValue , { 'double' } , { 'vector' , 'positive' } , 'pwbDistDiffuse' , 'refValue' , 2 );    
  validatestring( quantity , { 'Fir' , 'Fi' , 'Fi2' , 'F' , 'F2' } );
  
  % Chi distributions.
  chicdf=@(x,dof) gammainc( 0.5 .* x.^2 ,  0.5 * dof );
  chipdf=@(x,dof) 2.0.^(1.0-0.5*dof) .* x.^(dof-1.0) .* exp(-x.^2./2.0) ./ gamma( 0.5 * dof );
  chiinv=@(p,dof) error( 'chiinv not implemented yet' );
   
  % Quantiles to collect.
  quantiles = [ 0.25 , 0.5 , 0.75 , 0.95 , 0.99 ];

  switch( quantity )
  case 'Fir'
    sigma = refValue;
    meanQuantity = 0.0;
    stdQuantity = sigma;
    for quantIdx = 1:length( quantiles )
      quantQuantity(:,quantIdx) = norminv( quantiles(quantIdx) , 0.0 , sigma );
    end % for
  case 'Fi'
    sigma = refValue ./ sqrt( pi ./ 2.0 );
    meanQuantity = sigma .* sqrt( pi ./ 2.0 );
    stdQuantity = sigma .* sqrt( ( 4.0 - pi ) ./ 2.0 );
    for quantIdx = 1:length( quantiles )
      quantQuantity(:,quantIdx) = raylinv( quantiles(quantIdx) , 0.0 , sigma );
    end % for
  case 'Fi2'
    sigma = sqrt( refValue ./ 2.0 );
    meanQuantity = 2.0 * sigma.^2;
    stdQuantity = 2.0 * sigma.^2;
    for quantIdx = 1:length( quantiles )
      quantQuantity(:,quantIdx) = expinv( quantiles(quantIdx) , 2.0 .* sigma.^2 );
    end % for
  case 'F'
    sigma = 160.0 .* refValue ./ 15.0 ./ sqrt( 2.0 .* pi );
    meanQuantity = 15.0 .* sqrt( 2.0 .* pi ) .* sigma ./ 16.0;
    stdQuantity =  sqrt( 6.0 - 2.0 .* pi .* ( 15/16 ).^2 ) .* sigma;
    for quantIdx = 1:length( quantiles )
      quantQuantity(:,quantIdx) = sigma .* chiinv( quantiles(quantIdx) , 6 );
    end % for    
  case 'F2'
    sigma = sqrt( refValue ./ 6.0 );
    meanQuantity = 6 .* sigma.^2;
    stdQuantity = sqrt( 12.0 ) .* sigma.^2; 
    for quantIdx = 1:length( quantiles )
      quantQuantity(:,quantIdx) = sigma.^2 .* chi2inv( quantiles(quantIdx) , 6 );
    end % for 
  otherwise
    assert( false );
  end % switch

end %function
