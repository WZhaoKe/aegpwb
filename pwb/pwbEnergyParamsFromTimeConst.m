function [ CCS , decayRate , Q ] = pwbEnergyParamsFromTimeConst( f , timeConst , volume )
    
  c0 = 299792458;

  idx = find( timeConst == Inf );
  timeConst(idx) = 1e20;
  
  Q = timeConst .* 2 .* pi .* f;
  decayRate = 1.0 ./ timeConst;
  CCS = decayRate .* volume ./ c0;
 
  decayRate(idx) = 0.0;
  Q(idx) = Inf;
  CCS(idx) = 0.0;
  
end % function
