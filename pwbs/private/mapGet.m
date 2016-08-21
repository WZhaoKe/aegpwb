function [ value ] = mapGet( map , key )

  if( isfield( map , key ) )
    value = getfield( map , key );
  else
    error( 'cannot find key %s in map' , key );
  end % if

end % function
