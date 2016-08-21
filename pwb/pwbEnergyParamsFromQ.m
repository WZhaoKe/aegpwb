function [ CCS , decayRate , timeConst ] = pwbEnergyParamsFromQ( f , Q , volume )
    
  c0 = 299792458;

  idx = find( Q == Inf );
  Q(idx) = 1e20;
  
  timeConst = Q ./ ( 2 .* pi .* f );
  decayRate = 1.0 ./ timeConst;
  CCS = decayRate .* volume ./ c0;
 
  decayRate(idx) = 0.0;
  timeConst(idx) = Inf;
  CCS(idx) = 0.0;
  
end % function
