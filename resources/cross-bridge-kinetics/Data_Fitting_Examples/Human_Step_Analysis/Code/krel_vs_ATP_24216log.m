 %% BCWT Jan 19, 2014 %%%% Modified POA August 23, 2022
%% Graph some Passive Tension data in for prep Porcine cardiac OM Piperine studies
%% Summary Data Located at:
%J:\TannerBertGroup\Lab_Mechanics\Porcine\Analyzed\Tension

clear
close all
clc

%% Import 4.5 data
data=importdata('J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Analyzed\Step\krel_kdev_Mean_2023_8_17.xlsx')
data_45=data.data;

%% Note this is the row for each set of data

%%%%%AP_19 (pCa 4.8)
iRow_AP_19=2:9;

%%%%%ani (pCa 4.8)
iRow_MLCK_19=12:19;

%%%%%AP_19 (pCa 4.8)
iRow_AP_22=22:29;

%%%%%ani (pCa 4.8)
iRow_MLCK_22=32:39;

%% Set up our fonts
LegendFontSize=10;
AxisFontSize=12;

jitter_x_std=0.05;
mean_shift=7;
mean_marker_size=10;
mean_line_point=2;


clf(figure(1))

subplot(2,2,1)
%% Plot krel values:

xCol=4; %ATP concentration
iCol=9; %% Column for value mean
iColSE=10; %SEM

%% Plot AP 19 data
errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_AP_19, iCol), data_45(iRow_AP_19, iColSE),'ks'), hold on
%% Fit to a line
% Input to BT_kRELvsATP_Fit fitting funciton to the ADP and ATP rate Eqn.
% is ATP = x, Krel = y, and Figure number to plot fit
[best_p, rateATP_Fit, exit_flag] = BT_kRELvsATP_Fit(data_45(iRow_AP_19, xCol), data_45(iRow_AP_19, iCol), 'figure_number', 13);
% To plot, need to get back to active plot window for Fig. 1...
figure(1)
% subplot(3,1,1)
x_in=[min(data_45(iRow_AP_19, xCol)):0.01:max(data_45(iRow_AP_19, xCol))];
fit_to_plot = best_p(1)*x_in./((best_p(1)/best_p(2)) + x_in);
semilogx(x_in, fit_to_plot, 'k-')
% semilogx(x_in, 'k-')


%% Plot MLCK_19 data
errorbar(data_45(iRow_MLCK_19, xCol), data_45(iRow_MLCK_19, iCol), data_45(iRow_MLCK_19, iColSE),'k^', 'MarkerFaceColor', 'k'), hold on
%% Fit to a line
% Input to BT_kRELvsATP_Fit fitting funciton to the ADP and ATP rate Eqn.
% is ATP = x, Krel = y, and Figure number to plot fit
[best_p_MLCK_19, rateATP_Fit_MLCK_19, exit_flag_MLCK_19] = BT_kRELvsATP_Fit(data_45(iRow_MLCK_19, xCol), data_45(iRow_MLCK_19, iCol), 'figure_number', 14);
% To plot, need to get back to active plot window for Fig. 1...
% Subplot (2,2,1)
figure(1)
% subplot(3,1,1)
x_in_MLCK_19=[min(data_45(iRow_MLCK_19, xCol)):0.01:max(data_45(iRow_MLCK_19, xCol))];
fit_to_plot_MLCK_19 = best_p_MLCK_19(1)*x_in_MLCK_19./((best_p_MLCK_19(1)/best_p_MLCK_19(2)) + x_in_MLCK_19);
semilogx(x_in_MLCK_19, fit_to_plot_MLCK_19, 'k--')
% semilogx(x_in_MLCK_19, 'k--')

%% Plot AP 22 data
errorbar(data_45(iRow_AP_22, xCol), data_45(iRow_AP_22, iCol), data_45(iRow_AP_22, iColSE),'ks'), hold on
%% Fit to a line
% Input to BT_kRELvsATP_Fit fitting funciton to the ADP and ATP rate Eqn.
% is ATP = x, Krel = y, and Figure number to plot fit
[best_p, rateATP_Fit, exit_flag] = BT_kRELvsATP_Fit(data_45(iRow_AP_22, xCol), data_45(iRow_AP_22, iCol), 'figure_number', 13);
% To plot, need to get back to active plot window for Fig. 1...
% Subplot (2,2,1)
figure(1)
% subplot(3,1,1)
x_in=[min(data_45(iRow_AP_22, xCol)):0.01:max(data_45(iRow_AP_22, xCol))];
fit_to_plot = best_p(1)*x_in./((best_p(1)/best_p(2)) + x_in);
semilogx(x_in, fit_to_plot, 'k-')
% semilogx(x_in, 'k-')

%% Plot MLCK_22 data
errorbar(data_45(iRow_MLCK_22, xCol), data_45(iRow_MLCK_22, iCol), data_45(iRow_MLCK_22, iColSE),'k^', 'MarkerFaceColor', 'k'), hold on
%% Fit to a line
% Input to BT_kRELvsATP_Fit fitting funciton to the ADP and ATP rate Eqn.
% is ATP = x, Krel = y, and Figure number to plot fit
[best_p_MLCK_22, rateATP_Fit_MLCK_22, exit_flag_MLCK_22] = BT_kRELvsATP_Fit(data_45(iRow_MLCK_22, xCol), data_45(iRow_MLCK_22, iCol), 'figure_number', 14);
% To plot, need to get back to active plot window for Fig. 1...
% Subplot (2,2,1)
figure(1)
% subplot(3,1,1)
x_in_MLCK_22=[min(data_45(iRow_MLCK_22, xCol)):0.01:max(data_45(iRow_MLCK_22, xCol))];
fit_to_plot_MLCK_22 = best_p_MLCK_22(1)*x_in_MLCK_22./((best_p_MLCK_22(1)/best_p_MLCK_22(2)) + x_in_MLCK_22);
semilogx(x_in_MLCK_22, fit_to_plot_MLCK_22, 'k--')
% semilogx(x_in_MLCK_22, 'k--')

