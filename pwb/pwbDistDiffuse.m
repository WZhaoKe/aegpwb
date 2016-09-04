function [ x , y , meanQuantity , stdQuantity , quantQuantity ] = pwbDistDiffuse( quantity , dist , refValue )
% pwbDistDiffuse - probability distributions and statistics for ideal reverberant environment
%
% [ x , y , meanQuantity , stdQuantity quantQuantity ] = pwbDistDiffuse( quantity , dist , refValue )
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
% dist     - string, required probability distribution.
%            Valid values are:
%
%            'CDF'  - cumulative distribution
%            'CCDF' - complementary cumulative distribution, reliability function
%            'PDF'  - probability density function
%
% refValue - real scalar, reference value for quantity
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
% x             - real vector, quantity requested []
% y             - real vector, distribution of quantity requrested [].
% meanQuantity  - real scalar, mean of quantity requested [].
% stdQuantity   - real scalar, standard deviation of quantity requested [].
% quantQuantity - real array, quantiles  of quantity requested [].
%                 The first row give values of the CDF the and the second row gives the 
%                 quantiles. THe 25-th, 50-th (median), 75-th, 95-th and 99-th 
%                 quantiles are returned.
%
% References:
%
% [1]) D. A. Hill, "Plane wave integral representation for fields in reverberation chambers",
%      IEEE Transactions on Electromagnetic Compatibility, vol. 40, no. 3, pp. 209-217, Aug 1998.
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
% Author: I. D. Flintoft
% Date: 16/08/2016

  validateattributes( quantity , { 'char' } , {} , 'pwbDistDiffuse' , 'quantity' , 1 );
  validateattributes( dist , { 'char' } , {} , 'pwbDistDiffuse' , 'dist' , 2 );
  validateattributes( refValue , { 'double' } , { 'scalar' , 'positive' } , 'pwbDistDiffuse' , 'refValue' , 3 );    
  validatestring( quantity , { 'Fir' , 'Fi' , 'Fi2' , 'F' , 'F2' } );
  validatestring( dist , { 'CDF' , 'CCDF' , 'PDF' } );
  
  % Chi distributions.
  chicdf=@(x,dof) gammainc( 0.5 .* x.^2 ,  0.5 * dof );
  chipdf=@(x,dof) 2.0.^(1.0-0.5*dof) .* x.^(dof-1.0) .* exp(-x.^2./2.0) ./ gamma( 0.5 * dof );
  chiinv=@(p,dof) error( 'chiinv not implemented yet' );
  
  % Number of point for distributions.
  numPoints = 100;
  
  % Quantiles to collect.
  quantQuantity(1,:)  = [ 0.25 , 0.5 , 0.75 , 0.95 , 0.99 ];

  switch( quantity )
  case 'Fir'
    sigma = refValue;
    meanQuantity = 0.0;
    stdQuantity = sigma;
    quantQuantity(2,:) = norminv( quantQuantity(1,:) , 0.0 , sigma );
    x = linspace( norminv( 0.001 , 0.0 , sigma ) , norminv( 0.999 , 0.0 , sigma ) , numPoints );
    switch( dist )
    case 'CDF'
      y = normcdf( x , 0.0 , sigma );
    case 'CCDF'
      y = 1 - normcdf( x , 0.0 , sigma );
    case 'PDF'
      y = normpdf( x , 0.0, sigma );
    otherwise
      assert( false ); 
    end % switch   
  case 'Fi'
    sigma = refValue / sqrt( pi / 2.0 );
    meanQuantity = sigma * sqrt( pi / 2.0 );
    stdQuantity = sigma * sqrt( ( 4.0 - pi ) / 2.0 );
    quantQuantity(2,:) = raylinv( quantQuantity(1,:) , sigma );
    x = linspace( 0 , raylinv( 0.999 , sigma ) , numPoints );
    switch( dist )
    case 'CDF'
      y = raylcdf( x , sigma );
    case 'CCDF'
      y = 1 - raylcdf( x , sigma );
    case 'PDF'
      y = raylpdf( x , sigma );
    otherwise
      assert( false ); 
    end % switch  
  case 'Fi2'
    sigma = sqrt( refValue / 2.0 );
    meanQuantity = 2.0 * sigma^2;
    stdQuantity = 2.0 * sigma^2;
    quantQuantity(2,:) = expinv( quantQuantity(1,:) , 2.0 * sigma^2 );
    x = linspace( 0 ,  expinv( 0.999 , 2.0 * sigma^2 ) , numPoints );
    switch( dist )
    case 'CDF'
      y = expcdf( x , 2.0 * sigma^2 );
    case 'CCDF'
      y = 1 - expcdf( x , 2.0 * sigma^2 );
    case 'PDF'
      y = exppdf( x , 2.0 * sigma^2 );
    otherwise
      assert( false ); 
    end % switch
  case 'F'
    sigma = 160.0 * refValue / 15.0 / sqrt( 2.0 * pi );
    meanQuantity = 15.0 * sqrt( 2.0 * pi ) * sigma / 16.0;
    stdQuantity =  sqrt( 6.0 - 2.0 * pi * ( 15/16 )^2 ) * sigma;
    quantQuantity(2,:) = sigma .* chiinv( quantQuantity(1,:) , 6 );
    x = linspace( 0 , sigma * chiinv( 0.999 , 6 ) , numPoints );
    switch( dist )
    case 'CDF'
      y = chicdf( x ./ sigma , 6 );
    case 'CCDF'
      y = 1 - chicdf( x ./ sigma , 6 );
    case 'PDF'
      y = chipdf( x ./ sigma , 6 ) / sigma;
    otherwise
      assert( false ); 
    end % switch  
  case 'F2'
    sigma = sqrt( refValue / 6.0 );
    meanQuantity = 6 * sigma^2;
    stdQuantity = sqrt( 12.0 ) * sigma^2; 
    quantQuantity(2,:) = sigma^2 .* chi2inv( quantQuantity(1,:) , 6 );
    x = linspace( 0 , sigma^2 .* chi2inv( 0.999 , 6 ) , numPoints );
    switch( dist )
    case 'CDF'
      y = chi2cdf( x ./ sigma^2 , 6 );
    case 'CCDF'
      y = 1 - chi2cdf( x ./ sigma^2 , 6 );
    case 'PDF'
      y = chi2pdf( x ./ sigma^2 , 6 ) / sigma^2;
    otherwise
      assert( false ); 
    end % switch  
  otherwise
    assert( false );
  end % switch

end %function
