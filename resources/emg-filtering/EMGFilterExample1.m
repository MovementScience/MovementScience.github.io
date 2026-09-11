
%Example 1:  Guinea fowl EMG data collected using analog wired EMG system 
% sampling at 5000Hz,  
% for two muscles, lateral gastrocnemius & digital flexor 3

%load data
%fileDir = '';
%cd(fileDir);
clear variables; close all; clc;

load('Trimmed_YG_40cm_Trial005_DAQ.mat');

%% Set sampling rate
Fs = 5000;

% Pull out the two EMG channels of interest
EMGdata(:,1) = data.EMG1;
EMGdata(:,2) = data.EMG2;
time = (0:(size(EMGdata,1)-1))./Fs';

[n_samples, n_channels] = size(EMGdata);

%For high-pass filter only;
stopBandFreq = 30;
passBandFreq = 40;

%Normalize the specified frequencies to the Nyquist frequency Fs/2
Ws=stopBandFreq./(Fs/2);
Wp=passBandFreq./(Fs/2);
Rs = 40;  % Stopband attenuation (dB)
Rp = 1;   % Passband ripple (dB)

[filtOrder_HP,Wn_HP]=buttord(Wp,Ws,Rp,Rs);
%If only one frequency is included for Ws and Wp, then you need to specify
%the filter type as 'high' or 'low' pass.  
[b,a]=butter((round(filtOrder_HP/2)),Wn_HP,'high'); %

filtData_HP(:,:)=filtfilt(b,a,EMGdata); %filter forward and back for Nth order, zero phase lag result.
%Calculate cutoff frequency in Hz from the normalized frequency
filtCutOffFreq_HP=Wn_HP.*(Fs/2);

figure
plot(time,EMGdata(:,1),'k');
hold on;
plot(time,filtData_HP(:,1),'b');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'raw','high pass'})



%% Band-pass filter:

stopBandFreq = [30, 1200];   % Stopband: below 30 Hz and above 1200 Hz
passBandFreq = [90, 800];  % Passband: 90-800 Hz
Ws=stopBandFreq./(Fs/2);
Wp=passBandFreq./(Fs/2);

Rs = 40;  % Stopband attenuation (dB)
Rp = 1;   % Passband ripple (dB)

[filtOrder_BP,Wn_BP]=buttord(Wp,Ws,Rp,Rs);

%If only one frequency is included for Ws and Wp, then you need to specify
%the filter type as 'high' or 'low' pass.  
[b_bp,a_bp]=butter((round(filtOrder_BP/2)),Wn_BP); %

filtData_BP(:,:)=filtfilt(b_bp,a_bp,EMGdata); %filter forward and back for Nth order, zero phase lag result.
%Calculate cutoff frequency in Hz from the normalized frequency
filtCutOffFreq_BP=Wn_BP.*(Fs/2);

figure
plot(time,EMGdata(:,1),'k');
hold on;
plot(time,filtData_BP(:,1),'g');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'raw','band pass'})

%% Calculate linear envelope

%Rectify signal, 
%Fourth-order low-pass Butterworth filter at 10 Hz to create a smoothed linear envelope. 

rectEMG = abs(filtData_HP);

Wn_env = 10./(Fs/2);
[b_le,a_le]=butter(2,Wn_env,'low'); %

linEnv(:,:)=filtfilt(b_le,a_le,rectEMG);

%% Plot the results as a function of time in tiled subplots
ffH = figure;
ax1 = subplot(3,2,1);
plot(time,EMGdata(:,1),'k');
hold on;
plot(time,filtData_HP(:,1),'b');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'raw','high pass'})

ax2 = subplot(3,2,2);
plot(time,EMGdata(:,2),'k');
hold on;
plot(time,filtData_HP(:,2),'b');
xlabel('time (s)');
ylabel('EMG ch. 2(Volts)')
legend({'raw','high pass'})

ax3 = subplot(3,2,3);
plot(time,EMGdata(:,1),'k');
hold on;
plot(time,filtData_BP(:,1),'b');
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'raw','band pass'})

ax4 = subplot(3,2,4);
plot(time,EMGdata(:,2),'k');
hold on;
plot(time,filtData_BP(:,2),'b');
xlabel('time (s)');
ylabel('EMG ch. 2 (Volts)')
legend({'raw','band pass'})

