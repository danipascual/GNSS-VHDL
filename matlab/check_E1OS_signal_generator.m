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

out_E1OS = read_Xilinx_results('../source/GNSS_signal/sim/results/E1OS_signal_generator_output_8MHz.txt',8,'signed');
E1OS = GNSSsignalgen(1,'E1OS',8*1.023e6,2);    % https://github.com/danipascual/GNSS-matlab

% out_E1OS = read_Xilinx_results('../source/GNSS_signal/sim/results/E1OS_signal_generator_output_10MHz.txt',8,'signed');
% E1OS = GNSSsignalgen(1,'E1OS',10*1.023e6,2);    % https://github.com/danipascual/GNSS-matlab

% out_E1OS = read_Xilinx_results('../source/GNSS_signal/sim/results/E1OS_signal_generator_output_12MHz.txt',8,'signed');
% E1OS = GNSSsignalgen(1,'E1OS',12*1.023e6,2);    % https://github.com/danipascual/GNSS-matlab

% out_E1OS = read_Xilinx_results('../source/GNSS_signal/sim/results/E1OS_signal_generator_output_20MHz.txt',8,'signed');
% E1OS = GNSSsignalgen(1,'E1OS',20*1.023e6,2);    % https://github.com/danipascual/GNSS-matlab

% out_E1OS = read_Xilinx_results('../source/GNSS_signal/sim/results/E1OS_signal_generator_output_50MHz.txt',8,'signed');
% E1OS = GNSSsignalgen(1,'E1OS',50*1.023e6,2);    % https://github.com/danipascual/GNSS-matlab

Pot = sum(abs(out_E1OS).^2)/length(out_E1OS);
out_E1OS = out_E1OS/sqrt(Pot);

figure, plot(out_E1OS(1:length(E1OS))-E1OS)     % The small diference comes from the 8 bit quantization

figure, stairs(E1OS(1:500))
hold on, stairs(out_E1OS(1:500),'r')

figure, plot(out_E1OS(1:length(E1OS))-E1OS)  % The small diference comes from the 8 bit quantization
                                             % Xilinx is not good rounding reals to integers, and the "t" sequence may not be
                                             % perfect. But the resulting errors are neglible.
                                             
figure; hist((out_E1OS(1:length(E1OS))-E1OS))
                                            
ACF = abs((ifft(fft(E1OS).*conj(fft(out_E1OS(1:length(E1OS)))))));
figure, plot((ACF))