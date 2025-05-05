%import rain audio
[audio, Fs] = audioread("16kHzRain15sec.wav");
%average many magnitude responses from signal:
N = 4096; %size of FFT's
sumOfSpectrums = zeros(1,N);
for i = 1:(length(audio)/N)
    sumOfSpectrums(1,:) = abs(fftshift(fft(audio(i+N*(i-1)):(i*N),N)));
end
sumOfSpectrums = (1/(length(audio)/N)) * sumOfSpectrums;
%FFT of segment, smooth it
spec = abs(fftshift(fft(audio,4096)));
windowSize = 50; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
specSmooth = filter(b,a,spec);
%plot fft and spectrogram
subplot(4,1,1)
spectrogram(audio,'yaxis')
title('\fontsize{19}Spectrogram')
subplot(4,1,2)
plot(linspace(-Fs/2,Fs/2,4096),spec,LineWidth=1.2)
title('\fontsize{19} FFT')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
xlim([-5000 5000])
subplot(4,1,3)
plot(linspace(-Fs/2,Fs/2,4096),specSmooth,LineWidth=1.2)
title('\fontsize{19} Smoothed FFT')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
xlim([-5000 5000])
subplot(4,1,4)
plot(linspace(-Fs/2,Fs/2,N),sumOfSpectrums,LineWidth=1.2)
title('\fontsize{19} Averaged FFT')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
sgtitle("\fontsize{23} Analysis of 16kHz Rain Sound Audio")
xlim([-5000 5000])


%% use frequency sampling to create filter
%define filter length and used smoothed response as amplitude input for
%frequency sampling method
N = 20;
ampl = flip(specSmooth(1:end/2));
ampl = ampl/(0.5*max(ampl));
testFilt = fir2(N, linspace(0,1,2048), ampl);
%plot desired magnitude response, generated filter impulse and magnitude
%response, and pole zero plot of filter
subplot(3,2,1:2)
plot(linspace(-Fs/2,Fs/2,4096),specSmooth,LineWidth=1.2)
title('\fontsize{19} Desired Spectrum')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
xlim([-5000 5000])
subplot(3,2,3)
plot(testFilt,LineWidth=1.2)
title('\fontsize{19} Impulse Response of Generated Filter')
xlabel('\fontsize{16} n')
ylabel('\fontsize{16} h(n)')
subplot(3,2,5:6)
plot(linspace(-Fs/2,Fs/2,4096),abs(fftshift(fft(testFilt,4096))),LineWidth=1.2)
title('\fontsize{19} Frequency Response of Generated Filter')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
xlim([-5000 5000])
subplot(3,2,4)
zplane(testFilt)
sgtitle("\fontsize{23} Design of Colored Noise Filter Using Frequency Sampling of Rain Sound Spectrum")
%% create test output 
w = randn(1,64000);
x = filter(testFilt,1,w);
audiowrite("generatedNoise1.3.wav",x,16000);


%% pink noise filter
%generate pink noise magnitude response
N = 20;
pink = linspace(1,0,10);
%use frequency sampling to generate filter
testFilt2 = fir2(N, linspace(0,1,10), pink);
%plot desired magnitude response, generated filter impulse and magnitude
%response, and pole zero plot of filter
subplot(3,2,1:2)
plot(linspace(-Fs/2,Fs/2,19),[flip(pink) pink(2:end)],LineWidth=1.2)
title('\fontsize{19} Desired Spectrum')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
subplot(3,2,3)
plot(testFilt2,LineWidth=1.2)
title('\fontsize{19} Impulse Response of Generated Filter')
xlabel('\fontsize{16} n')
ylabel('\fontsize{16} h(n)')
subplot(3,2,5:6)
plot(linspace(-Fs/2,Fs/2,4096),abs(fftshift(fft(testFilt2,4096))),LineWidth=1.2)
title('\fontsize{19} Frequency Response of Generated Filter')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
xlim([-5000 5000])
subplot(3,2,4)
zplane(testFilt2)
sgtitle("\fontsize{23} Design of Colored Noise Filter Using Frequency Sampling of Pink Noise Spectrum")
%% create test output
w = randn(1,64000);
w = w / max(w);
x = filter(testFilt2,1,w);
audiowrite("generatedNoise2.wav",x,16000);


%% autoregressive filter approach using Fs=2000Hz - less memory, less calculations, more stability concerns
%define filter by complex conjugate pole location
secondOrderSegment = ones(1,3);
poleR = 0.9;
poleW = pi/10;
secondOrderSegment(1,2) = -2*poleR*cos(poleW);
secondOrderSegment(1,3) = poleR^2;
%plot
subplot(2,1,1)
zplane(1,secondOrderSegment)
subplot(2,1,2)
[h,w] = freqz(1,secondOrderSegment,4096);
w = w *(2000/pi);
plot(w,abs(h),LineWidth=1.2)
title('\fontsize{19} Frequency Response of Generated Filter')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
sgtitle("\fontsize{23} Design of Colored Noise Filter Using Second Order Autoregressive Filter and 4kHz Sampling Frequency")
%% create test outputs
w = randn(100000,1);
w = w / max(w);
audiowrite("testSamples/4000kHzwhite.wav",w,4000);

x = filter(1,secondOrderSegment,w);
x = x / max(x);
audiowrite("testSamples/0.5r4000kHzcolored.wav",x,4000);


%% auto regressive first order
%define filter coefficients
firstOrderSegment = [1, -0.9];
%plot
subplot(2,1,1)
zplane(1,firstOrderSegment)
subplot(2,1,2)
[h,w] = freqz(1,firstOrderSegment,4096);
w = w *(1000/pi);
plot(w,abs(h),LineWidth=1.2)
title('\fontsize{19} Frequency Response of Generated Filter')
xlabel('\fontsize{16} Frequency(Hz)')
ylabel('\fontsize{16}Magnitude')
sgtitle("\fontsize{23} Design of Colored Noise Filter Using First Order Autoregressive Filter and 2kHz Sampling Frequency")


