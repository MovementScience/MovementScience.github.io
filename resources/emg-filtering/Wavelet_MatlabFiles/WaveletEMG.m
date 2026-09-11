function [powersByWavelet,totalPower,subRangePowers] = WaveletEMG(dataEMG,waveletData,subRanges)
% [powersByWavelet,totalPower,subRangePowers] = WaveletEMG(dataEMG,waveletData,subRanges)
% Wavelet analysis of EMGs in Matlab
 % dataEMG:  array of EMG data (timepoints as rows, channels as columns)
 %
 % waveletData: information loaded by GetWaveletData function 
 %          (run GetWaveletData first)
 % This file analyses only a 'chunk' of EMG data as long as
 %      waveletData.nWvltPoints
% For longer files, use Wavelet_longFiles.m
% 
% subRanges is a cell array of vectors specifying subRanges of wavelets to
%   sum over.  For example, 3 vectors could be used to specify a low, middle
%   and high frequency range
% If no subRanges are specified, enter the empty matrix for subRanges
%
% See also:
% Wavelet_LongFiles, RunWaveletCalc, GetWaveletData

warning off MATLAB:mir_warning_variable_used_as_function

ch_npts = waveletData.nWvltPoints;
F_n = size(dataEMG,1);
nwvlts = waveletData.nWavelets;

chunkEMG = zeros(ch_npts,1);
chunkEMG(1:F_n,1) = dataEMG(1:F_n,1);

powersByWavelet = RunWaveletCalc(chunkEMG,waveletData);

if F_n  < ch_npts
    powersByWavelet((F_n+1):end,:) = [];
end

totalPower = sum(powersByWavelet(1:F_n,2:nwvlts),2);

if  ~ isempty(subRanges)
    nR = length(subRanges);
    subRangePowers = ones(F_n,nR).*NaN;
    for i = 1:nR
        rV = subRanges{i};
        subRangePowers(:,i) = sum(powersByWavelet(1:F_n,rV),2);
    end
else
    subRangePowers = [];
end