%% BCWT Jan 19, 2014
%%%Edited Dec 16 2020 PA/KT
%% Graph sAP_22e force-pCa data for Engineered Heart Tissue
%% talk.  Summary Data Located at:
% J:\TannerBertGroup\RLC_Studies\Mechanics\Analyzed\Tension\pCa_Tension_Analysis_Summer2015\Tension_Analysis_SPSS_Summaries_2015_09_19.xlsx

clear
close all
clc


%% Import 45 data
data=importdata('J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Analyzed\Step\Scripts\kREL_ATP_Fit_Output\ATP_ADP_Release_Rates_231010.xlsx')
data_45=data.data;

%% Note this is the row for each set of data
ipCa_Range_AP_19=1:8; %% No TreatmeAP_19
ipCa_Range_AP_22=9:16; %% Damicamtiv
ipCa_Range_MLCK_19=17:23; %% Damicamtiv
ipCa_Range_MLCK_22=24:29; %% Damicamtiv


%% Set up our foAP_19s
LegendFontSize=10;
AxisFontSize=12;

jitter_x_std=0.05;
mean_shift=7;
mean_marker_size=10;
mean_line_point=2;


clf(figure(1))
subplot(2,2,1)
%% Plot k_ADP:
iCol=5; %% Column for value mean
plot([1 + jitter_x_std.*randn(size(ipCa_Range_AP_19))], data_45(ipCa_Range_AP_19, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([2 + jitter_x_std.*randn(size(ipCa_Range_MLCK_19))], data_45(ipCa_Range_MLCK_19, iCol), 'k^', 'markerfacecolor', 'k'), hold on
plot([3 + jitter_x_std.*randn(size(ipCa_Range_AP_22))], data_45(ipCa_Range_AP_22, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([4 + jitter_x_std.*randn(size(ipCa_Range_MLCK_22))], data_45(ipCa_Range_MLCK_22, iCol), 'k^', 'markerfacecolor', 'k'), hold on

errorbar([1 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_19, iCol)), std(data_45(ipCa_Range_AP_19, iCol))/sqrt(length(ipCa_Range_AP_19)), 'k.', 'MarkerSize', mean_marker_size)
errorbar([2 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_19, iCol)), std(data_45(ipCa_Range_MLCK_19, iCol))/sqrt(length(ipCa_Range_MLCK_19)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([3 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_22, iCol)), std(data_45(ipCa_Range_AP_22, iCol))/sqrt(length(ipCa_Range_AP_22)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([4 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_22, iCol)), std(data_45(ipCa_Range_MLCK_22, iCol))/sqrt(length(ipCa_Range_MLCK_22)), 'k.', 'MarkerSize', mean_marker_size), hold on

plot([1 - mean_shift*jitter_x_std/2, 1 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_19, iCol)), mean(data_45(ipCa_Range_AP_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([2 - mean_shift*jitter_x_std/2, 2 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_19, iCol)), mean(data_45(ipCa_Range_MLCK_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([3 - mean_shift*jitter_x_std/2, 3 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_22, iCol)), mean(data_45(ipCa_Range_AP_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([4 - mean_shift*jitter_x_std/2, 4 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_22, iCol)), mean(data_45(ipCa_Range_MLCK_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on

% title('Force-pCa 4 Parameter Hill Fits')
set(gca, 'xtick', [1,2,3,4])
set(gca,'xticklabel',{'AP 19', 'MLCK 19', 'AP 22', 'MLCK 22'});
ylabel('k_{-ADP} (s^{-1})', 'FontSize', AxisFontSize)
ylim([0, 25])
xlim([0.5, 4.5])
set(gca, 'FontSize', LegendFontSize)
set(gca, 'box', 'off')

% return


subplot(2,2,2)
%% Plot k_ATP values:
iCol=6; %% Column for value mean
plot([1 + jitter_x_std.*randn(size(ipCa_Range_AP_19))], data_45(ipCa_Range_AP_19, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([2 + jitter_x_std.*randn(size(ipCa_Range_MLCK_19))], data_45(ipCa_Range_MLCK_19, iCol), 'k^', 'markerfacecolor', 'k'), hold on
plot([3 + jitter_x_std.*randn(size(ipCa_Range_AP_22))], data_45(ipCa_Range_AP_22, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([4 + jitter_x_std.*randn(size(ipCa_Range_MLCK_22))], data_45(ipCa_Range_MLCK_22, iCol), 'k^', 'markerfacecolor', 'k'), hold on

errorbar([1 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_19, iCol)), std(data_45(ipCa_Range_AP_19, iCol))/sqrt(length(ipCa_Range_AP_19)), 'k.', 'MarkerSize', mean_marker_size)
errorbar([2 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_19, iCol)), std(data_45(ipCa_Range_MLCK_19, iCol))/sqrt(length(ipCa_Range_MLCK_19)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([3 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_22, iCol)), std(data_45(ipCa_Range_AP_22, iCol))/sqrt(length(ipCa_Range_AP_22)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([4 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_22, iCol)), std(data_45(ipCa_Range_MLCK_22, iCol))/sqrt(length(ipCa_Range_MLCK_22)), 'k.', 'MarkerSize', mean_marker_size), hold on

plot([1 - mean_shift*jitter_x_std/2, 1 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_19, iCol)), mean(data_45(ipCa_Range_AP_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([2 - mean_shift*jitter_x_std/2, 2 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_19, iCol)), mean(data_45(ipCa_Range_MLCK_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([3 - mean_shift*jitter_x_std/2, 3 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_22, iCol)), mean(data_45(ipCa_Range_AP_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([4 - mean_shift*jitter_x_std/2, 4 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_22, iCol)), mean(data_45(ipCa_Range_MLCK_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on

set(gca, 'xtick', [1,2,3,4])
set(gca,'xticklabel',{'AP 19', 'MLCK 19', 'AP 22', 'MLCK 22'});
ylabel('k_{+ATP} (mM^{-1} s^{-1})', 'FontSize', AxisFontSize)
ylim([0, 800])
xlim([0.5, 4.5])
set(gca, 'FontSize', LegendFontSize)
set(gca, 'box', 'off')

subplot(2,2,3)
%% Plot MgATP50 values:
iCol=7; %% Column for value mean
plot([1 + jitter_x_std.*randn(size(ipCa_Range_AP_19))], data_45(ipCa_Range_AP_19, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([2 + jitter_x_std.*randn(size(ipCa_Range_MLCK_19))], data_45(ipCa_Range_MLCK_19, iCol), 'k^', 'markerfacecolor', 'k'), hold on
plot([3 + jitter_x_std.*randn(size(ipCa_Range_AP_22))], data_45(ipCa_Range_AP_22, iCol), 'ks', 'markerfacecolor', 'w'), hold on
plot([4 + jitter_x_std.*randn(size(ipCa_Range_MLCK_22))], data_45(ipCa_Range_MLCK_22, iCol), 'k^', 'markerfacecolor', 'k'), hold on

errorbar([1 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_19, iCol)), std(data_45(ipCa_Range_AP_19, iCol))/sqrt(length(ipCa_Range_AP_19)), 'k.', 'MarkerSize', mean_marker_size)
errorbar([2 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_19, iCol)), std(data_45(ipCa_Range_MLCK_19, iCol))/sqrt(length(ipCa_Range_MLCK_19)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([3 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_AP_22, iCol)), std(data_45(ipCa_Range_AP_22, iCol))/sqrt(length(ipCa_Range_AP_22)), 'k.', 'MarkerSize', mean_marker_size), hold on
errorbar([4 - mean_shift*jitter_x_std], mean(data_45(ipCa_Range_MLCK_22, iCol)), std(data_45(ipCa_Range_MLCK_22, iCol))/sqrt(length(ipCa_Range_MLCK_22)), 'k.', 'MarkerSize', mean_marker_size), hold on

plot([1 - mean_shift*jitter_x_std/2, 1 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_19, iCol)), mean(data_45(ipCa_Range_AP_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([2 - mean_shift*jitter_x_std/2, 2 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_19, iCol)), mean(data_45(ipCa_Range_MLCK_19, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([3 - mean_shift*jitter_x_std/2, 3 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_AP_22, iCol)), mean(data_45(ipCa_Range_AP_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on
plot([4 - mean_shift*jitter_x_std/2, 4 + mean_shift*jitter_x_std/2], [mean(data_45(ipCa_Range_MLCK_22, iCol)), mean(data_45(ipCa_Range_MLCK_22, iCol))], 'k-', 'linewidth', mean_line_point), hold on

set(gca, 'xtick', [1,2,3,4])
set(gca,'xticklabel',{'AP 19', 'MLCK 19', 'AP 22', 'MLCK 22'});
ylabel('[MgATP]_{50}', 'FontSize', AxisFontSize)
ylim([0, 150])
xlim([0.5, 4.5])
set(gca, 'FontSize', LegendFontSize)
set(gca, 'box', 'off')


%% Scale figure size
%% Default screensize is pixels
set(0,'Units','inches');
scrsz_inches = get(0,'ScreenSize');
set(0,'Units','pixels');
scnsize_pix = get(0,'ScreenSize');
pix_per_inch=scnsize_pix(1,3)/scrsz_inches(1,3);
%% Set figure size--lower left cooridnates(a, b), then witdth then height
%set(gcf, 'Position',[2 2 7 3.5]) for example with 7 by 3.5 inches.  It
%happens that this also includes the bounding box
set(gcf, 'Position', [100, 100, pix_per_inch*5.5, pix_per_inch*5.5])
