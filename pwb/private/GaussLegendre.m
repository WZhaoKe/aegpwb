function [ abscisas , weights ] = GaussLegendre( order )
%
%
% References:
%
% [1] G. H. Golub and J. H. Welsch, "Calculation of Gauss quadrature rules",
%     Journal of Math. Comp., vol. 23, pp. 221-230, 1969. 
%
% [2] A. Townsend, "The race for high order Gauss?Legendre quadrature", 
%     SIAM Newsletter, http://math.mit.edu/~ajt/papers/QuadratureEssay.pdf
%     From: http://mathoverflow.net/questions/203863/computing-gauss-legendre-quadrature-for-large-n#
%
% [3] I. Bogaert, "Iteration-free computation of Gauss--Legendre quadrature nodes and weights",
%     SIAM Journal on Scientific Computing, 2014, Vol. 36, No. 3 : pp. A1008-A1026.
%
% [4] https://sourceforge.net/projects/fastgausslegendrequadrature
%
% [5] D. Day and L. Romero. "Roots of polynomials expressed in terms of orthogonal polynomials",
%     SIAM journal on numerical analysis 43.5 (2005): 1969-1987.
%

  n = 1:order-1;
  gamma = n ./ sqrt( 4.0 * n.^2 - 1 );
  C = diag( gamma , 1 ) + diag( gamma , -1 );
  [ vector , lambda ] = eig( C );
  [ abscisas , idx ] = sort( diag( lambda ) );
  vector = vector(:,idx)';
  weights = 2.0 * vector(:,1).^2;

end % function
