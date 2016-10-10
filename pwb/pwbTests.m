function pwbTests()
% pwbTests - Run toolbox test-suite
%
% pwbTests()
%
% Runs all tests found in the tests sub-directory of the installation 
% directory of the function. Any m-files in the tests sub-directory
% with name beginning pwbTest is assumed to be a test and is called.
% All test functions should return a single boolean parameter indicating
% whether the test was successful or not.
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
% Date: 01/09/2016

  % Get base name of solver installation.
  baseName = fileparts( which( 'pwbTests' ) );
  
  % Test folder.
  testDir = [ baseName , '/tests' ];
  addpath( testDir );
   
  % Any file in the test directory with name starting pwbsTest is a test.
  testList = dir( [ testDir , '/pwbTest*.m'] );

  % Run tests
  for testIdx = 1:length( testList )
    [ ~ , testName , suffix ] = fileparts( testList(testIdx).name );
    fprintf( 'running test: %s ... ' ,  testName );
    isPass(testIdx) = feval( testName );
    if( isPass(testIdx) )
      fprintf( 'pass\n' );
    else
      fprintf( 'fail\n' );
    end % if
  end % for

  fprintf( '\npassed %d out of %d tests\n\n' , sum( isPass == true ) , length( testList ) );
  
  rmpath( testDir );

end % function
