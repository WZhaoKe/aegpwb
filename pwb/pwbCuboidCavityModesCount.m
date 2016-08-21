function [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesCount( f , a  , b , c )
%
% pwbCuboidCavityModesCount - modes in a cuboid cavity by exact mode counting.
%
% [ numModes , modeDensity , f_1 , f_60 ] = pwbCuboidCavityModesCount( f , a  , b , c )
%
% Inputs:
%
% f       - real vector, frequency (Hz).
% a, b, c - real scalars, cavity linear dimensions [m].
%
% Outputs:
%
% numModes    - integer vector, cumulative number of modes below frequencies in f [-].
% modeDensity - real vector, density of modes at frequencies in f [/Hz]. 
% f_1         - real scalar, frequency at which numModes is greater than or equal to 1 [Hz].
% f_60        - real scalar, frequency at which numModes is greater than or equal to 60 [Hz].
%

  % Get mode frequencies.
  [ f_c , ~ ] = pwbCuboidCavityModeFreqs( f(end) , a , b , c );

  
  if( ~isempty( f_c ) )
  
    f_1 = f_c(1);
    f_60 = f_c(60);
  
    % Find cumulative number of modes. Modes could be degenerate!
    for p=1:length( f )
      numModes(p) = sum( f_c < f(p) );
    end % for

    % Differentiate for mode density. Frequencies may not have uniform spacing!
    % [FIXME] This will give poor result if the sampling rate is low!
    modeDensity = diff( numModes ) ./ ( f(2:end) - f(1:end-1) );
    modeDensity(end+1) = ( numModes(end) - numModes(end-1) ) / ( f(end) - f(end-1) );
    
  else
  
    % Requested frequencies below lowest mode.
    f_1 = NaN;
    f_60 = NaN;
    numModes = zeros( size( f ) );
    modeDensity = zeros( size( f ) );
    
  end % if

end % function
