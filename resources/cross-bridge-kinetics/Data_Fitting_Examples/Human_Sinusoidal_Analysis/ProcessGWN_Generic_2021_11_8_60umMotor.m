%% BCWT; December 15, 2010 (PA January 10, 2022)
%%%%%%%Adapted from Kyrah's updated correction file%%%%%ProcessGWN_Generic_2021_11_8_60umMotor.m
%% Building General Code for Testing and Analysis of GWN stimulus Files
%% generic rigs
%%

clear, close all, clc

%% Example Fiber information as shown below:
%% File Path (Directory), string:'C:\BertUVM\WhiteNoise\PPG_MyBP_C\JAP_Repeat_Tests'
%% File Name (without extension--it searches for scs), string:'GWN_10914R21'
%% Run to analize, number:16
%% Sampling Fequency (Hz), number:5000
%% Cutoff Frequency (Hz), number:200
%% Expected STD of Strain Amplitude (% ML), number: 0.1
%% Waiting Time Duration to start stimulus (s), number:2.5
%% Wing Duration of wrapped stimulus (s), nubmer: 1
%% Noise Stimulus Duration (s):20
%% File information example for 5 mM ATP, number:0 (here is 0)
%%                Path                                  File       Run  fs   fc  eAmp Wait   wings  Noise Run_INFO
%%     'M:\B_Tanner\GWN\GWN_Stim_Tests\Rig_5_Tests', 'GWN_10C1541', 1, 5000, 250, 0.1, 2.5,   1,     40,    0;

%% Create the file list as a set cells, then pass

VarNames = {'HashCode', 'Treatment', 'SL'}; %Var1, Var2, Var3

CurrentDir = pwd;

FileList={
    % %                                                                                                         %%FittingFunc, Var1, Var2, Var3, Series, pCa, Pi (mM), ATP (mM)

    %%%%%%%%%New Correction File
    %Export_MSNorGWNtoABC_XLD_Skeletal_Human_27C
    %%%%%%Script for Danicamtiv studies January 18, 2023.

    %%%%%%%%%Noise Analysis (GWN)

    %%%%%%%%Sinusoidal analysis (MSN)

    [CurrentDir filesep 'Cardiac_Data'], '24208R11', 1, 20e3, 250, 0.125, 0, 0, 0, 'Cardiac_Human_S2', '2B487', 'control', '1.9', 1, 8.0, 0.3, 8; %% Relaxed Fiber (8.0)--Sinusoid
    [CurrentDir filesep 'Cardiac_Data'], '24208R11', 2, 20e3, 250, 0.125, 0, 0, 0, 'Cardiac_Human_S2', '2B487', 'control', '1.9', 1, 4.0, 0.3, 8; %% Full Activation (4.0)--Sinusoid


    };

addpath('.\Code\') % To access functions

Process=2; %% Set at 2 for post processing of GWN Data and ABC fitting of Sinusoidal and GWN data


if Process==2



    %%This little chunk of code sorts out individual fibers and all of
    %%their run data. Here, it allows us to run Process 2 on multiple
    %%fibers at once.    -AJF 6-25-2015
    FileList_Full = FileList;
    Unique_Fiber_Names = unique(FileList_Full(:,2));
    for ifiber = 1:length(Unique_Fiber_Names)
        %Creates a temporary array of just the file information for just one unique fiber.
        Unique_Fiber_index = find((strcmp(FileList_Full(:,2),Unique_Fiber_Names(ifiber))) == 0);
        FileList = FileList_Full;
        FileList(Unique_Fiber_index, :) = [];


        [r,c]=size(FileList);
        count1=0; %% Set the counters to 0 for the headers in each Series type
        count2=0; %% for MSN vs GWN

        for i=1:r

            %% Correct Em Vm Data, Fit Data with ABC model, write files:
            %% This needs a few inputs Correction File and the N_Avg for the Downsample:
            %% also the figure handles to output the fits.
            %% Adjust the Em and Vm for the correction:

            Corr_File_Path = [CurrentDir filesep 'Code' filesep]
            Corr_File_Name='Rig1_SysError_2021_11_17_New.msn';


            if i==1
                clf(figure(111))
                Fig_1=gcf;
                clf(figure(222))
                Fig_2=gcf;
            end

            if count1==0 %% toggle on whether to write the header for the first file when we go through here
                count1=1;
                First=1;
            else
                First=0; %% First will toggle on whether to tag the header or PKPKAend the file
            end
            Quality=1; %% Default Quality on 1

            Export_Func = str2func(['Export_MSNorGWNtoABC_XLD_' FileList{i,10}]);  % FileList{i,10} should contain the str for the fitting function.
            Export_Func(Corr_File_Path, Corr_File_Name, Fig_1, Fig_2, First, FileList(i, :), Quality, VarNames);


        end

        %% Write the 2nd figure out to the storage directory
        %% This will hold the ABC data for the fiber
        Out_Fig=[FileList{i,1} filesep FileList{i,2} '_ABCParms.fig'];
        saveas(Fig_2, Out_Fig)
        Out_Fig2=[FileList{i,1} filesep FileList{i,2} '_ABCParms.png'];
        saveas(Fig_2, Out_Fig2)
        toc
    end

    %Plot an overlay of the moduli traces selected
    if size(FileList_Full,1) > 1
        Plot_Moduli_Overlay_2020(FileList_Full)
    end

end
