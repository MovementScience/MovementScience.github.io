%% October 20, 2011
%% Import at MSN Run, and feed the data back as f, Em, Vm

function [f, Em, Vm] = Import_MSN_Run_EmVm_v1(DataDir, InFiber, Run)

%% Update the scs extension
FileName=[InFiber '.msn'];

FilePath=[DataDir filesep FileName];
%FilePath
%% Example of Header Data
% Saved Filename: 11a17S1R24.msn
% Saved Run Number: 02
% Date and Time of Day: Wed, Oct 19, 2011, 12:41:38 PM
% Time: 52317698s
% System Name: Sine Rig 2
% User Notes: 
% pCa: 8.00
% Temp: 17.0C, IonStr: 200.0mEq, [Pi]: 0.000mM
% [ATP]: 5.00mM, [PCr]: 35.000mM, [CK]: 300.0mM
% Other: 
% Model Species: Mouse
% Muscle Name: Papillary
% Muscle Prep: Skinned Strip
% Muscle Length: 270.0um
% Muscle Diam Major: 182.00um, Minor: 159.25um
% Muscle Cross Sectional Area: 2.276e-02mm^2
% Isometric Force:   0.08mN, Tension:   3.40mN/mm^2
% Perturbation: Multiple Sinusoid
% System Error Filename: SysErrRig2_2011.01.04.msn 
% Pre-Sinusoid Duration: 50 ms
% Amplitude: 0.125 %ML
% Frequency Set: Low_Set
% Number of Frequencies: 48
% Number of Cycles Skipped: 2 
% Number of Cycles Run: 4 
% Dip Freq = 0.125000 Hz
% Max Work = -0.049584  J/m^3 at Freq = 0.250000 Hz
% Max Power = -0.007128  W/m^3 at Freq = 0.125000 Hz
% A = 88.580482 kN/m^2, k = 0.106466 (unitless)
% B = 17.590206 kN/m^2, b = 1.930218 Hz
% C = 69.018242 kN/m^2, c = 656.969299 Hz
% Freq (Hz)	Elastic_Mod (kN/m^2)	Viscous_Mod (kN/m^2)

% First we need to find the correct run.
% Then, based on the Number of Frequencies, we will strip the data
% for the run and return the f, Em, and Vm

count=0;
A=[];
%FilePath
fid=fopen(FilePath);
while count==0
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    %disp(tline)
    if strncmp('Saved Run Number:',tline,17)
        %disp(tline)
        [r,c]=size(A);
        A(r+1,1)=str2num(tline(1,end-2:end));
        %disp(['Run' (tline(1,end-2:end))] )
     elseif strncmp('Number of Frequencies:',tline,22)
       A(r+1,2)=str2num(tline(1,end-2:end));
       %disp(['f' str2num(tline(1,end-2:end))])
    elseif strncmp('Freq (Hz)',tline,9) %% Now we know the next line will be at the Data we want
        
        if A(r+1, 1)==Run %% Grab Desired Run
            
            %% Notes for 'tab_index' just below
            %f=[]; %0 to 1  %Freq (Hz)
            %Em=[]; %1 to 2 %Elastic_Mod (kN/m^2)
            %Vm=[]; %2 to 3 %Viscous_Mod (kN/m^2)
            
            %% Try and make data so not allocating on the fly--just filling
            f=zeros(A(r+1, 2), 1);
            Em=zeros(A(r+1, 2), 1);
            Vm=zeros(A(r+1, 2), 1);
            
            %% Now keep track of our looping with the counter
            count=0;
            
            %% Now the next will be the data to read in
            tline=fgetl(fid);
            while ~isempty(tline) %% While not empty for end \n white space
                if ~ischar(tline), break, end %% break on the end of file character
                count = count+1;
                %% find all the spaces where the tab is indexed
                tab_index = find(isspace(tline));
               
                %% Populate the Data Variable
                 f(count,1)=str2double( tline(1, 1:tab_index(1,1))) ;  %% Write f
                 Em(count,1)=str2double( tline(1, tab_index(1,1):tab_index(1,2))) ;  %% Write Em
                 Vm(count,1)=str2double( tline(1, tab_index(1,2):end) ) ;  %% Write Vm
                
                tline=fgetl(fid);
            end
            
        end
    end
    
    
end

fclose(fid);

% A;

