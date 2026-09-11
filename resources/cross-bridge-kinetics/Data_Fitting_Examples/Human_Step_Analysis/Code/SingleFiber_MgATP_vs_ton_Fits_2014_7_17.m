%% BCWT
%% May 15, 2014
%% Use this code to fit force-pCa data and get the parameters back.
%%
%% User Required Inputs: Fiber Name, pCa value, MgATP values,
%%                       ton Data (ms) at each MgATP value
%%
%% Outcomes: ton will be converted to detachment rate and 
%%           the detachment rate vs. MgATP kinetics will be fit
%%           to output the MgADP release and MgATP binding rates
%%           for the data of a particular fiber.
%%
%% Set our values for xdata = [MgATP] and fit detachment rate (2*pi*c):
%% 2*pi*c=kADP_release*MgATP/((kADP_release/kATP_binding) + MgATP)
%%
%%           The figure will also be saved in "CurrentDir\MgATPFigFits\"
%%           using a generic fiber name as "pCaFits_XXXXXXXX.Fig"
%%           were XXXXXX is the single fiber name, entered by the user.
%%

%% Clear data variables
clear

%% User Enter Fiber Name, with Fiber Name surrounded by ' '
% Example: FiberName='14307R11';
%
Fiber_Name='26115R118';

%% User Enter pCa Data, for the pCa value that the MgATP titration
%% occured at:
pCa_Data=4.8;

%% User Enter MgATP Data array for the [MgATP], as an array surrounded by [ ]
MgATP_Values=[
5
2.5
1
0.5
0.25
0.1
0.05
0.025
0.01
% 0.005
% 0.0025
0.001
    ];

%% User Enter ton values (in ms), as an array surrounded by [ ]
ton_Values=[
6.3165
7.2574
8.8791
9.2567
11.5451
13.13
17.6777
23.5035
604.1505
% 2722.9263
% 559.7295
2096.8723
];


%%%%%%%%%
%%%%%%%%%  Do NOT edit below here
%%%%%%%%%  Do NOT edit below here
%%%%%%%%%
% ---------------------------------------------------------------
% ---------------------------------------------------------------
% ---------------------------------------------------------------
close all
clc
%% Addpath for directory that stores the data fitting funciton
addpath('J:\TannerBertGroup\Bert\DataFittingCode\MgATP_ton_Fits')

%% Fit the data
Current_Directory=pwd;
MgATP_ton_fits_2014_7_17(Current_Directory, Fiber_Name, pCa_Data, MgATP_Values, ton_Values)