xlabel('ATP (mM)')
ylabel('k_{rel} (s^{-1})', 'FontSize', AxisFontSize)
legend('AP 19', '', 'MLCK 19', '', 'AP 22', '', 'MLCK 22', 'location', 'Southeast')
legend('boxoff')
ylim([0, 15])
xlim([0.001, 10])
set(gca, 'FontSize', LegendFontSize)
set(gca, 'box', 'off')
set(gca, 'xscale', 'log')
% 
% subplot(2,2,2)
% %% Plot krel values:
% 
% xCol=4; %ATP concentration
% iCol=11; %% Column for value mean
% iColSE=12 %SEM
% 
% %% Plot No Treatment data
% errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_AP_19, iCol), data_45(iRow_AP_19, iColSE),'ko'), hold on
% % Plot Fit Line
% plot(x_in, fit_to_plot, 'k-')
%  
% %% Plot MLCK_19 data
% errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_MLCK_19, iCol), data_45(iRow_MLCK_19, iColSE),'ko', 'MarkerFaceColor', 'k'), hold on
% % Plot Fit Line
% plot(x_in_MLCK_19, fit_to_plot_MLCK_19, 'k--')
% 
% xlabel('ATP (mM)')
% ylabel(['k_{rel} (s^{-1})'], 'FontSize', AxisFontSize)
% legend('AP 19', '', 'MLCK 19', 'location', 'Northwest')
% legend('boxoff')
% 
% set(gca, 'xscale', 'log')
% set(gca, 'xtick', [0.001, 0.01, 0.1, 1, 5])
% set(gca,'xticklabel',{'0.001', '0.01', '0.1', '1', '5'})
% 
% ylim([0, 25])
% xlim([0, 6])
% set(gca, 'FontSize', LegendFontSize)
% set(gca, 'box', 'off')
% 
% 
% subplot(2,2,3)
% %% Plot kdev values:
% 
% xCol=1; %ATP concentration
% iCol=8; %% Column for value mean
% iColSE=9 %SEM
% 
% %% Plot No Treatment data
% errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_AP_19, iCol), data_45(iRow_AP_19, iColSE),'ks'), hold on
% 
% %% Plot MLCK_19 data
% errorbar(data_45(iRow_MLCK_19, xCol), data_45(iRow_MLCK_19, iCol), data_45(iRow_MLCK_19, iColSE),'ks', 'MarkerFaceColor', 'k'), hold on
% 
% xlabel('ATP (mM)')
% ylabel({'k_d_e_v (s^-^1)'}, 'FontSize', AxisFontSize)
% legend('AP 19', 'MLCK 19', 'location', 'West')
% legend('boxoff')
% ylim([0, 25])
% xlim([0, 5])
% set(gca, 'FontSize', LegendFontSize)
% set(gca, 'box', 'off')
% 
% 
% subplot(2,2,4)
% %% Plot kdev values:
% 
% xCol=1; %ATP concentration
% iCol=8; %% Column for value mean
% iColSE=9 %SEM
% 
% %% Plot No Treatment data
% errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_AP_19, iCol), data_45(iRow_AP_19, iColSE),'ks'), hold on
%  
% %% Plot MLCK_19 data
% errorbar(data_45(iRow_AP_19, xCol), data_45(iRow_MLCK_19, iCol), data_45(iRow_MLCK_19, iColSE),'ks', 'MarkerFaceColor', 'k'), hold on
% 
% xlabel('ATP (\muM)')
% ylabel({'k_d_e_v (s^-^1)'}, 'FontSize', AxisFontSize)
% legend('AP 19', 'MLCK 19', 'location', 'West')
% legend('boxoff')
% 
% set(gca, 'xscale', 'log')
% set(gca, 'xtick', [0.001, 0.01, 0.1, 1, 5])
% set(gca,'xticklabel',{'0.001', '0.01', '0.1', '1', '5'})
% 
% ylim([0, 25])
% xlim([0, 6])
% set(gca, 'FontSize', LegendFontSize)
% set(gca, 'box', 'off')


%% Scale figure size
%% Defaul screensize is pixels
set(0,'Units','inches');
scrsz_inches = get(0,'ScreenSize');
set(0,'Units','pixels');
scnsize_pix = get(0,'ScreenSize');
pix_per_inch=scnsize_pix(1,3)/scrsz_inches(1,3);
%% Set figure size--lower left cooridnates(a, b), then witdth then height
%set(gcf, 'Position',[2 2 7 3.5]) for example with 7 by 3.5 inches.  It
%happens that this also includes the bounding box
set(gcf, 'Position', [100, 100, pix_per_inch*6, pix_per_inch*6])

return

%% Save file to:
% J:\TannerBertGroup\Lab_Mechanics\Porcine\Analyzed\Tension\Scripts_Plots_Stats\Plots

FilePath='J:\TannerBertGroup\Lab_Mechanics\Porcine\OM_Piperine\Analyzed\Tension\Scripts_Plots_Stats\Plots';
FileName=['Tension_Piperine_' date];

saveas(gcf, [FilePath filesep FileName], 'fig');
saveas(gcf, [FilePath filesep FileName], 'eps');
saveas(gcf, [FilePath filesep FileName], 'pdf');
saveas(gcf, [FilePath filesep FileName], 'png');
saveas(gcf, [FilePath filesep FileName], 'svg');