function pwbsDrawEMT( pwbm )
% pwbsDrawEMT - Output toplogical diagram to file and display on screen.
%
% pwbsDrawEMT( pwbm )
%
% Inputs:
%
% pwbm   - structure, contains the model state.
%

% This file is part of aegpwb.
%
% aegpwb power balance toolbox and solver.
% Copyright (C) 2016 Ian Flintoft <ian.flintoft@googlemail.com>
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
% Author: Ian Flintoft <ian.flintoft@googlemail.com>
% Date: 19/08/2016

  nextRef = 1;
  
  dotFileName = [ pwbm.modelName , '_EMT.dot' ];
  epsFileName = [ pwbm.modelName , '_EMT.eps' ];
  pngFileName = [ pwbm.modelName , '_EMT.png' ];
  
  fp = fopen( dotFileName , 'w' );
  fprintf( fp , 'digraph pwb_model {\n' );
  fprintf( fp , '	rankdir=LR;\n' );
  fprintf( fp , '	size="8,5"\n' );
  fprintf( fp , '	node [ shape = circle , fontname = "Helvetica" , fontsize = 10 , height = 0.1 , width = 0.1 , margin = 0.01 ,  style=filled ];\n' );
  fprintf( fp , '	edge [ fontname = "Helvetica" , forcelabels= true , fontsize = 10 ];\n' );  
  if( pwbm.isExtCavity )  
    fprintf( fp , '	"%s" [shape=circle , regular=1, style=filled , fillcolor=coral ];\n' , 'EXT' );
  end % if
  for cavityIdx=2:pwbm.numCavities
    fprintf( fp , '	"%s" [ shape=circle fillcolor=cyan ];\n' , pwbm.cavities(cavityIdx).tag );
  end % for
  for edgeIdx = 1:size( pwbm.edges , 1)
    node1 = pwbm.edges{edgeIdx,1};
    node2 = pwbm.edges{edgeIdx,2};
    nodeLabel = pwbm.edges{edgeIdx,3};
    if( strcmp( node1 , 'REF' ) )
      node1 = sprintf( 'REF%d' , nextRef );
      nextRef = nextRef + 1;
      fprintf( fp , '"%s" [shape=point , label ="", width=0.02 , height=0.02, regular=1, style=filled , fillcolor=black ];\n' , node1 );
    end % if
    if( strcmp( node2 , 'REF' ) )
      node2 = sprintf( 'REF%d' , nextRef );
      nextRef = nextRef + 1;
      fprintf( fp , '"%s" [shape=point , label ="", width=0.02 , height=0.02, regular=1, style=filled , fillcolor=black ];\n' , node2 );
    end % if   
    switch( pwbm.edges{edgeIdx,4} )
    case 'Antenna'
      arrowType = 'normal';
    case 'Absorber'
      arrowType = 'normal';
    case 'PowerSource'
      arrowType = 'invdot';
    case 'PowerDensitySource'
      arrowType = 'emptyodot';      
    case 'Aperture'
      arrowType = 'empty';
    end % switch 
    fprintf( fp , '	%s -> %s [ label = "%s" , arrowhead = "%s" ];\n' , node1 , node2 , nodeLabel , arrowType );
  end % for
  fprintf( fp , '}\n' );
  fclose( fp );
  
  [ status , output ] = system( 'dot -?' );
  if( status == 0 )
    [ status , output ] = system( sprintf( 'dot -Teps %s -o %s' , dotFileName , epsFileName ) );
    [ status , output ] = system( sprintf( 'dot -Tpng %s -o %s' , dotFileName , pngFileName ) );
    [ I , map ] = imread( pngFileName );
    figure();
    imshow( I , map );
  else
    warning( 'dot command failed - is graphviz installed and in command path?' );
  end % if
  
end % function
