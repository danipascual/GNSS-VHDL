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


satellits  = 1:27;
L = 4092;   % Code lenght
P = 4;      % Padding between satellites


%% Galileo E1B
codis = importdata('codes_E1B.mat');    % https://github.com/danipascual/GNSS-matlab
codis = (codis+1)/2;
nom = 'PRN_E1B.coe';
fid = fopen(nom,'w+');
fprintf(fid,'memory_initialization_radix = 2;\n');
fprintf(fid,'memory_initialization_vector = \n');
for k=1:length(satellits)
    for i=1:L
        fprintf(fid,[num2str(codis(i,satellits(k))) ', ']);
    end

    % Padding
    if k==length(satellits)
        for i=1:P-1                 % Last one requires a semicolon
            fprintf(fid,['0, ']);        
        end
        fprintf(fid,['0;']);        
    else
        for i=1:P
            fprintf(fid,['0, ']);        
        end        
    end
end
fclose(fid);


%% Galileo E1C
codis = importdata('codes_E1C.mat');    % https://github.com/danipascual/GNSS-matlab
codis = (codis+1)/2;
nom = 'PRN_E1C.coe';
fid = fopen(nom,'w+');
fprintf(fid,'memory_initialization_radix = 2;\n');
fprintf(fid,'memory_initialization_vector = \n');
for k=1:length(satellits)
    for i=1:L
        fprintf(fid,[num2str(codis(i,satellits(k))) ', ']);
    end

    % Padding
    if k==length(satellits)
        for i=1:P-1                 % Last one requires a semicolon
            fprintf(fid,['0, ']);        
        end
        fprintf(fid,['0;']);        
    else
        for i=1:P
            fprintf(fid,['0, ']);        
        end        
    end
end
fclose(fid);
