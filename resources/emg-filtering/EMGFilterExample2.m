%% Example from human surface EMG electrodes:
close all; clc; clear variables;

load('Subject_01_hopping_20%weight_02_EMG_raw.mat')

time = EMGTable.Time; 
Fs = mean(1./(diff(time)));

%Pull two example channels out of the data table
EMGdata(:,1) = EMGTable.("LeftSOL.IM EMG1");
EMGdata(:,2) = EMGTable.("LeftLG.IM EMG2");

%% This system has built in band-pass filtering in hardware
% filter to remove potential motion artifact and DC offset

filtOrd = 2;
Wn_HP = 25./(Fs/2);

[b,a]=butter(filtOrd,Wn_HP,'high'); %
filtData_HP(:,:)=filtfilt(b,a,EMGdata); %filter forward and back for Nth order, zero phase lag result.

%% Calculate linear envelope

%Rectify signal, 
%Fourth-order low-pass Butterworth filter at 10 Hz to create a smoothed linear envelope. 

rectEMG = abs(filtData_HP);
Wn_env = 10./(Fs/2);
[b_le,a_le]=butter(2,Wn_env,'low'); %

linEnv(:,:)=filter(b_le,a_le,rectEMG);


%% Run wavelet analysis:
% see Wakeling and Syme 2002 & other Wakeling paper for details on Wavelet analysis
%Slow MUAPs:  ~180Hz,  Fast MUAPs ~ 370Hz
%    waveletData.centerFreq = [6.902 19.287 37.711 62.089 92.359 128.471 170.386 218.068 271.487 330.619 395.438]';
nCh = size(EMGdata,2);
nRows = size(EMGdata,1);
[waveletParams] = GetWaveletData(Fs);
subRanges = {[3:7] [8:11]}; %Specify range for 'slow' and 'fast'

nWavelets = waveletParams.nWavelets;
waveletCenterFreqs = waveletParams.scaledCenterFreq;

EMGpowers = ones(nRows,nWavelets,nCh).*NaN;
EMGTotPower = ones(nRows,nCh).*NaN;

%For each EMG channel,  use the wavelets to calculate a smoothed amplitude
%envelope for the physiological frequency range of muscle. 
%This acts as a band-pass filter tuned for the specific frequency
%characteristics of muscle action potentials. 
for i = 1:nCh
    [EMGpowers(:,:,i),~,subRangePowers(:,:,i)] = Wavelet_LongFiles(EMGdata(:,i),waveletParams,subRanges,0);
    % The lower frequency range are  associated with electrical noise,  so omit
% them and sum over the range from 90-400Hz only for total intensity
% calculation
    totalPowers(:,i) = sum(EMGpowers(:,3:end,i),2);
end

%% To transform back to intensities in units of millivolts (not v^2)
%take the squareroot of the power values
totalInt = (totalPowers.^0.5);
subTotInt = (subRangePowers.^0.5);

%% Plot the results as a function of time in tiled subplots
ffH = figure;
ax1 = subplot(2,2,1);
plot(time,EMGdata(:,1),'k');
hold on;
plot(time,filtData_HP(:,1),'b');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'raw','high pass'})

ax2 = subplot(2,2,2);
plot(time,EMGdata(:,2),'k');
hold on;
plot(time,filtData_HP(:,2),'b');
xlabel('time (s)');
ylabel('EMG ch. 2(Volts)')
legend({'raw','high pass'})

ax3 = subplot(2,2,3);
plot(time,rectEMG(:,1),'k');
hold on;
plot(time,linEnv(:,1),'m');
hold on;
plot(time,subTotInt(:,1,1),'g');
plot(time,subTotInt(:,2,1),'r');
plot(time,totalInt(:,1),'c');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'rectified','linear env','slow','fast','Int_tot'})

ax4 = subplot(2,2,4);
plot(time,rectEMG(:,2),'k');
hold on;
plot(time,linEnv(:,2),'m');
plot(time,subTotInt(:,1,2),'g');
plot(time,subTotInt(:,2,2),'r');
plot(time,totalInt(:,2),'c');
xlabel('time (s)');
ylabel('EMG ch. 2 (Volts)')
legend({'rectified','linear env','slow','fast','Int_tot'})

linkaxes([ax1 ax2 ax3 ax4], 'x');
