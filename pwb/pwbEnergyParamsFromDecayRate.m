function [ CCS , Q , timeConst ] = pwbEnergyParamsFromDecayRate( f , decayRate , volume )
    
  c0 = 299792458;

  idx = find( decayRate == 0.0 );
  decayRate(idx) = eps;
 
  timeConst = 1.0 ./ decayRate;
  Q = timeConst .* 2 .* pi .* f;
  CCS = decayRate .* volume ./ c0;
 
  timeConst(idx) = Inf; 
  Q(idx) = Inf;
  CCS(idx) = 0.0;

end % function
