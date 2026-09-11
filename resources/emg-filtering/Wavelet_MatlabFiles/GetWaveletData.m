function [waveletData] = GetWaveletData(sampleFreq_Hz)
%  [waveletData] = GetWaveletData(sampleFreq_Hz)
% function to load the most relevant set of wavelets and scale the wavelet
% center frequencies appropriately.
% Inputs: sampleFreq_Hz; recording sample frequency in Hz
%            waveletDirectory: directory containing wavelet files

mpath = strrep(which(mfilename),[mfilename '.m'],'');
waveletDirectory = [mpath filesep 'WaveletData' filesep];

waveletData.waveletDirectory = waveletDirectory; 
waveletData.sampleFreq_Hz = sampleFreq_Hz; 

% Choose a set of wavelets
waveletCases = [1024 2400 5000];
freqDifferences  = abs(waveletCases - sampleFreq_Hz);
[val, index] = min(freqDifferences); %#ok<ASGLU>
waveletChoice  = waveletCases(index);

waveletData.wSampleFreq_Hz = waveletChoice;
% Assign wavelet data variables based on the set of wavelets chosen:
if waveletChoice == 2400
    waveletData.nWvltPoints = 4096;
    waveletData.nWavelets = 11;  % number of wavelets
    waveletData.waveletFileName = ['wavelets2400.txt'];	                % creates filename to open waveletFileName.txt intensity wavelet file
    waveletData.gaussFileName = ['gauss2400.txt'];	                    % creates filename to open gaussFileName.txt file
    waveletData.co = [1 1 1 1 0.99 0.98 0.97 0.95 0.92 0.88 0.83]';
    waveletData.centerFreq = [6.902 19.287 37.711 62.089 92.359 128.471 170.386 218.068 271.487 330.619 395.438]';

elseif waveletChoice == 1024
    waveletData.nWvltPoints = 8192;
    waveletData.nWavelets = 10;
    waveletData.waveletFileName = ['wavelet1024.txt'];	                % creates filename to open intwave1024.txt intensity wavelet file
    waveletData.gaussFileName = ['gauss1024.txt'];	                    % creates filename to open gauss1024.txt file
    waveletData.co = [1,1,0.994,0.978,0.95,0.902,0.829,0.729,0.599,0.443]';
    waveletData.centerFreq = [6.9023,19.2865,37.7108,62.0891,92.3590,128.4713,170.3855,218.0675,271.4873,330.6188]';

elseif waveletChoice == 5000
    waveletData.nWvltPoints  = 8192;
    waveletData.nWavelets = 16;        % number of wavelets
    waveletData.waveletFileName = ['wavelets5000.txt'];	                % creates filename to open intwave1024.txt intensity wavelet file
    waveletData.gaussFileName = ['gauss5000.txt'];	                    % creates filename to open gauss1024.txt file
    waveletData.co =[1 1 1 1 1 1 0.995 0.99 0.985 0.975 0.96 0.945 0.925 0.905 0.875 0.84]';
    waveletData.centerFreq =  [6.902 19.287 37.711 62.089 92.359 128.471 170.386 218.068 271.487 330.619 395.438 465.924 542.058 623.821 711.197 804.17]';
end

% Calculate wavelet additional wavelet variables:
waveletData.timestep = 1000/waveletData.wSampleFreq_Hz;
% Calculate correction factor and scale the center frequencies.
% correctionFactor = waveletFreq/ActualSampleFreq
% newCenterFrequencies = cf*correctionFactor
correctionFactor = waveletData.wSampleFreq_Hz./sampleFreq_Hz;
waveletData.scaledCenterFreq = waveletData.centerFreq./correctionFactor;

t_labels = mat2cell(waveletData.scaledCenterFreq(:), ones(length(waveletData.scaledCenterFreq(:)),1),1);
for i = 1:length(t_labels)
labels{i} = num2str(t_labels{i});
end
waveletData.cfLabels = labels;

evens = [2:2:length(waveletData.cfLabels)];
evensLabels = cell(1,length(evens));
[evensLabels{:}] = deal(waveletData.cfLabels{evens});
waveletData.evensLabels = evensLabels;

%%%%%%%%%%%%  Load Wavelet data from files %%%%%%%%%%%%%%
fid=fopen([waveletDirectory waveletData.waveletFileName],'r');		                    % open the file to read
wavelets=fscanf(fid, '%f', [waveletData.nWvltPoints,waveletData.nWavelets]);        % [columns, rows]
waveletData.wavelets=wavelets';
msg = fclose(fid);
fid=fopen([waveletDirectory waveletData.gaussFileName],'r');		                    % open the file to read
gaussdata=fscanf(fid, '%f', [waveletData.nWvltPoints,waveletData.nWavelets]);             % [columns, rows]
waveletData.gaussmatrix=gaussdata';                             % transpose matrix -
msg = fclose(fid);
%%%%%%
