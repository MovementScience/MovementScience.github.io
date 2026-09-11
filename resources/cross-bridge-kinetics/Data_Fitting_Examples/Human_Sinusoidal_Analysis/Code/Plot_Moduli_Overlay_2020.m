
function Plot_Moduli_Overlay_2020(FileList)

    %% Can Comment out this section and use the one after for manual input %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    PathName = FileList(:,1);
    FiberName = FileList(:,2);
    RunNumber = {};
    for i = 1:length(FileList(:,3))
        RunNumber = [RunNumber;num2str(FileList{i,3})];
    end
    Label = {};
    for i = 1:length(FileList(:,1))
        Label = [Label;[FileList{i,2},'_',num2str(FileList{i,3})]];
    end
    
    
    LineColor = {};
    colors = ['b';'g';'r';'c';'m';'b';'g'];
    for i = 1:length(FileList(:,1))
        icolor = mod(i,length(colors)+1);
        LineColor = [LineColor;colors(icolor)];
    end
    
    DataIn = [PathName,FiberName,RunNumber,Label,LineColor];
    
    
    %% MOD HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     DataIn = {
%     %AnimalName, FiberName, Run#, Label, LineColor   
%     'J:\TannerBertGroup\Lab_Mechanics\Skeletal\Skeletal_Biopsies\Acquired\3L_Bundle1_200302','20302R110','2','Run1','b';
%     'J:\TannerBertGroup\Lab_Mechanics\Skeletal\Skeletal_Biopsies\Acquired\3L_Bundle1_200302','20302R112','2','Run2','r';
%     'J:\TannerBertGroup\Lab_Mechanics\Skeletal\Skeletal_Biopsies\Acquired\2L_Bundle1_200203','20203R15','7','Run3','g';
%     };

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i = 1:length(DataIn(:,1))
        %Open and create handles for each figure
        h(i) = open([DataIn{i,1},'\GWN_Processed\',DataIn{i,2},'_Corr_Run_',DataIn{i,3},'.fig']);
    end

    for i = 1:length(DataIn(:,1))
        %Because our graphs are 2x1 plots, we have to grab 2 sets of axis data
        axis_data = findobj(h(i), 'type', 'axes');
        ax(i,1) = axis_data(1); %
        ax(i,2) = axis_data(2);
    end

    for i = 1:length(DataIn(:,1))

        child{i} = get(ax(i,1), 'children');
        children = child{i};
        children(1).Color = DataIn{i,5};
        children(2).Color = DataIn{i,5};
        if i > 1 %I'm going to copy all to first figure (so don't need to copy first)
            copyobj(child{i}, ax(1,1)); 
        end
        child{i} = get(ax(i,2), 'children');
        children = child{i};
        children(1).Color = DataIn{i,5};
        children(2).Color = DataIn{i,5};
        if i > 1 %I'm going to copy all to first figure (so don't need to copy first)
            copyobj(child{i}, ax(1,2)); 
        end
    end


    %Now treat the first figure as the final figure with all elemtns. Refind these axis and children.
    Final_axis = findobj(h(1), 'type', 'axes');
    first_ax1 = Final_axis(2);
    child_Upper = get(first_ax1, 'children');
    first_ax2 = Final_axis(1);
    child_Lower = get(first_ax2, 'children');

    for i = 1:length(DataIn(:,1))
        legend_data{i,1} = DataIn{i,4};
    end

    figure(h(1))
    subplot(2,1,1)
    title('Fits for fibers'); %Underscore run#
    for i = 1:length(DataIn(:,1))
        set(get(get(child_Upper(i*2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');   
    end
    l1 = legend(legend_data{:,1},'location', 'northwest');
    set(l1, 'Interpreter', 'none')
    
    subplot(2,1,2)
    for i = 1:length(DataIn(:,1))
        set(get(get(child_Lower(i*2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');   
    end
    l2 = legend(legend_data{:,1},'location', 'northwest');
    set(l2, 'Interpreter', 'none')
    
    
    %Close all but that first figure
    for i = 2:length(h)
        delete(h(i))
    end
    
end
