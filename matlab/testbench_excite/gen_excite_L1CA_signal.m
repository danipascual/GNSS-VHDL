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

% fs = 16*1.023e6; nom = 'SIGNAL_L1CA_1_16_rep5.txt';
fs = 16*1.023e6; nom = 'SIGNAL_L1CA_1_16_rep5_shifted_8191.txt';
% fs = 10*1.023e6; nom = 'SIGNAL_L1CA_1_10_rep5.txt';
% fs = 4*1.023e6; nom = 'SIGNAL_L1CA_1_4_rep5.txt';
% fs = 1*1.023e6; nom = 'SIGNAL_L1CA_1_1_rep5.txt';

[L1CA] = GNSSsignalgen(1, 'L1CA',fs,5);  % https://github.com/danipascual/GNSS-matlab
L1CA = (L1CA+1)/2;

L1CA = circshift(L1CA',8192)';

fileID = fopen(nom,'w');
for i=1:length(L1CA)-1
    fprintf(fileID,num2str(L1CA(i)));
    fprintf(fileID,'\n');
end
fprintf(fileID,num2str(L1CA(i+1)));
fclose(fileID);

