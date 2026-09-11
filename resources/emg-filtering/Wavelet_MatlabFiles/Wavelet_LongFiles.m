function [powersByWavelet,totalPower,subRangePowers] = Wavelet_LongFiles(dataEMG,waveletData,subRanges,plotmode, plotDivInc)
% [powersByWavelet,totalPower,subRangePowers] =
%       Wavelet_LongFiles(dataEMG,waveletData,subRanges,plotmode, plotDivInc)
% Does wavelet analysis on a matrix of EMG data
% Inputs:
% dataEMG:  array of EMG data (timepoints as rows, channels as columns)
%
% waveletData: information loaded by GetWaveletData function
%          (run GetWaveletData first)
%
% subRanges is a cell array of vectors specifying subRanges of wavelets to
%       sum over.  For example, 3 vectors could be used to specify a low, middle
%       and high frequency range. There should be at least a 1 wavelet gap between
%       subRanges.
%       If no subRanges are specified, enter the empty matrix for subRanges
%
% plotmode=1, a graph will be produced for every EMG "chunk"
% plotmode=0, no graphs are produced
%       Default plotmode=1
%
% plotDivInc:  is  increment for the contour plot divisions
%       This should be adjusted according to the magnitude of the EMG signal
%
% This function uses WaveletEMG.m, see help for more detail.
%   Breaks the data into chunks for wavelet analysis, then recompiles into a
%    single wave.  The edges of the chunks are overlapped and cut to remove
%    edge artifact.  However, some edge artifact remains in the first 20-40ms
%    of the file
%
% See also:
% GetWaveletData, WaveletEMG, RunWaveletCalc,WaveletTest
%            Monica Daley

if ~exist('plotmode','var')
    plotmode=1;
end;

if ~exist('plotDivInc','var')
    plotDivInc=0.1;
end;

% Break data into chunks and run through wavelet analysis, then recompile
%   into a single wave
ch_npts = waveletData.nWvltPoints;
sampleFreq_Hz = waveletData.sampleFreq_Hz;
rows = size(dataEMG, 1);
chunk_i1 = 1;
chunk_i2 = ch_npts;
 if rows < ch_npts
     chunk_i2 = rows;
 end

Nsegs = 1;

% Calculate frequency distribution over time for each column of data
%   cut off the first and last 40ms of each segment to remove edge artifact
% (only cuts the last 40ms of the first segment), edge artifact remains at
% the beginning of the file

deleteSeg = round(0.04*sampleFreq_Hz);
while chunk_i1 <= rows;

    chunkEMG = zeros(ch_npts,1);
    chunkEMG(1:(chunk_i2-chunk_i1+1),:) = dataEMG(chunk_i1:chunk_i2,:);
    [t_powers,t_TotalPower,t_subPower] = WaveletEMG(chunkEMG,waveletData,subRanges);
    % [powersByWavelet,totalPower,subRangePowers] = WaveletEMG(dataEMG,waveletData,subRanges)
    if chunk_i1 == 1
        startEMGpowers = t_powers(1:deleteSeg,:,1);
        startTotalPower = t_TotalPower(1:deleteSeg,1);
        EMGpowers(:,:,Nsegs) = t_powers(deleteSeg:(ch_npts-deleteSeg),:,1);
        TotalPower(:,Nsegs) = t_TotalPower(deleteSeg:(ch_npts-deleteSeg),1);

        if isempty(t_subPower) == 0
            subPowers(:,:,Nsegs) = t_subPower(deleteSeg:(ch_npts-deleteSeg),:,1);
            startSubPowers = t_subPower(1:deleteSeg,:,1);
        end;
        chunk_i1 = chunk_i1+ch_npts-(2*deleteSeg)-1;
    else
        EMGpowers(:,:,Nsegs) = t_powers(deleteSeg:(ch_npts-deleteSeg),:,1);
        TotalPower(:,Nsegs) = t_TotalPower(deleteSeg:(ch_npts-deleteSeg),1);

        if isempty(t_subPower) == 0
            subPowers(:,:,Nsegs) = t_subPower(deleteSeg:(ch_npts-deleteSeg),:,1);
        end;
        chunk_i1 = chunk_i1+ch_npts-(2*deleteSeg)-1;
    end

    chunk_i2 = chunk_i1+(ch_npts-1);
    if chunk_i2 > rows;
        chunk_i2 = rows;
    end
    Nsegs = Nsegs+1;
end
% Put time chunks back together into one file
powersByWavelet = startEMGpowers;
totalPower = startTotalPower;
if exist('subPowers', 'var' )
    subRangePowers = startSubPowers;
end;

Nsegs = size(TotalPower,2);
for i=1:Nsegs
    powersByWavelet = [powersByWavelet ; EMGpowers(:,:,i)];
    totalPower = [totalPower ; TotalPower(:,i)];
    if exist('subPowers', 'var' )
        subRangePowers = [subRangePowers ; subPowers(:,:,i)];
    end;
end

if size(totalPower,1) > rows
    powersByWavelet((rows+1):end,:,:) = [];
    totalPower((rows+1):end,:) = [];
    if exist('subPowers', 'var' )
        subRangePowers((rows+1):end,:,:) = [];
    end
end;

cfLabels = waveletData.evensLabels;

if plotmode == 1
    time = [0:(1/sampleFreq_Hz):(size(dataEMG,1)-1)/sampleFreq_Hz];

    fh = figure;
    hold on;
    subplot(3,1,1);
    plot(time,totalPower);
    if exist('subPowers', 'var' )
        hold all;
        plot(time,subRangePowers);
        for i = 1:size(subRangePowers,2)
            legStr{i} = ['Wavelets: ' num2str(subRanges{i})];
        end
        legend('Total Power', legStr{:});
    else
        legend ('Total Power')
    end
    ylabel('Total power (mV^2)')
    xlabel('Time (s)');
    titlestring='Frequency spectrum of EMG Signal';
    xlim([0 time(end)]);
    xl=xlim;
    yl=ylim;
    text((xl(1)+200),(yl(2)+(yl(2)*.25)),titlestring);
    subplot(3,1,[2 3])
    minInt=min(min(powersByWavelet(:,2:end)));
    maxInt=max(max(powersByWavelet(:,2:end)));
    IntDivisions=round((maxInt-minInt)./plotDivInc);
    if IntDivisions<=5
        IntDivisions=10;
    end;
    contourf(powersByWavelet(:,2:end)',IntDivisions)
    hold on;
    xlim([0 size(dataEMG,1)]);
    ticV=2:2:size(powersByWavelet(:,2:end),2);
    set(gca,'YTick',ticV)
    set(gca, 'XTick', [])
    set(gca,'YTickLabel',cfLabels)
    ylabel('Frequency')
    colorbar('horiz');
end

