function  [ mat ] = expandMaterialArray( mat , numFreq , numLayer , matStr )

  mat_numFreq = size( mat , 1 );
  mat_numLayer = size( mat , 2 );

  if ( mat_numLayer ~= numLayer )
    error( 'second dimension of %s must be the same as the number of layers' , matStr );
  end %if

  if ( mat_numFreq ~= numFreq )
    if( mat_numFreq == 1 )
      mat = repmat( mat , [ numFreq , 1 ] ); 
    else
      error( 'first dimension of %s must be 1 or the same as the number of frequencies' , matStr );
    end %if
  end %if

  assert( all( size( mat ) == [ numFreq , numLayer ] ) );
  
end % function
