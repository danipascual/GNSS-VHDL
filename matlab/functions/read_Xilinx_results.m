function out = read_Xilinx_results(path,bits,type,offset)
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

    fid = fopen(path);

    out = fscanf(fid,'%s');
    L = length(out);
    L = floor(L/bits);
    out = out(1:L*bits);
    out = reshape(out,bits,L)';
    
    if bits>1
        [~, Lenght] = size(out);
        
        if strcmp(type,'signed')
            Signe=out(:,1);
            
            
            out= bin2dec(out(:,2:end-0)); 
%             out= bin2dec(out(:,offset-(Lenght-2):offset)); 
            
            
            

            Negatius=find(Signe =='1');      
            out(Negatius)=out(Negatius) -2^(Lenght-1);
            
        elseif strcmp(type,'usigned')
            out= bin2dec(out(:,1:end));                     
        end
    else 
        out= bin2dec(out);
    end
    fclose(fid);
end