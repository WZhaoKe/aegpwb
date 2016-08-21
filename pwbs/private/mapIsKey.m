function [ isKey ] = mapIsKey( map , key )

  if( isfield( map , key ) )
    isKey = true;
  else
    isKey = false;
  end % if

end % function
