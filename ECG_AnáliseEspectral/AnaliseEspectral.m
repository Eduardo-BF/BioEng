%% Filtragem ECG
% Eduardo Barcelos Freitas      ;
% M. F. S. Ventura  ;

clear; close all; clc;
%%
load normal.txt
t = normal(:,1);
sinal = normal(:,2);
Fs = 250;

%% Sinal Limpo
ecglimpo = sinal(1000:3000);
tlimpo= t(1000:3000);
figure(1)
plot(tlimpo,ecglimpo)
xlim([4 12])
title('Gráfico Sinal Limpo')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')

%% Sinal Ruido
ecgruido = sinal(61000:63000);
truido= t(61000:63000);
figure(2)
plot(truido,ecgruido)
title('Gráfico Sinal Ruído')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')

%% FFT sinal

[Xlimpo,Freqlimpo] = positiveFFT (ecglimpo,Fs);
[Xruido,Freqruido] = positiveFFT (ecgruido,Fs);
XlimpoS = smoothdata(Xlimpo);
XruidoS = smoothdata(Xruido);
figure(3)
%plot(Freqlimpo,20*log10(Xlimpo/max(abs(Xlimpo)))); hold on;
plot(Freqlimpo,20*log10(abs(XlimpoS)/max(abs(XlimpoS)))); hold on;
%plot(Freqruido,20*log10(Xruido/max(abs(Xruido)))); hold on;
plot(Freqruido,20*log10(abs(XruidoS)/max(abs(XruidoS)))); hold on;
title('Gráfico FFT')
legend('Sinal Limpo','Sinal Ruido')
xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
hold off;

%% Densidade Espectral de Potência
[pxlimpo,pwlimpo] = pwelch(ecglimpo);
figure(4)
plot(Fs*pwlimpo/(2*pi),20*log10(abs(pxlimpo)/max(abs(pxlimpo)))); hold on;
[pxruido,pwruido] = pwelch(ecgruido);
plot(Fs*pwruido/(2*pi),20*log10(abs(pxruido)/max(abs(pxruido)))); hold on;
title('Gráfico Densidade Espectral Potência')
legend('Sinal Limpo','Sinal Ruido')
xlabel('Frequência (Hz)')
ylabel('PSD (dB/Hz)')
hold off; 
%% Filtro FIR
% KAISER
FIR_bdpass = designfilt('bandpassfir','StopbandFrequency1',1, ...
                        'PassbandFrequency1',3,'PassbandFrequency2',30, ...
                        'StopbandFrequency2',40,'StopbandAttenuation1',1, ...
                        'PassbandRipple',0.4,'StopbandAttenuation2',30, ...
                        'SampleRate',250,'DesignMethod','kaiserwin');
ecgfiltro_FIR = filter(FIR_bdpass,sinal);
[XFIR_l,FreqFIR_l] = positiveFFT (ecgfiltro_FIR(1000:3000),Fs);
[XFIR_r,FreqFIR_r] = positiveFFT (ecgfiltro_FIR(61000:63000),Fs);

figure(5)
subplot(2,1,1)
plot(Freqlimpo,20*log10(abs(Xlimpo)/max(max(abs([Xlimpo XFIR_l]))))); hold on;
plot(FreqFIR_l,20*log10(abs(XFIR_l)/max(max(abs([XFIR_l Xlimpo])))));
title('Espectro Sinal Limpo - FIR')
xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
legend('Original', 'Filtrado')

subplot(2,1,2)
plot(Freqruido,20*log10(abs(Xruido)/max(max(abs([XFIR_r Xruido]))))); hold on;
plot(FreqFIR_r,20*log10(abs(XFIR_r)/max(max(abs([XFIR_r Xruido]))))); 
title('Espectro Sinal Ruído - FIR')
xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
legend('Original', 'Filtrado')


figure(6)
subplot(2,2,1)
plot(tlimpo,ecglimpo)
title('Sinal Limpo')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,2)
plot(truido,ecgruido)
title('Sinal Ruído')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,3)
plot(tlimpo,ecgfiltro_FIR(1000:3000))
title('FIR Limpo')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,4)
plot(truido,ecgfiltro_FIR(61000:63000))
title('FIR Ruído')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')

%% Filtro IIR
% BUTTERWORTH
IIR_bdpass = designfilt('bandpassiir','StopbandFrequency1',0.5, ...
                        'PassbandFrequency1',3,'PassbandFrequency2',20, ...
                        'StopbandFrequency2',70,'StopbandAttenuation1',10, ...
                        'PassbandRipple',0.2,'StopbandAttenuation2',10, ...
                        'SampleRate',250);
ecgfiltro_IIR = filter(IIR_bdpass,sinal);
[XIIR_l,FreqIIR_l] = positiveFFT (ecgfiltro_IIR(1000:3000),Fs);
[XIIR_r,FreqIIR_r] = positiveFFT (ecgfiltro_IIR(61000:63000),Fs);

figure(7)
subplot(2,1,1)
plot(Freqlimpo,20*log10(abs(Xlimpo)/max(max(abs([Xlimpo XIIR_l]))))); hold on;
plot(FreqIIR_l,20*log10(abs(XIIR_l)/max(max(abs([XIIR_l Xlimpo])))));
title('Espectro Sinal Limpo - IIR')
xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
legend('Original', 'Filtrado')

subplot(2,1,2)
plot(Freqruido,20*log10(abs(Xruido)/max(max(abs([XIIR_r Xruido]))))); hold on;
plot(FreqIIR_r,20*log10(abs(XIIR_r)/max(max(abs([XIIR_r Xruido]))))); 
title('Espectro Sinal Ruído - IIR')
xlabel('Frequência (Hz)')
ylabel('Magnitude (dB)')
legend('Original', 'Filtrado')



figure(8)
subplot(2,2,1)
plot(tlimpo,ecglimpo)
title('Sinal Limpo')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,2)
plot(truido,ecgruido)
title('Sinal Ruído')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,3)
plot(tlimpo,ecgfiltro_IIR(1000:3000))
title('IIR Limpo')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')
subplot(2,2,4)
plot(truido,ecgfiltro_IIR(61000:63000))
title('IIR Ruído')
xlabel('Tempo (s)')
ylabel('Amplitude (V)')

%% Funções 

% Função positiveFFT
function [X,freq]=positiveFFT(x,Fs)
N=length(x); %get the number of points
k=0:N-1; %create a vector from 0 to N-1
T=N/Fs; %get the frequency interval
freq=k/T; %create the frequency range
X=fft(x)/N; % normalize the data
%only want the first half of the FFT, since it is redundant
cutOff = ceil(N/2);
%take only the first half of the spectrum
X = X(1:cutOff);
freq = freq(1:cutOff);
end