ax5 = subplot(3,2,5);
plot(time,rectEMG(:,1),'k');
hold on;
plot(time,linEnv(:,1),'m','LineWidth', 1.5);
xlabel('time (s)');
ylabel('EMG ch. 1 (Volts)')
legend({'rectified','linear env'})

ax6 = subplot(3,2,6);
plot(time,rectEMG(:,2),'k');
hold on;
plot(time,linEnv(:,2),'m','LineWidth', 1.5);
xlabel('time (s)');
ylabel('EMG ch. 2 (Volts)')
legend({'rectified','linear env'})

linkaxes([ax1 ax2 ax3 ax4 ax5 ax6], 'x');


%% Look at data in the frequency domain

    % Create frequency vector for FFT
    f = (0:n_samples-1) * Fs / n_samples;
    f_half = f(1:floor(n_samples/2)+1); % Single-sided spectrum
    
    % Compute FFT of original data (just channel 1 for example)    for i = 1: n_channels
        raw_fft = fft(EMGdata(:,1));
        raw_magnitude = abs(raw_fft(1:length(f_half),1));
       
    % Get filter frequency response for band pass filter
    [H, f_filter] = freqz(b_bp, a_bp, 1024, Fs);
    filter_magnitude = abs(H);

        % Add overall title
    sgtitle(sprintf('Butterworth Bandpass Filter (Order: %d, Cutoffs: %.1f-%.1f Hz)', ...
            filtOrder_BP, filtCutOffFreq_BP(1), filtCutOffFreq_BP(2)));
    
    % Plot 2: Frequency domain analysis
    figure('Name', 'EMG Data: Frequency Domain Analysis', 'Position', [100, 100, 1000, 800]);
    
    % Top subplot: Original data spectrum
    ax_freq1 = subplot(2, 1, 1);
    hold on;
    %Plot raw magnitude in dB against frequency
    semilogx(f_half, 20*log10(raw_magnitude), 'b-', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('Frequency Spectrum of Original EMG Data');
    grid on;
    
    % Add vertical lines for filter specifications
    hold on;
    yl = ylim;
    plot([stopBandFreq(1), stopBandFreq(1)], yl, 'r--', 'LineWidth', 1, 'DisplayName', 'Stop Low');
    plot([passBandFreq(1), passBandFreq(1)], yl, 'g--', 'LineWidth', 1, 'DisplayName', 'Pass Low');
    plot([passBandFreq(2), passBandFreq(2)], yl, 'g--', 'LineWidth', 1, 'DisplayName', 'Pass High');
    plot([stopBandFreq(2), stopBandFreq(2)], yl, 'r--', 'LineWidth', 1, 'DisplayName', 'Stop High');
    legend('EMG Spectrum', 'Stopband', 'Passband Low', 'Passband High', 'Stopband', 'Location', 'best');
    
    % Bottom subplot: Filter frequency response
    ax_freq2 = subplot(2, 1, 2);
    semilogx(f_filter, 20*log10(filter_magnitude), 'k-', 'LineWidth', 1.5);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title(sprintf('Butterworth Bandpass Filter Response (Order: %d)', filtOrder_BP));
    grid on;
    xlim([1, Fs/2]);
    
    % Add vertical lines for filter specifications
    hold on;
    yl = ylim;
    plot([stopBandFreq(1), stopBandFreq(1)], yl, 'r--', 'LineWidth', 1);
    plot([passBandFreq(1), passBandFreq(1)], yl, 'g--', 'LineWidth', 1);
    plot([passBandFreq(2), passBandFreq(2)], yl, 'g--', 'LineWidth', 1);
    plot([stopBandFreq(2), stopBandFreq(2)], yl, 'r--', 'LineWidth', 1);
    
    % Add horizontal lines for specification levels
    plot(xlim, [-Rp, -Rp], 'g:', 'LineWidth', 1, 'DisplayName', 'Passband Ripple');
    plot(xlim, [-Rs, -Rs], 'r:', 'LineWidth', 1, 'DisplayName', 'Stopband Atten.');
    
    
    % Link x-axes of frequency domain plots
    linkaxes([ax_freq1, ax_freq2], 'x');