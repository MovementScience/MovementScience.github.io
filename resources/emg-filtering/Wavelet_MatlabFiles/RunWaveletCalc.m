function [powers] = RunWaveletCalc(dataEMG,waveletData)
%  [powers] = RunWaveletCalc(dataEMG,waveletData)
% function to run wavelet analysis on section of EMG data
% Inputs:
% dataEMG:  array of EMG data (timepoints as rows, channels as columns)
%
% waveletData: information loaded by GetWaveletData function
%          (run GetWaveletData first)

intWavelet = waveletData.wavelets;
gaussmatrix = waveletData.gaussmatrix;
centerFreq = waveletData.centerFreq;
co = waveletData.co;
timestep = waveletData.timestep;
nWvltPoints = waveletData.nWvltPoints;
nWavelets = waveletData.nWavelets;

%%%%%%%%%%%% Basic Wavelet EMG function %%%%%%%%%%%%%%
fftEMG = fft(dataEMG);     % fft of chunk of nWvltPoints of raw EMG data (now in frequency domain)
powers=ones(nWvltPoints,nWavelets).*NaN;

for i= 1:nWavelets;            % loop through for all wavelets
    intwaveletcolumn = intWavelet(i,:)';        %#ok<COLND> % define the row of wavelets to be used in equation and transpose
    % so wavelet is in 1 column
    convolutedata = 2* (real(ifft(fftEMG .* intwaveletcolumn)));       % take real component of fft, perform ifft and run it through
    nom = (1000 ./ (2 * pi * centerFreq .* co));    % mystical value needed according to Vincent
    convolute1 = convolutedata(3:nWvltPoints);     % drop first 2 numbers in matrix
    convolute2 = convolutedata(1:(nWvltPoints-2));     % drop last 2 numbers in matrix
    % this is used to in the next step to determine the slope of a line between
    % two data points (ie., slope between pt 1 and pt 3 - since we shift each convolute
    % matrix by 2 values they overlap) and the intensity of the signal can
    % be determined
    intensityintime = ((convolutedata(2:(nWvltPoints-1)).^2)) + ((nom(i)*(convolute2 - convolute1)/(2*timestep)).^2);
    % determines intensity of signal in time domain
    intensityresize = [0 intensityintime' 0];      % adds a 0 to the front and back of the intensity matrix so it
    % is now back to original size
    fftintensity = (fft(intensityresize) .* gaussmatrix(i,:));  %#ok<COLND> % perform fft and run data through the gauss matrix
    % one row at a time (back in frequency domain)
    intensity = real(ifft(fftintensity));                       % perform ifft on real value of fft (back into time domain)
    powers(:,i) = intensity';                              % build matrix of powers (intensity) for each wavelet
end
