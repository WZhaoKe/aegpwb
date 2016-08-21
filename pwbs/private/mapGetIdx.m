function [ key ] = mapGetIdx( map , value )

  idx = find( cell2mat( struct2cell( map ) ) == value );  
  keys = fieldnames( map );
  key = keys{idx};
  
end % function
