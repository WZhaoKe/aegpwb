function [ data ] = pwbImportAndInterp( f , fileName )
%
% pwbInterpFile - Load  and interpolate frequency dependent data from an ASCII file.
%
% [ data ] = pwbInterpFile( f , fileName )
%
% Inputs:
%
% f        - real vector, frequencies to determine CCS at [Hz].
% fileName - string, name of file contaiing frequency dependent data.
% 
%            File format: 
%
%            # Optional header/comment using initial # character. 
%            # M+1 columns of real data with N rows
%            # Column 1: Frequency [Hz].
%            # Column 2: Data vector 1
%            # ....................
%            # Column ND+1: Data vector ND
%            # f [Hz]  DV1 [-] .....  DVM [-] 
%            ft(1)     DV1(1)          DVM(1) 
%            ......    .....   .....   ......
%            ft(N)     DV1(N)  .....   DVM(N)
%
%            The first frequency, ft(1), must less than or equal to the 
%            lowest frequency in the model and the last frequency, ft(N),
%            must greater than or equal to the highest frequency in the model.
%            The data at the frequencies given in the file are interpolated 
%            onto the frequencies requested in th model. 
%
% Outputs:
%
% data - real array (NxM), of data in file interpolated onto frequencies in f.
%

  if( ~exist( fileName , 'file' ) )
    error( 'cannot find file %s' , fileName );
  end % if
  
  fid = fopen( fileName , 'rt' );
  if( fid == -1 )
    error( 'failed to open file %s for reading' , fileName );
  end % if

  % Detect number of header lines in file.
  headerLines = 0;
  line = fgets( fid );
  trimmed =  strtrim( line );
  while( trimmed(1) == '#' )
    headerLines = headerLines + 1;
    line = fgets( fid );
    trimmed =  strtrim( line );
  end % while
  fclose( fid );

  % Now read data en-mass.
  datat = dlmread( fileName , '' , headerLines , 0 );
  
  % Frequencies in tables.
  ft = datat(:,1);
  validateattributes( ft , { 'double' } , { 'vector' , 'real' , 'nonnegative' , 'increasing' } , 'pwbFileCCS' , 'data column' , 1 );
  
  % Must span requested range.
  if( f(1) < ft(1) || f(end) > ft(end) )
    error( 'frequency range in file, %g-%g, does not span requested frequencies %g-%g' , ft(1) , ft(end) , f(1) , f(end) );
  end % if
    
  % Interpolate.
  data = interp1( ft , datat(:,2:end) , f );

end %function
