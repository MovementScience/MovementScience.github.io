%% BCWT; December 15, 2010
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
%%                Path                                  File       Run  fs   fc  eAmp Wait   wings  Noise Run_INFO  ATP  SL
%%     'M:\B_Tanner\GWN\GWN_Stim_Tests\Rig_5_Tests', 'GWN_10C1541', 1, 5000, 250, 0.1, 2.5,   1,     40,    0; %% In Air; Nothing


%% Create the file list as a set cells, then pass
FileList={

 
% % Pig 2018
% % 'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 22, 20000, 0.5, 0.05, 4.8, 0.3, 5.0 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 23, 20000, 0.5, 0.05, 4.8, 0.3, 2.5 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 24, 20000, 0.5, 0.05, 4.8, 0.3, 1.0 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 25, 20000, 0.5, 0.05, 4.8, 0.3, 0.5 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 26, 20000, 0.5, 0.05, 4.8, 0.3, 0.25 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 27, 20000, 0.5, 0.05, 4.8, 0.3, 0.1 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 28, 20000, 0.5, 0.05, 4.8, 0.3, 0.05 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 29, 20000, 0.5, 0.05, 4.8, 0.3, 0.025 , 2.2; %% AP 2.2 SL
% %  'J:\TannerBertGroup\Lab_Mechanics\Porcine_RLC_Phos\Acquired\Pig_2018', '23727R12', 30, 20000, 0.5, 0.05, 4.8, 0.3, 0.001 , 2.2; %% AP 2.2 SL

%% Human 2024
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 3, 20000, 0.5, 0.05, 4.0, 0.3, 6.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 4, 20000, 0.5, 0.05, 4.0, 0.3, 4.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 5, 20000, 0.5, 0.05, 4.0, 0.3, 2.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 6, 20000, 0.5, 0.05, 4.0, 0.3, 1.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 7, 20000, 0.5, 0.05, 4.0, 0.3, 0.5 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 8, 20000, 0.5, 0.05, 4.0, 0.3, 0.25 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 9, 20000, 0.5, 0.05, 4.0, 0.3, 0.175 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 10, 20000, 0.5, 0.05, 4.0, 0.3, 0.1 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R15', 11, 20000, 0.5, 0.05, 4.0, 0.3, 0.05 , 2.3; %% Control 2.3 SL

% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 3, 20000, 0.5, 0.05, 4.0, 0.3, 6.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 4, 20000, 0.5, 0.05, 4.0, 0.3, 4.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 5, 20000, 0.5, 0.05, 4.0, 0.3, 2.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 6, 20000, 0.5, 0.05, 4.0, 0.3, 1.0 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 7, 20000, 0.5, 0.05, 4.0, 0.3, 0.5 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 8, 20000, 0.5, 0.05, 4.0, 0.3, 0.25 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 9, 20000, 0.5, 0.05, 4.0, 0.3, 0.175 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 10, 20000, 0.5, 0.05, 4.0, 0.3, 0.1 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 11, 20000, 0.5, 0.05, 4.0, 0.3, 0.05 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 12, 20000, 0.5, 0.05, 4.0, 0.3, 0.025 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 13, 20000, 0.5, 0.05, 4.0, 0.3, 0.01 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 14, 20000, 0.5, 0.05, 4.0, 0.3, 0.005 , 2.3; %% Control 2.3 SL
% % 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R16', 15, 20000, 0.5, 0.05, 4.0, 0.3, 0.001 , 2.3; %% Control 2.3 SL

'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 3, 20000, 0.5, 0.05, 4.0, 0.3, 8.0 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 4, 20000, 0.5, 0.05, 4.0, 0.3, 6.0 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 5, 20000, 0.5, 0.05, 4.0, 0.3, 4.0 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 6, 20000, 0.5, 0.05, 4.0, 0.3, 2.0 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 7, 20000, 0.5, 0.05, 4.0, 0.3, 1.0 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 8, 20000, 0.5, 0.05, 4.0, 0.3, 0.5 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 9, 20000, 0.5, 0.05, 4.0, 0.3, 0.25 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 10, 20000, 0.5, 0.05, 4.0, 0.3, 0.175 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 11, 20000, 0.5, 0.05, 4.0, 0.3, 0.1 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 12, 20000, 0.5, 0.05, 4.0, 0.3, 0.05 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 13, 20000, 0.5, 0.05, 4.0, 0.3, 0.025 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 14, 20000, 0.5, 0.05, 4.0, 0.3, 0.01 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 15, 20000, 0.5, 0.05, 4.0, 0.3, 0.005 , 2.3; %% Control 2.3 SL
% 'J:\TannerBertGroup\Lab_Mechanics\Human_Cardiac_2024\Acquired\Human\Myotropes_studies\2B487', '24208R118', 16, 20000, 0.5, 0.05, 4.0, 0.3, 0.0018 , 2.3; %% Control 2.3 SL

};

%% Make some File Paths for Output Files
output_data_file_string = ['kREL_ATP_Fit_Output' filesep 'Out_ATP_Fit_Data.txt'];
output_fit_image = ['kREL_ATP_Fit_Output' filesep 'Fiber_Fit_Figs' filesep];

out_fiber_data = [];
out_fiber = {};


%%Fiber Sorting
%First sort by individual fiber

Unique_Fiber_Names = unique(FileList(:,2));

