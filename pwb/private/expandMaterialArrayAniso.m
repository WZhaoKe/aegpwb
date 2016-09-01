function  [ mat ] = expandMaterialArrayAniso( mat , numFreq , numLayer , matStr )

  mat_numFreq = size( mat , 1 );
  mat_numLayer = size( mat , 2 );
  mat_numAniso = size( mat , 3 );

  if ( mat_numLayer ~= numLayer )
    error( 'second dimension of %s must be the same as the number of layers' , matStr );
  end %if

  if ( mat_numFreq ~= numFreq )
    if( mat_numFreq == 1 )
      mat = repmat( mat , [ numFreq , 1  , 1 ] ); 
    else
      error( 'first dimension of %s must be 1 or the same as the number of frequencies' , matStr );
    end %if
  end %if

  if ( mat_numAniso == 1 )
    mat(:,:,2) = mat(:,:,1);
    mat(:,:,3) = mat(:,:,1);
  elseif( mat_numAniso == 2 )
    mat(:,:,3) = mat(:,:,2);
  elseif( mat_numAniso > 3 )
    error( 'third dimension of %s must be 1, 2 or 3' , matStr );
  end %if

  assert( all( size( mat ) == [ numFreq , numLayer , 3 ] ) );
  
end % function
