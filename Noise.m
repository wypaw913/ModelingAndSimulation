clc; clf; clear; close all;

%number of time increments
N = 1e4;
%fundamental frequency of signal in Hz
f0 = 100;
%sample rate >Nyquist
Fs = 1000;
%sample period
Ts = 1/Fs;
%time vector
time = (0:N-1)*Ts;
%signal amplitude
sig_amp = 3;
%final time show 5 periods
tfinal = (1/f0)*5;

%%Make composite signal using Fourier Synthesis%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%number of harmonics to be combined, three is the number that we shall use
harmonics = 3;

%Add the harmonics together into composite signal
for i=1: harmonics
    
    if i==1
        signal =0;
    end
    
    %successive harmonics with equal amplitudes
    signal = signal + sig_amp*sin(2*pi*f0*i*time);
    
end

%%composite signal is complete%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%mixing in Gaussian noise to signal%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DC_offset = 0;

%amplitude of noise
noise_amp = 10;

%Noise = Amplitude * randn() + DCOffset
noise = noise_amp .* randn(N, 1) + DC_offset;
%noise = 0;

%make noise a horiz vector
noise = noise';

%combine signal and gaussian noise
signal_raw = signal + noise;

%%Signal is complete with noise%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Mix signal with smoothed noise%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%run our smoothing function, second argument is number of pts to 
%use to compute moving average
smoothed_noise = smooth(noise, 3);
smoothed_noise_high = smooth(noise, 11);

%add smoothed noise to signal
signal_smoothed = smoothed_noise + signal;
signal_high = smoothed_noise_high + signal;

%%smoothed noise signal is complete%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compute SNR of raw signal noise
snr_raw = snr(sig_amp, noise);

%compute SNR of smoothed signal noise
snr_smoothed = snr(sig_amp, smoothed_noise);

%compute SNR of high smoothed signal noise
snr_high = snr(sig_amp, smoothed_noise_high);

%%%compute power spectral densities of signal and noise%%%%%%%%%%%%%%%%%%%%

%signal fourier transform
myFFT = fft(signal_raw);
%Double side band spectrum
DSB= abs(myFFT/N);
%lower side band half the length of N
LSB_raw = DSB(1:N/2+1);
%double the amplitude of interior pts
LSB_raw(2:length(LSB_raw)-1) = 2*LSB_raw(2:length(LSB_raw)-1);

%signal fourier transform
myFFT = fft(signal_smoothed);
%Double side band spectrum
DSB= abs(myFFT/N);
%lower side band half the length of N
LSB_smoothed = DSB(1:N/2+1);
%double the amplitude of interior pts and cut end spikes
LSB_smoothed(2:length(LSB_smoothed)-1) = ...
    2*LSB_smoothed(2:length(LSB_smoothed)-1);
%chop inexplicable spike at zero
LSB_smoothed(1) = 0;

%signal fourier transform
myFFT = fft(signal_high);
%Double side band spectrum
DSB= abs(myFFT/N);
%lower side band half the length of N
LSB_high = DSB(1:N/2+1);
%double the amplitude of interior pts
LSB_high(2:length(LSB_high)-1) = 2*LSB_high(2:length(LSB_high)-1);

%create frequency vector 0-600hz half the length of N to match LSB
%and corrected by N to cancel fft scaling
f = Fs*(0:(N/2))/N;

figure(1)
subplot(2,3,1)
hold on
plot(time, signal_raw)
plot(time, signal)
axis([0 tfinal -35 35])
title(["Raw Noisy Signal","SNR=",num2str(snr_raw)])
ylabel('Amplitude (mV)')
xlabel('Time (s)')
legend("Signal","with Noise")
hold off

subplot(2,3,4)
plot(f, LSB_raw)
axis([0 500 0 4])
title("PSD of Signal and Noise")
ylabel('Amplitude (mV)')
xlabel('Frequency (Hz)')

subplot(2,3,2)
hold on
plot(time, signal_smoothed)
plot(time, signal)
axis([0 tfinal -35 35])
title(["Smoothed Noisy Signal (3pts)","SNR=",num2str(snr_smoothed)])
ylabel('Amplitude (mV)')
xlabel('Time (s)')
legend("Signal", "with Noise")
hold off

subplot(2,3,5)
plot(f, LSB_smoothed)
axis([0 500 0 4])
title("PSD of Signal and Smoothed Noise")
ylabel('Amplitude (mV)')
xlabel('Frequency (Hz)')

subplot(2,3,3)
hold on
plot(time, signal_high)
plot(time, signal)
axis([0 tfinal -35 35])
title(["Smoothed Noisy Signal (11pts)","SNR=",num2str(snr_high)])
ylabel('Amplitude (mV)')
xlabel('Time (s)')
legend("Signal", "with Noise")
hold off

subplot(2,3,6)
plot(f, LSB_high)
axis([0 500 0 4])
title("PSD of Signal and Smoothed Noise 11pts")
ylabel('Amplitude (mV)')
xlabel('Frequency (Hz)')


%%Find signal to noise ratio%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%quantifies noise amplitude as the average of top 1% of noise value
%squares signal amplitude and noise amplitude to remove negatives
%then finds RMS values and takes the ratio
function SNR = snr(signal_amp, noise_vect)
    
    %find RMS value of signal power squared
    signal_P = (signal_amp^2) *(1/sqrt(2));

    %find average of top 1% of noise^2 for peak of bell curve
    noise_max = mean( maxk(noise_vect.^2, round(length(noise_vect)/100))...
            , 'all');
    %find rms value
    noise_P = noise_max * (1/sqrt(2));

    SNR = signal_P / noise_P;
    
end
%%SNR computed%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%smoothing filter, ODD points only!
function smoothed_noise = smooth(noise, points)
    
    smoothed_noise = noise;
    %take moving average of n pts at N-n interior pts
    %higher values skip increasingly more
    %end points and increase smoothing of interior pts
    %value must be odd!

    %keeps endpoints the same and shuttle the stencil to interior pts
    for i=1+floor(points/2): length(noise)-floor(points/2)
        
        %reset sum to zero
        sum = 0;
        for j=-floor(points/2): floor(points/2)
            
            %add n pts
            sum = sum + noise(i+j);
            
        end
        %average sum and add smoothed point to output
        smoothed_noise(i) = sum/points;
    end
    
end
