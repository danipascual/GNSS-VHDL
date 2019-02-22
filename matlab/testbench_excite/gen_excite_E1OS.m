%==========================================================================
% 
%--------------------------------------------------------------------------
% Version log (main changes)
%   02/06/2016 --> Log started
%--------------------------------------------------------------------------
% Author: Daniel Pascual (daniel.pascual at protonmail.com) 
% Copyright 2017 Daniel Pascual
% License: GNU GPLv3
%==========================================================================

% Copyright 2017 Daniel Pascual
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%%

load('codes_E1B.mat')       % https://github.com/danipascual/GNSS-matlab
load('codes_E1C.mat')

codeE1B = codes_E1B(:,1)';
codeE1C = codes_E1C(:,1)';

codeE1B = (codeE1B+1)/2;
codeE1C = (codeE1C+1)/2;

codeE1B_ = codeE1B;
codeE1C_ = codeE1C;

for i=1:4
    codeE1B = [codeE1B codeE1B_];
    codeE1C = [codeE1C codeE1C_];
end

nom = 'PRN_E1B_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE1B)-1
    fprintf(fileID,num2str(codeE1B(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE1B(i+1)));
fclose(fileID);

nom = 'PRN_E1C_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE1C)-1
    fprintf(fileID,num2str(codeE1C(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE1C(i+1)));
fclose(fileID);
