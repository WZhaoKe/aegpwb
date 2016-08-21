function [ f_c , ijkp ] = pwbCuboidCavityModeFreqs( f_max , a , b , c )
%
% pwbCuboidCavityModeFreqs - Calculates the TE/TM_ijk resonant frequencies 
%                            of a rectangular cavity of given dimensions, 
%                            up to a given maximum frequency.
%
% [ f_c , ijkp ] = pwbCuboidCavityModes( f_max , a , b , c )
%
% Inputs:
%
% f_max - real scalar, maximum mode frequency [Hz].
% a     - real scalar, length of cavity in x-direction [m].
% b     - real scalar, length of cavity in y-direction [m].
% c     - real scalar, length of cavity in z-direction [m].
%
% Outputs:
%
% f_c   - real vector, mode cut-off frequencies is ascending order [Hz].
% ijkp -  integer array, mode indices and polarisation [-].
%
%         ijk(p,q) describers the p-th mode: 
%
%                  q=1 is the x-direction mode index "i"
%                  q=2 is the y-direction mode index "j"
%                  q=3 is the z-direction mode index "k"
%                  q=4 is the mode polarisation TM(0) or TE (1).
%

%
% MPR 9/12/2002
% Interface changes IDF 08/04/2011.
%

  c0 = 299792458;
  
  dims = [ a , b , c ];

  % Check for three dimensions
  if length( dims ) ~= 3
    error( 'wrong number of cavity dimensions' );
  end

  if sum( dims > 0 ) < 3
    error( 'cavity dimensions must all be positive' );
  end

  if ~( f_max > 0 )
    error( 'maximum frequency must be positive' );
  end

  f_c = [];
  ijkp = [];

  i_max = 2 * dims(1) * f_max / c0;
  j_max = 2 * dims(2) * f_max / c0;
  k_max = 2 * dims(3) * f_max / c0;

  if( i_max * j_max * k_max > 1e6 )
    error( 'too many modes!' );
  end

  for i=0:i_max
    for j=0:j_max
      for k=0:k_max
        f_res = 0.5 * c0 * sqrt( ( i / dims(1) )^2 + ( j / dims(2) )^2 + ( k / dims(3) )^2 );
        if( f_res < f_max )
          % TM modes.
          if( i~=0 && j ~= 0 )
            f_c = [ f_c ; f_res ];
            ijkp = [ ijkp ; i , j , k , 0 ];
          end % if
          % TE modes.
          if( ~( i==0 && j == 0 ) && k ~= 0 )
            f_c = [ f_c ; f_res ];
            ijkp = [ ijkp ; i , j , k , 1 ];
          end % if
        end %if
      end %for
    end % for
  end % for

  % Sort into ascending order of resonant frequencies.
  [ f_c , i ] = sort( f_c );
  ijkp = ijkp(i,:);

end % function
