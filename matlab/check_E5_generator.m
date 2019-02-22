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

out_E5aI = read_Xilinx_results('../source/GNSS_prn/sim/results/E5_generator_output_E5aI.txt',1,'signed');
out_E5aI = out_E5aI*2-1;

out_E5bI = read_Xilinx_results('../source/GNSS_prn/sim/results/E5_generator_output_E5bI.txt',1,'signed');
out_E5bI = out_E5bI*2-1;

out_E5aQ = read_Xilinx_results('../source/GNSS_prn/sim/results/E5_generator_output_E5aQ.txt',1,'signed');
out_E5aQ = out_E5aQ*2-1;

out_E5bQ = read_Xilinx_results('../source/GNSS_prn/sim/results/E5_generator_output_E5bQ.txt',1,'signed');
out_E5bQ = out_E5bQ*2-1;

load('codes_E5aI.mat')   % https://github.com/danipascual/GNSS-matlab
load('codes_E5aQ.mat')   
load('codes_E5bI.mat')   
load('codes_E5bQ.mat')   

% PRN 2 first epoch
figure, plot(out_E5aI(1:10230)-codes_E5aI(:,2))
figure, plot(out_E5aQ(1:10230)-codes_E5aQ(:,2))
figure, plot(out_E5bQ(1:10230)-codes_E5bQ(:,2))
figure, plot(out_E5bI(1:10230)-codes_E5bI(:,2))

% PRN 2 second epoch
figure, plot(out_E5aI(1+10230*1:10230*2)-codes_E5aI(:,2))
figure, plot(out_E5aQ(1+10230*1:10230*2)-codes_E5aQ(:,2))
figure, plot(out_E5bI(1+10230*1:10230*2)-codes_E5bI(:,2))
figure, plot(out_E5bQ(1+10230*1:10230*2)-codes_E5bQ(:,2))

% PRN 1 first epoch
idx = 9767;
figure, plot(out_E5aI(1+10230*1+idx:10230*2+idx)-codes_E5aI(:,1))
figure, plot(out_E5aQ(1+10230*1+idx:10230*2+idx)-codes_E5aQ(:,1))
figure, plot(out_E5bI(1+10230*1+idx:10230*2+idx)-codes_E5bI(:,1))
figure, plot(out_E5bQ(1+10230*1+idx:10230*2+idx)-codes_E5bQ(:,1))