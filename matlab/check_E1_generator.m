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

out_B = read_Xilinx_results('../source/GNSS_prn/sim/results/E1_generator_output_B.txt',1,'signed');
out_B = out_B*2-1;

out_C = read_Xilinx_results('../source/GNSS_prn/sim/results/E1_generator_output_C.txt',1,'signed');
out_C = out_C*2-1;

load('codes_E1B.mat')   % https://github.com/danipascual/GNSS-matlab
load('codes_E1C.mat')

% PRN 1 first epoch
figure, plot(out_B(1:4092)-codes_E1B(:,1))
figure, plot(out_C(1:4092)-codes_E1C(:,1))

% PRN 1 second epoch
figure, plot(out_B(1+4092*1:4092*2)-codes_E1B(:,1))
figure, plot(out_C(1+4092*1:4092*2)-codes_E1C(:,1))

% PRN 2 first epoch
idx = 2906;
figure, plot(out_B(1+4092*1+idx:4092*2+idx)-codes_E1B(:,2))
figure, plot(out_C(1+4092*1+idx:4092*2+idx)-codes_E1C(:,2))