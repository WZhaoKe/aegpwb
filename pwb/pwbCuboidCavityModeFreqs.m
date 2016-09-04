function [ f_c , ijkp ] = pwbCuboidCavityModeFreqs( f_max , a , b , c )
% pwbCuboidCavityModeFreqs - mode frequencies of cuboid cavity
%
% [ f_c , ijkp ] = pwbCuboidCavityModes( f_max , a , b , c )
%
% Calculates the TE/TM_ijk resonant frequencies of a cuboid cavity of 
% given dimensions, up to a given maximum frequency [1].
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
%         ijkp(m,n) describers the m-th mode: 
%
%                  n=1 is the x-direction mode index "i"
%                  n=2 is the y-direction mode index "j"
%                  n=3 is the z-direction mode index "k"
%                  n=4 is the mode polarisation TM(0) or TE (1).
%
% References:
%
% [1] D. M. Pozar, "Microwave Engineering", 4th edition, John Wiley & Sons; 2011.
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
% Author: M. P. Robinson
% Date: 09/12/2002
%       08/04/2011 - new interface, Ian Flintoft

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