%Process ADP Fit for a Single Fiber
for ifiber = 1:length(Unique_Fiber_Names)
    %Creates a temporary array of just the file information for just one unique fiber.
    Unique_Fiber_index = find((strcmp(FileList(:,2),Unique_Fiber_Names(ifiber))) == 0);
    Single_Fiber = FileList;
    Single_Fiber(Unique_Fiber_index, :) = [];
    Single_Fiber = sortrows(Single_Fiber,3);

    %     Single_Fiber = FileList;
    [r,c]=size(Single_Fiber)


    for i=1:r
        %
        %         %% Gather the t, Strain, Stress for the file
        %         [t, Strain, Stress] = ImportRun_Step_v1(Single_Fiber{i,1}, Single_Fiber{i,2}, Single_Fiber{i,3}, Single_Fiber{i,4}, Single_Fiber{i,5}, Single_Fiber{i,6});
        %         toc

        %% Process k_rel vs. MgATP for this fiber
        data_dir =  Single_Fiber{i,1};
        data_filename = [Single_Fiber{i,2} '_Step.txt']

        % Fit the curve, and return the values for data variables
        % Note, function for the fitting
        % xdata=MgATP
        % k_rel(ATP)=kADP_release*MgATP/((kADP_release/kATP_binding) + MgATP)

        %        out_data = analyze_kRELvsATP_plots(data_dir, data_filename)
        %        analyze_kRELvsATP_plots(data_dir, data_filename)
        InFile = [data_dir filesep data_filename];
        data = importdata(InFile);

        %Row 1 of Text Data = {'Fibername'}
        %Row 8 of Text Data = {'pCa'}
        %Row 3 of Text Data = {'ATP (mM)'}
        %Row 33 of Text Data = {'k_rel2 (s-1)'}

        % % If only want ATP 0 through 5 mM
        % pCa= data.data(2:end,7)
        % ATP = data.data(2:end,2)
        % k_rel = data.data(2:end,32)

        % If only want ATP 0.001 through 5 mM
        pCa= data.data(2:end-1,7);
        ATP = data.data(2:end-1,2);
        k_rel = data.data(2:end-1,32);


        %                         % Fit data
        [best_p, fit, exit_flag] = BT_kRELvsATP_Fit(ATP, k_rel, ...
            'figure_number',1);

        k_ADP = best_p(1);
        k_ATP = best_p(2);
        MgATP50 = 1000*(best_p(1)/best_p(2));
        r_squared = corr(k_rel, fit)*corr(k_rel, fit);

        %% Store data for output
            out_fiber_data = [out_fiber_data; [pCa(1,1), k_ADP, k_ATP, MgATP50, r_squared, exit_flag] ]
            out_fiber = [out_fiber ; Single_Fiber(i,2)]

            % Plot results
            clf(figure(2))
            subplot(2,1,1)
            plot(ATP,k_rel,'ks'); hold on
            plot(ATP,fit,'bo-');
            title([ ['Fiber = ', data.textdata{2,1}]...
                ['     R^2 = ', num2str(r_squared)]; ...
                ])
            legend('Data', 'Fit', 'Location', 'southeast')


            % Now x-axis = log
            subplot(2,1,2)
            plot(ATP,k_rel,'ks'); hold on
            plot(ATP,fit,'bo-');
            set(gca, 'xScale', 'log')

            pause(1)

            %Save Figure
            Fiber = data.textdata{2,1};
            saveas(gcf, ...
                sprintf('%s.png', ...
                [output_fit_image, ...
                Fiber ]), ...
                'png' )

            %         %% Scale figure size
            %         %% Defaul screensize is pixels
            %         set(0,'Units','inches');
            %         scrsz_inches = get(0,'ScreenSize');
            %         set(0,'Units','pixels');
            %         scnsize_pix = get(0,'ScreenSize');
            %         pix_per_inch=scnsize_pix(1,3)/scrsz_inches(1,3);
            %         %% Set figure size--lower left cooridnates(a, b), then witdth then height
            %         %set(gcf, 'Position',[2 2 7 3.5]) for example with 7 by 3.5 inches.  It
            %         %happens that this also includes the bounding box
            %         set(gcf, 'Position', [150, 150, pix_per_inch*12, pix_per_inch*8])

        end

    end

    %Write Header to File
    %        if exist(output_data_file_string, 'file') == 2 %If the file already exists .
    %                    Header = '';
    %                else
    % Build header
    Header = sprintf('%s\t', 'Fibername', ...
        'pCa', 'k_ADP (s-1)', 'k_ATP (mM-1 s-1)',...
        'MgATP50 (uM)', 'r_squared', 'Exit_Flag');
    Header = [Header, '\n'];
    %                end

    % Output Data  = Fiber     pCa, k_ADP, k_ATP, MgATP50, r2, Exit Flag
    % out_fiber(i, 1),
    % [pCa, k_ADP, k_ATP, MgATP50, r_squared, exit_flag];

    % Build Data Output Format specifications
    formatDataSpec = ['%2.2f\t %6.4f\t %6.4f\t %6.4f\t %3.3f\t %1i' ...
        '\n'];

    % open file, with write = 'w' -->
    % open file for writing; discard existing contents
    fid_out=fopen(output_data_file_string, 'w');

    % Write Header
    fprintf(fid_out, Header);

    % Write Data Out
    [nrows,ncols] = size(out_fiber_data);
    for row = 1:nrows
        %write fiber name
        fprintf(fid_out,'%s\t', out_fiber{row,1});
        %wirte data
        fprintf(fid_out, formatDataSpec, out_fiber_data(row, :) );
    end

    fclose(fid_out);

    