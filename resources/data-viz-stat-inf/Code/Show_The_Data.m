% Read the data from the CSV file containing Anscombe's quartet
Data = readmatrix('anscombe_quartet.csv');

% Create a bar plot with error bars for the y-values in each data set
figure
subplot(1,2,1)
e = errorbar(1:4,mean(Data(:,[2 4 6 8])), std(Data(:,[2 4 6 8])));
hold on
b = bar(mean(Data(:,[2 4 6 8])));

set(b,'FaceColor','w','EdgeColor','k','LineWidth',0.75)
set(e,'Color','k','LineWidth',0.75,'LineStyle','none')
xlim([0 5])
ylim([0 12])
ylabel('Variable Name (units)')
set(gca,'LineWidth',0.75,'XTick',1:4, 'XTickLabel',{'Grp 1' 'Grp 2' 'Grp 3' 'Grp 4'})
box off

% Create a dot plot with medians
subplot(1,2,2)
s = scatter(1:4,Data(:,[2 4 6 8]),'k');
hold on
l = line([0.7 1.7 2.7 3.7; 1.3 2.3 3.3 4.3],[median(Data(:,[2 4 6 8])); median(Data(:,[2 4 6 8]))]);

set(s,'LineWidth',0.5,'MarkerFaceColor',[0.5 0.5 0.5])
set(l,'Color','k','LineWidth',1)
xlim([0 5])
ylim([0 12])
set(gca,'LineWidth',0.75,'YTick','','XTick',[1 2 3 4],'XTickLabel',{'Grp 1' 'Grp 2' 'Grp 3' 'Grp 4'})

% Set figure dimensions for publication (10 cm for single column, 13 cm for
% 1.5 columns, or 19 cm for two columns)
width = 13;
set(gcf,'Units','centimeters')
position = get(gcf,'Position');
set(gcf,'Position',[position(1:2) width 5])
saveas(gcf,'Show_the_Data','fig')
saveas(gcf,'Show_the_Data','pdf')