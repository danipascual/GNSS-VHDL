out = read_Xilinx_results('../GNSS_signal/results/L1_CA_mem_1_1_output.txt',1,'signed');
out = out*2-1;
fs = 1.023e6;
coh_samples = 1e-3*fs;
idx = 2978;


[L1CA_1] = GNSSsignalgen(1,'L1CA',fs,5);
[L1CA_2] = GNSSsignalgen(2,'L1CA',fs,5);


figure, plot(out(1:length(L1CA_1))-L1CA_1)
ACF = ifft(fft(L1CA_1(1:coh_samples)) .*conj(fft(out(1:coh_samples))));
figure, plot(abs(ACF))

% Change address with same satellite
% ACF = ifft(fft(L1CA_1(1:coh_samples)) .*conj(fft(out(idx:idx+coh_samples-1))));
% figure, plot(abs(ACF))

% Change satellite
figure, plot(out(idx:idx+coh_samples-1)-L1CA_2(1:coh_samples))
ACF = ifft(fft(L1CA_2(1:coh_samples)) .*conj(fft(out(idx:idx+coh_samples-1))));
figure, plot(abs(ACF))

