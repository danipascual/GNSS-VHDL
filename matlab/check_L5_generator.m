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

out_real = read_Xilinx_results('../source/GNSS_prn/sim/results/L5_generator_output_real.txt',1,'signed');
out_real = out_real*2-1;

out_imag = read_Xilinx_results('../source/GNSS_prn/sim/results/L5_generator_output_imag.txt',1,'signed');
out_imag = out_imag*2-1;

load('codes_L5I.mat')   % https://github.com/danipascual/GNSS-matlab
load('codes_L5Q.mat')

% PRN 3 first epoch
figure, plot(out_real(1:10230)-codes_L5I(:,3))
figure, plot(out_imag(1:10230)-codes_L5Q(:,3))

% PRN 3 second epoch
figure, plot(out_real(1+10230*1:10230*2)-codes_L5I(:,3))
figure, plot(out_imag(1+10230*1:10230*2)-codes_L5Q(:,3))

% PRN 1 first epoch
idx = 9768;
figure, plot(out_real(1+10230*1+idx:10230*2+idx)-codes_L5I(:,1))
figure, plot(out_imag(1+10230*1+idx:10230*2+idx)-codes_L5Q(:,1))