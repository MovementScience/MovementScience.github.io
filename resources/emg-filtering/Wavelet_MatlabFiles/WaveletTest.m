%A wavelet test program to verify that it works
clear variables;

%Change directories below to correspond to your folder that contains
%the 'WaveletData' folder. 
computerTypeString = computer;
if strcmp(computerTypeString(1:3), 'MAC')
waveletDirectory = '/Users/monicadaley/Documents/MonicaFiles/MonicaMatlab/MatlabHelpFnctns/WaveletTools/WaveletData/';
else
waveletDirectory = 'C:\MonicaFiles\MonicaMatlab\MatlabHelpFnctns\WaveletTools\WaveletData\';
end

%Prompt the user for some sample frequencies to test with a sine wave
promptE={'Low' 'Middle' 'High' };
defansE={'60' '180' '450'};
freqAns=inputdlg(promptE,'Input test frequencies',1,defansE);
testfreq(1)=str2num(freqAns{1,1});
testfreq(2)=str2num(freqAns{2,1});
testfreq(3)=str2num(freqAns{3,1});

%Create sine waves at each frequency and with the correct number of points
%for the single-chunk wavelet analysis
sampleHz=5000;
[waveletData] = GetWaveletData(sampleHz);

time=[1:1:waveletData.nWvltPoints]./sampleHz;
testSine=ones(waveletData.nWvltPoints,(length(testfreq)+1)).*NaN;

for i=1:length(testfreq)
    radInc=(testfreq(i)./sampleHz).*2*pi; %radians per sample
    testSine(:,i)=(sin([1:1:waveletData.nWvltPoints].*radInc))'; %create sine wave at appropriatefrequency
end
testSine(:,(length(testfreq)+1))=sum(testSine(:,1:length(testfreq)),2);

lstr{1}=[num2str(testfreq(1)) ' Hz Sine']; %Create text for legend
lstr{2}=[num2str(testfreq(2)) ' Hz  Sine'];
lstr{3}=[num2str(testfreq(3)) ' Hz  Sine'];
lstr{4}=['Summed'];

f1=figure;
subplot(4,1,1)
plot(time, testSine(:,1),'b')
xlim([0 .0166667]) %Xlim set so that 1 cycle of a 60 Hz signal should be displayed
legend(lstr{1})
subplot(4,1,2)
plot(time, testSine(:,2),'r')
xlim([0 .0166667])
legend(lstr{2})
subplot(4,1,3)
plot(time, testSine(:,3),'g')
xlim([0 .0166667])
legend(lstr{3})
subplot(4,1,4)
plot(time, testSine(:,4),'k')
xlim([0 .0166667])
legend(lstr{4})
xlabel('Time (s)')

cfLabels = waveletData.evensLabels;

%Run data through wavelet analysis
testPowers=ones(waveletData.nWvltPoints,waveletData.nWavelets,(length(testfreq)+1));
for i=1:(length(testfreq)+1);
    powersTemp = RunWaveletCalc(testSine(:,i),waveletData); %Wavelet decomposition
    testPowers(:,:,i)=powersTemp;
    figure;
    contourf(testPowers(:,1:waveletData.nWavelets,i)');
    colorbar('horiz');
    ticV=2:2:size(powersTemp,2);
    set(gca,'YTick',ticV)
    set(gca,'YTickLabel',cfLabels);
    title(['Wavelet results: ' lstr{i} ' wave']);
    ylabel('Frequency')
    xlabel('points')
end
