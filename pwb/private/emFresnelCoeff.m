
function [ rhoTE , rhoTM , tauTE , tauTM ] = emFresnelCoeff( na , nb , theta ) 
%
% emFresnelCoeff - Fresnel coefficients for isotropic lossy media.
%
% [ rhoTE , rhoTM , tauTE , tauTM ] = emFresnelCoeff( na , nb , theta ) 
% 
% Inputs:
%
% na    - complex refractive index of left medium (-)
% nb    - complex refractive index of right medium (-)
% theta - vector in incident angles from left medium (radians)
%
% Outputs:
%
% Fresnel coefficient from side a to b:
%
% rhoTE - reflection coefficent for TE polarisation (-)
% rhoTM - reflection coefficent for TM polarisation (-)
% tauTE - transmission coefficent for TE polarisation (-)
% tauTM - transmission coefficent for TM polarisation (-)
%

  cost = cos( theta );
  sint = sin( theta );

  x = sqrt( ( nb / na ).^2 - sint.^2 );
  y = ( nb / na )^2 .* cost;

  rhoTE = ( cost - x ) ./ ( cost + x );
  rhoTM = ( x - y ) ./ ( x + y);

  tauTE = 1 + rhoTE;
  tauTM = 1 + rhoTM;

end % function
