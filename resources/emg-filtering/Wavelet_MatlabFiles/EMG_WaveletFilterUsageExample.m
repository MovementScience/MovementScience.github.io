function [EMGresults] = GetEMGSummaryMeasures(pathName,fileName1)
% EMG wavelet function use:

%Load example file into Matlab
pathName = 'G:\.shortcut-targets-by-id\1cPltUeSj4r9nan3xCYVmllFFRA0oTPFZ\IMS-SRI Projects\Group 3 Project 10 Human hopping\MatlabCode\EMG_Wavelet_MatlabFiles';
fileName1 = 'Subject_01_haptic_hoppng_EMG_raw.mat';
fileName2 = [fileName1(1:25) 'Force_filt_Events.csv'];
    
if ~exist([pathName fileName2],'file')==2
[resultVals,varNames] = GetFrequencyAdaptation_Hop(pathName,fileName);
end

% fileName1 = 'Subject_16_hoppng_no_weight_EMG_raw.mat';
% fileName2 = 'Subject_16_hoppng_no_weight_Force_filt_Events.csv';
%% Get categorical variables for trial
%Pull out subject, task and condition informaiton from filename
subjectNum = fileName1(9:10);
taskName = fileName1(12:13);
condName = fileName1(19:20);
if strcmp(taskName,'ha')==0
% if 'no' determine if it's first trial or post added mass
if strcmp(condName,'no')==1
    if strcmp(fileName(end-20:end-15),'weight')==1
        condName = 'no';
    else
        condName = 'no post';
    end
elseif strcmp(condName,'10')==1
    condName = 'ten';
elseif strcmp(condName,'20')==1
    condName = 'twenty';
else
    disp('WARNING: file name is wrong!')
end
end   
%%
load([pathName fileName1],'EMGTable');
eventTable = readtable([pathName fileName2]);
takeOffIndex = eventTable.takeOffIndex;
landingIndex = eventTable.landingIndex;
nHops = length(takeOffIndex)-1;

time = EMGTable.Time;
EMGdata = table2array(EMGTable(:,2:end));
chNames = EMGTable.Properties.VariableNames(2:end);
EMGlabels = {'L Sol' 'L LG' 'L MG' 'L TA' 'R Sol' 'R LG' 'R MG' 'R TA'};

%% 
nCh = size(EMGdata,2);
nRows = size(EMGdata,1);
sampleFreq = 1./double(mean(diff(time))); 
% waveletData.centerFreq = [6.902 19.287 37.711 62.089 92.359 128.471 170.386 218.068 271.487 330.619 395.438]';
[waveletParams] = GetWaveletData(sampleFreq);
% see Wakeling and Syme 2002 & other Wakeling paper for details on Wavelet analysis
%Slow MUAPs:  ~180Hz,  Fast MUAPs ~ 370Hz
subRanges = {[5:7] [8:11]};

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
    totalPowers(:,i) = sum(EMGpowers(:,4:end,i),2);
end

%% To transform back to intensities in units of millivolts (not v^2)
%take the squareroot of the power values
totalInt = (totalPowers.^0.5).*1000;
subTotInt = (subRangePowers.^0.5).*1000;

%% Plot wavelet transformed EMG data
%Select arbitrary time range in the middle of the file
t1 = 102000;
t2 = 112000;
plotOrder = [1 5 2 6 3 7 4 8];
%chNames

%Find take-off events that fall within specified time range
takeOff_t1t2 = intersect(takeOffIndex,[t1:t2]);
landing_t1t2 = intersect(landingIndex,[t1:t2]);

 f1 = figure; 
 for c = 1:nCh
 subplot((nCh/2),2,c)
 eIdx =plotOrder(c); 
 plot(time(t1:t2),totalInt(t1:t2,eIdx),'k');
 hold on;
 %Plot takeoff and landing times
  plot(time(t1:t2),subTotInt(t1:t2,1,eIdx),'b:');
  plot(time(t1:t2),subTotInt(t1:t2,2,eIdx),'m:');
   plot(time(takeOff_t1t2),totalInt(takeOff_t1t2,eIdx),'r^');
  plot(time(landing_t1t2),totalInt(landing_t1t2,eIdx),'rv');

 title([EMGlabels(eIdx)])
  if c == 1
  legend('tot', 'slow (~70-200Hz)','fast (~200-400Hz)','takeOff','landing');
  end
  if c == 7 || c == 8 
      xlabel('Time (s)')
  end
  if c == 1 || c == 3 ||c == 5 || c == 7 
        ylabel('Intensity (mV)')
  end
 end
 
