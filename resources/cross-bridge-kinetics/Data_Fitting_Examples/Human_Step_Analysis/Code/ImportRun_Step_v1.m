%% Jan 18, 2010
%% BCWT--Hack on the combination of reading in the Single Custom Wave File:
%% "ImportRun_CustomWave_v3.m"
%% function [t, Strain, Stress] = ImportRun_Step_v1(DataDir, InFiber, Run, in_fs, in_Step_Dur, in_WaitDur)
%% We read in the proper run, and return the t, Strain, Stress

function [t, Strain, Stress] = ImportRun_Step_v1(DataDir, InFiber, Run, in_fs, in_Step_Dur, in_WaitDur)

%% Update the scs extension
FileName=[InFiber '.stp'];

FilePath=[DataDir filesep FileName];

%% No Longer Use Data--Just Gather t, Strain, Stress
%Data=zeros(in_fs*(NoiseDur+2*(WaitDur+WingDur)), 6);
t=zeros(floor(in_fs*(in_Step_Dur+in_WaitDur)), 1);
Strain=zeros(floor(in_fs*(in_Step_Dur+in_WaitDur)), 1);
Force=zeros(floor(in_fs*(in_Step_Dur+in_WaitDur)), 1);

% Saved Filename: 11104R22.stp
% Saved Run Number: 01
% Date and Time of Day: Tue, Jan 11, 2011, 12:09:35 PM
% Time: 30715775s
% System Name: Sine Rig 2
% User Notes: t/t-1
% pCa: 8.00
% Temp: 17.0C, IonStr: 200.0mEq, [Pi]: 0.000mM
% [ATP]: 5.00mM, [PCr]: 35.000mM, [CK]: 300.0mM
% Other:
% Model Species: Mouse
% Muscle Name: Papillary
% Muscle Prep: Skinned Strip
% Muscle Length: 261.0um
% Muscle Diam Major: 170.00um, Minor: 170.00um
% Muscle Cross Sectional Area: 2.270e-02mm^2
% Isometric Force:   0.10mN, Tension:   4.33mN/mm^2
% Perturbation: Step
% Pre-Step Duration: 50 ms
% Amplitude: 1 % ML
% Step Duration: 500 ms
% Return Duration: 2000 ms
% Time (s)	Muscle Length (um)	Force (mN)	Force (mN)	Strain	Stress (mN/mm^2)

%18, 7'' 35, 7

count=0;
A=[];

fid=fopen(FilePath);
while count==0
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    %disp(tline)
    if strncmp('Saved Run Number:',tline,17)
        %disp(tline)
        [r,c]=size(A);
        tline = strtrim(tline);  % Having some problems with trailing zeros
        A(r+1,1)=str2num(tline(1,end-2:end));
    elseif strncmp('Muscle Diam Major:',tline,18)
        %% Now we need to grab the next 7 characters for the major
        %% diameter in microns.
        %% AF Changed code 8/8/2019 to account for larger digit diameters (ie, 1000um)
        um = strfind(tline,'um');
        A(r+1,2)=str2num(tline(1,strfind(tline,'Major')+7:um(1)-1)); %% Major diameter   
        A(r+1,3)=str2num(tline(1,strfind(tline,'Minor')+7:um(2)-1)); %% Minor diameter 
        %A(r+1,2)=str2num(tline(1,19:25)); %% Major diameter
        %A(r+1,3)=str2num(tline(1,36:42)); %% Minor diameter
    elseif strncmp('Time (s)',tline,8)
        
        if A(r+1, 1)==Run %% Grab the Run we want.
            
            %% From above, what our specific variabls should be:
            %% Time (s)--Col 1
            %% DRIVEN INDICATES THE FORMED PERTURBATION, changes from 0
            %% Driven Len0 (um) -- Dac 0 better for bigger throws on Rig
            %% Driven Len1 (um) -- Dac 1 better for little oscilations on Rig 2
            %% WE USED DAC 1 FOR THE STUDY BELOW
            %% Muscle Length (um) -- Actual ML -- Col 4
            %% Force Rel (mN) -- Force relative to F listed above -- Col 5
            %% Force Abs (mN) -- Actual Force -- Col 6
            %% Strain -- Strain dL/L0 -- Col 7
            %% Stress Rel (mN/mm^2) -- T/To; where To is listed above-- Col 8
            
            %% Modification of Header for the written single custom wave
            %% file:
            %Time (s)	Muscle Length (um)	Force (mN)	Force (mN)	Strain	Stress (mN/mm^2)
            %% Notes for 'tab_index' just below
            %t=[]; %0 to 1  %Time (s)
            %ML=[]; %1 to 2 %Muscle Length (um)
            %F_Rel=[]; %2 to 3 %Force Rel (mN)
            %F_Abs=[]; %3 to 4 %Force Abs (mN)
            %Strain=[]; %4 to 5 %Strain
            %Stress=[]; %5 to 6 %Stress Rel (mN/mm^2)
            %in_fs, in_fc, eAmp, WaitDur, WingDur, NoiseDur
            
            %% Try and make data so not allocating on the fly--just filling
            % Data=zeros(in_fs*(NoiseDur+2*(WaitDur+WingDur)), 6);
            count=0;
            
            %% Now the next will be the data to read in
            tline=fgetl(fid);
            while ~isempty(tline) %% While not empty for end \n white space
                if ~ischar(tline), break, end %% break on the end of file character
                count = count+1;
                %% find all the spaces where the tab is indexed
                tab_index = find(isspace(tline));
                % t(count,1)=str2double( tline(1, 1:tab_index(1,1))) ;  %% Write Time
                % ML(count,1)=str2double( tline(1, tab_index(1,1):tab_index(1,2))) ;  %% Write ML
                % F_Rel(count,1)=str2double( tline(1, tab_index(1,2):tab_index(1,3))) ;  %% Write Force Rel
                % F_Abs(count,1)=str2double( tline(1, tab_index(1,3):tab_index(1,4)) ) ;  %% Write Force Abs
                % Strain(count,1)=str2double( tline(1, tab_index(1,4):tab_index(1,5)) ) ;  %% Write Strain
                % Stress(count,1)=str2double( tline(1, tab_index(1,5):end) ) ;  %% Write Stress
                
                %% Populate the Data Variable
                t(count,1)=str2double( tline(1, 1:tab_index(1,1))) ;  %% Write Time
                Force(count,1)=str2double( tline(1, tab_index(1,2):tab_index(1,3))) ;  %% Write Force Rel
                Strain(count,1)=str2double( tline(1, tab_index(1,4):tab_index(1,5)) ) ;  %% Write Strain
                             
                if Force(1,1) ~= 4.5300e-005
                   test = 1; 
                end
                
                tline=fgetl(fid);
            end
            
            %% Now turn Force into Stress mN/mm2
            Stress=Force/(pi*(A(r+1, 2)/2)*(A(r+1, 3)/2)*1.e-006); %% (1mm/1000um)^2 to get into mm2
            
        end
    end
    
    
end

fclose(fid);

%A;

