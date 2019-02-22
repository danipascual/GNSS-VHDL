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

out_E5I = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_I_10MHz.txt',8,'signed');
out_E5Q = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_Q_10MHz.txt',8,'signed');
[E5I, E5Q] = GNSSsignalgen(1,'E5',10*1.023e6,2);   % https://github.com/danipascual/GNSS-matlab

% out_E5I = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_I_20MHz.txt',8,'signed');
% out_E5Q = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_Q_20MHz.txt',8,'signed');
% [E5I, E5Q] = GNSSsignalgen(1,'E5',20*1.023e6,2); % https://github.com/danipascual/GNSS-matlab

% out_E5I = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_I_50MHz.txt',8,'signed');
% % out_E5Q = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_Q_50MHz.txt',8,'signed');
% [E5I, E5Q] = GNSSsignalgen(1,'E5',50*1.023e6,2);     % https://github.com/danipascual/GNSS-matlab

% out_E5I = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_I_100MHz.txt',8,'signed');
% out_E5Q = read_Xilinx_results('../source/GNSS_signal/sim/results/E5_signal_generator_output_Q_100MHz.txt',8,'signed');
% [E5I, E5Q] = GNSSsignalgen(1,'E5',100*1.023e6,2);  % https://github.com/danipascual/GNSS-matlab


Pot = sum(abs(out_E5I).^2)/length(out_E5I);
out_E5I = out_E5I/sqrt(Pot);

Pot = sum(abs(out_E5Q).^2)/length(out_E5Q);
out_E5Q = out_E5Q/sqrt(Pot);

Pot = sum(abs(E5I).^2)/length(E5I);
E5I = E5I/sqrt(Pot);

Pot = sum(abs(E5Q).^2)/length(E5Q);
E5Q = E5Q/sqrt(Pot);

figure, stairs(E5I(1:500))
hold on, stairs(out_E5I(1:500),'r')

figure, plot(out_E5I(1:length(E5I))-E5I)     % The small diference comes from the 8 bit quantization
figure, plot(out_E5Q(1:length(E5I))-E5Q)     % Xilinx is not good rounding reals to integers, and the "t" sequence may not be
                                             % perfect. But the resulting errors are neglible
                                             
figure; hist((out_E5I(1:length(E5I))-E5I),1001)
                                            
ACF = abs((ifft(fft(E5I).*conj(fft(out_E5I(1:length(E5I)))))));
figure, plot((ACF))