%% Save figure to pdf and close
fontProperties = {'FontName','Arial','FontSize',14};
set(gca,'Box', 'off',fontProperties{:})
set(f1,'InvertHardcopy','off');
figure(f1)
print([pathName filesep fileName1(1:(end-8)) '_EMGSummary'],'-dpdf','-bestfit','-painters');
figure(f1)

dh = msgbox('Close figure to continue');

waitfor(f1);

%% Select standing region to calculate baseline activity for
% an activity threshold for each EMG channel. 
t1 = 1;
t2 = 40000;
tf = figure;
plot(t1:t2,totalInt(t1:t2,[1 5]));
ylabel('Intensity (mV)')
legend ('l Sol', 'r Sol');
xlabel('timepoints');
title('Click on start(1) and end(2) of baseline standing period');
[x,y] = ginput(2);

activityThreshold = mean(totalInt(round(x(1):x(2)),:)) + 4.*std(totalInt(round(x(1):x(2)),:));
threshDetectData = totalInt - activityThreshold; 

%Find all 'active' timepoints,  divide by the number of hops
%Divide mean active time per hop by the average hop duration to get duty
%factor
%Calculate weighted mean activation frequency,  
% and percent of activity in the 'low frequency' band

for c =1:nCh
%[onsetIndex{c},offsetIndex{c}] = FindZeroCrossings(time,threshDetectData(:,c),1); %#ok<SAGROW>
isActive = threshDetectData(takeOffIndex(1):takeOffIndex(end),c) > 0;

activeDuration(c) = (sum(isActive)./sampleFreq)./nHops;
totalDuration(c) = (time(takeOffIndex(end))-time(takeOffIndex(1)))./nHops;
dutyFactor(c) = activeDuration(c)./totalDuration(c);
[meanFreq(c)] = getMeanEMGFrequency(EMGpowers(:,:,c),waveletCenterFreq);
fractionLowFreq(c) = sum(subTotInt(:,1,c))./sum(totalInt(:,c));
end


   varTypes = {'string', 'string','string', 'string','double','double','double','double','double'};   
   varNames = {'Subject', 'Task', 'Cond', 'EMGch', 'activeDuration', 'totalDuration','dutyFactor','meanFreq','fractionLowFreq'};
 resultTable = table ('Size',[nCh,length(varNames)],'VariableTypes',varTypes, 'VariableNames',varNames);


%% Alternative filtering approach
% 1) High pass filter with cut-off ~70-90Hz to remove motion artifact and
% electrical noise
%2) Rectify
%3) Low pass filter to smooth, or calculate a moving average with a time-window of approximately 20ms or so 

% cutOffFreq = 70; % in Hz
% %Determine sample frequency from time vector
% S_Hz = 1/(data.time(2)-data.time(1));
% %Calculate normalized cutt-off frequency
% nyquist= S_Hz/2;
% Wn = cutOffFreq/nyquist;
% 
% %Design a 2nd order high pass filter
% [b,a] = butter(2,Wn,'high'); 
% %Filter data in forward and backward direction using 'filtfilt' to avoid phase shifts
% filtEMG = filtfilt(b,a,EMGdata);

end

function [meanFreq] = getMeanEMGFrequency(EMGPowers,waveletCenterFreqs)

waveletSums = sum(EMGPowers(:,5:end),1);

 t_sum = sum(waveletSums,2);  
 t_norm = nan(size(waveletSums));

  for w = 1:size(waveletSums,2)
      t_norm(:,w) = waveletSums(:,w)./t_sum;
  end
  meanFreq = (waveletCenterFreqs(5:end)'*t_norm')';

end
