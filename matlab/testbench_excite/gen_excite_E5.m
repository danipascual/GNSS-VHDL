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

load('codes_E5aI.mat')   % https://github.com/danipascual/GNSS-matlab
load('codes_E5bI.mat')
load('codes_E5aQ.mat')
load('codes_E5bQ.mat')

codeE5aI = codes_E5aI(:,1)';
codeE5bI = codes_E5bI(:,1)';
codeE5aQ = codes_E5aQ(:,1)';
codeE5bQ = codes_E5bQ(:,1)';

codeE5aI = (codeE5aI+1)/2;
codeE5bI = (codeE5bI+1)/2;
codeE5aQ = (codeE5aQ+1)/2;
codeE5bQ = (codeE5bQ+1)/2;

codeE5aI_ = codeE5aI;
codeE5bI_ = codeE5bI;
codeE5aQ_ = codeE5aQ;
codeE5bQ_ = codeE5bQ;

for i=1:4
    codeE5aI = [codeE5aI codeE5aI_];
    codeE5bI = [codeE5bI codeE5bI_];
    codeE5aQ = [codeE5aQ codeE5aQ_];
    codeE5bQ = [codeE5bQ codeE5bQ_];    
end

nom = 'PRN_E5aI_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE5aI)-1
    fprintf(fileID,num2str(codeE5aI(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE5aI(i+1)));
fclose(fileID);

nom = 'PRN_E5bI_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE5bI)-1
    fprintf(fileID,num2str(codeE5bI(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE5bI(i+1)));
fclose(fileID);

nom = 'PRN_E5aQ_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE5aQ)-1
    fprintf(fileID,num2str(codeE5aQ(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE5aQ(i+1)));
fclose(fileID);

nom = 'PRN_E5bQ_1_rep5.txt';
fileID = fopen(nom,'w');
for i=1:length(codeE5bQ)-1
    fprintf(fileID,num2str(codeE5bQ(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(codeE5bQ(i+1)));
fclose(fileID);
