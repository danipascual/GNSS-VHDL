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

out = read_Xilinx_results('../source/GNSS_prn/sim/results/L1_CA_generator_output.txt',1,'signed');
out = out*2-1;

load('codes_L1CA.mat')  % https://github.com/danipascual/GNSS-matlab

% PRN 3 first epoch
figure, plot(out(1:1023)-codes_L1CA(:,3))

% PRN 3 second epoch
figure, plot(out(1+1023*1:1023*2)-codes_L1CA(:,3))

% PRN 1 first epoch
idx = 975;
figure, plot(out(1+1023*1+idx:1023*2+idx)-codes_L1CA(:,1))