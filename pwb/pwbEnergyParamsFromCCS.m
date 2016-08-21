function [ Q , decayRate , timeConst ] = pwbEnergyParamsFromCCS( f , CCS , volume )
    
  c0 = 299792458;

  idx = find( CCS == 0 );
  CCS(idx) = eps;

  decayRate = c0 .* CCS ./ volume;
  timeConst = 1.0 ./ decayRate;
  Q = 2 .* pi .* f .* timeConst;
    
  decayRate(idx) = 0.0;
  timeConst(idx) = Inf;
  Q(idx) = Inf;
  
end % function
