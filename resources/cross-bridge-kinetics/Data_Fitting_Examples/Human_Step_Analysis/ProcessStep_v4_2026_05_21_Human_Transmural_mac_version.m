%% BCWT; December 15, 2010
%% Building General Code for Testing and Analysis of GWN stimulus Files
%% generic rigs
%%

clear, close all, clc

%% Example Fiber information as shown below:
%% File Path (Directory), string:'C:\BertUVM\WhiteNoise\PPG_MyBP_C\JAP_Repeat_Tests'
%% File Name (without extension--it searches for scs), string:'GWN_10914R21'
%% File information example for 5 mM ATP, number:0 (here is 0)2.3
%%                Path to Data                            File       Run  fs   StepDur(s)  step-time (s)   pCa   MgATP    SL
%%      [CurrentDir filesep 'Cardiac_Data'], 'GWN_10C1541', 1, 20000,   1,      0.05,         4.0,    5.0,    2.2;
% Above = FileList, columns 1-9
%%      SL      Sex     Hashcode	Region    Condition (Cond)
% Above = FileList, columns 9-13

CurrentDir = pwd;

%%%%%%%Human Transmural 2024
%

%% Create the file list as a set cells, then pass
FileList={

%%%%%%%%%%%%%%%%% 4FB2F Endo %%%%%%%%%%%%%%%%%%%%%

[CurrentDir filesep 'Cardiac_Data'], '24813R11', 3, 20000, 1, 0.05, 4.0,  8, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 4, 20000, 1, 0.05, 4.0,  6, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 5, 20000, 1, 0.05, 4.0,  4, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 6, 20000, 1, 0.05, 4.0,  2, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 7, 20000, 1, 0.05, 4.0,  1, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 8, 20000, 1, 0.05, 4.0,  0.5, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 9, 20000, 1, 0.05, 4.0,  0.25, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 10, 20000, 1, 0.05, 4.0, 0.175, 2.3,'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 11, 20000, 1, 0.05, 4.0, 0.1, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 12, 20000, 1, 0.05, 4.0, 0.05, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 13, 20000, 1, 0.05, 4.0, 0.025, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 14, 20000, 1, 0.05, 4.0, 0.01, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 15, 20000, 1, 0.05, 4.0, 0.005, 2.3, 'F', '48CAF', 'Endo', 'DCM';
[CurrentDir filesep 'Cardiac_Data'], '24813R11', 16, 20000, 1, 0.05, 4.0, 0.0018, 2.3, 'F', '48CAF', 'Endo', 'DCM';

};


addpath('Code') % Add path to access the fitting functions.

%%Fiber Sorting
%First sort by individual fiber
Unique_Fiber_Names = unique(FileList(:,2));

for ifiber = 1:length(Unique_Fiber_Names)
    %Creates a temporary array of just the file information for just one unique fiber.
    Unique_Fiber_index = find((strcmp(FileList(:,2),Unique_Fiber_Names(ifiber))) == 0);
    Single_Fiber = FileList;
    Single_Fiber(Unique_Fiber_index, :) = [];
    Single_Fiber = sortrows(Single_Fiber,3)

    %     Single_Fiber = FileList;
    [r,c]=size(Single_Fiber);

    tic

    for i=1:r

        %% Gather the t, Strain, Stress for the file
        [t, Strain, Stress] = ImportRun_Step_v1(Single_Fiber{i,1}, Single_Fiber{i,2}, Single_Fiber{i,3}, Single_Fiber{i,4}, Single_Fiber{i,5}, Single_Fiber{i,6});
        toc

        %% Fill a set of variable:
        % P--being P for tenion
        % t--being t for time points
        % 0--mean of the pre-duration, and 0 time is the stretch time
        % 1--peak of the stretch (max F) and time of the peak
        % 2--minimum of the relaxation and time of the relaxation
        % 3--maximum of the redevelopment of the force following relaxation & time
        % F--final or the mean of the last little bit (waiting time) and final time
        % Also--record the time to reach half the tensile stress between t1 and t2
        %       call this t12half, and record the time for the tension to reach
        %       half way between the minimum of 2 and maximum 3, call this t23half.
        % Also--fit the 2 and 3 phase with a double exponential:
        %       For this fitting--we will strip off the T0 value for stress
        %       and begin our fitting of the time, Stress relationship from t1
        %       forward, only looking at the relax and redevelopment phases

        %% Find T0 and t0 compared to waiting duration, and calculate T0 as the
        %% mean for the beginning waiting duration
        [t0,it0] = min(abs(t-Single_Fiber{i,6}));
        % Because using min and subtraction it returns difference value and index
        % so now, restuff these values
        t0=t(it0);%% Raw time value in seconds
        T0=mean(Stress(1:it0, 1)); %% Raw Stress value in kPa

        %% Find T1 and t1, as the maximum force values following t0.
        [T1,it1] = max(Stress(it0:end,1));
        % Again because this was pulled as a relative, we need to adjust the offset
        % for the max, etc and restuff these values:
        it1=it1+it0; %% Make this absolute in the array indexing for time.
        t1=t(it1, 1); % This will return a time value (seconds).

        %% Find TF and tF, as the mean force values for the last X points
        %% equivalently long as the waiting duration
        tF=t(end, end);%% Raw time value in seconds
        TF=mean(Stress(end-it0, 1)); %% Raw Stress value in kPa

        % Start to plot some of our raw data.  Strain and delta_Force from
        % Isometric force.
        clf(figure(1))
        subplot(2,3,1)
        plot(t, Strain)
        xlabel('time (s)')
        ylabel('Strain')
        xlim([t(1,1), tF])
        % Make title, the Fiber Name + the Run Number
        title([ Single_Fiber{i,2}, ', Run ' num2str(Single_Fiber{i,3} ) ] )

        subplot(2,2,2)
        plot(t, Stress), hold on
        plot(t0, T0, 'ko', 'markerfacecolor', 'y') % place point for t0
        plot(t1, T1, 'ko', 'markerfacecolor', 'y')% place point for t1 peak
        plot(tF, TF, 'ko', 'markerfacecolor', 'y')% place point for t_final
        xlim([t(1,1), tF])
        % Now scale ylim to be [auto, T1*1.2]
        y_limits = ylim;
        ylim([y_limits(1,1), 1.2*T1])
        title('4 phase timepoints')
        xlabel('Time (s)')
        ylabel('Stress - T0 (kN m^{-2})')

        % Write out instructions for the user to click near t2 for finding
        % the minimum or nadir--if it exists.  Otherwise, click minimum
        % near-ish to T_Final
        text(t0, T0, {'Use mouse pointer to click on rising force', 'trace near nadir (but right-->) of t2', 'and left of t3'})
            waitforbuttonpress;
                cp = get(gca, 'CurrentPoint');
                xga = cp(1,1);
                yga = cp(1,2);;
        % clear the above object for 'instructions text', from axes
        delete(findobj(gca, 'Type', 'text'));

        % This should set xga = to the 'time' that we should look left of for the
        % nadir.  That is, xga = max time to look, to search for minimum tension
        % from t1 to tF.
        [t_Xhair,it_Xhair] = min(abs(t-xga));

        %% Find T2 and t2, as the minimum force values following t1.
        [T2,it2] = min(Stress(it1:it_Xhair,1));
        % Again because this was pulled as a relative, we need to adjust the offset
        % for the max, etc and restuff these values:
        it2=it2+it1; %% Make this absolute in the array indexing for time.
        t2=t(it2, 1); % This will return a time value (seconds).

        %% Find T3 and t3, as the maximum force values following t2.
        [T3,it3] = max(Stress(it2:end,1));
        % Again because this was pulled as a relative, we need to adjust the offset
        % for the max, etc and restuff these values:
        it3=it3+it2; %% Make this absolute in the array indexing for time.
        t3=t(it3, 1); % This will return a time value (seconds).

        %% Now that we know all our changes and phase duarations let's
        %% pull down the half times for phase 2 and phase 3
        % Also--record the time to reach half the tensile stress between t1 and t2
        %       call this t12half, and record the time for the tension to reach
        %       half way between the minimum of 2 and maximum 3, call this t23half.
        [T12half,it12half] = min(abs(Stress(it1:it2,1)-mean([T1,T2])));
        % Again because this was pulled as a relative, we need to adjust the offset
        % for the average value and restuff these values:
        % There is something below that we were off by 1 for the half-times
        % in the indexing, where the
        it12half=(it12half-1)+it1; %% Make this absolute in the array indexing for time.
        t12half=t(it12half, 1); % This will return a time value (seconds).
        T12half=Stress(it12half, 1); %% Grab the real stress

        %       Now half time of phase23
        [T23half,it23half] = min(abs(Stress(it2:it3,1)-mean([T2,T3])));
        % Again because this was pulled as a relative, we need to adjust the offset
        % for the average value and restuff these values:
        it23half=(it23half-1)+it2; %% Make this absolute in the array indexing for time.
        t23half=t(it23half, 1); % This will return a time value (seconds).
        T23half=Stress(it23half, 1); %% Grab the real stress

        % Plot the rest of the placeholder locations on the subplot
        % for Stress vs. Time
        plot(t2, T2, 'ko', 'markerfacecolor', 'y')
        plot(t3, T3, 'ko', 'markerfacecolor', 'y')
        plot(t12half, mean([T1,T2]), 'ko', 'markerfacecolor', 'y')
        plot(t23half, mean([T2,T3]), 'ko', 'markerfacecolor', 'y')
        % Now label them to help with clarity.
        text([t0+4*(t1-t0)], T0, ['t_{0} = ' num2str(t0, '%.3f') 's,  T_{0} = ' num2str(T0, '%.2f') ' kN/m2' ])
        text([t1+4*(t1-t0)], T1, ['t_{1} = ' num2str(t1, '%.3f') 's,  T_{1} = ' num2str(T1, '%.2f') ' kN/m2' ])
        text(1.2*t12half, mean([T1,T2]), ['t_{1/2} = ' num2str(t12half, '%.3f') 's,  T_{1/2} = ' num2str(mean([T1,T2]), '%.2f') ' kN/m2' ])
        text([t2+4*(t1-t0)], T2, ['t_{2} = ' num2str(t2, '%.3f') 's,  T_{2} = ' num2str(T2, '%.2f') ' kN/m2' ])
        text(1.2*t23half, mean([T2,T3]), ['t_{2,3} = ' num2str(t23half, '%.3f') 's,  T_{2/3} = ' num2str(mean([T2,T3]), '%.2f') ' kN/m2'],...
            'color', 'm', 'fontweight', 'bold', 'FontSize', 16)
        text(1.1*t3, T3, ['t_{3} = ' num2str(t3, '%.3f') 's,  T_{3} = ' num2str(T3, '%.2f') ' kN/m2' ])
        text(mean([tF,t0]), mean([tF,t0]), ['t_{final} = ' num2str(t3, '%.3f') 's,  T_{final} = ' num2str(TF, '%.2f') ' kN/m2' ])

        % Given the points of time and tension that we pulled off the data,
        % we can fit the data to explore the rates.  However, I can put in our
        % parameter guesses that we are interested in.
        % Remember--that we are going to look into fitting the data with the T0
        % subtracted and t1 being = to zero seconds.

        % Work with some rough parameters for phase 2 and phase 3 fitting.  To
        % begin: A2*exp(-kf_12*t)+A3*(1-exp(-kf_df*t)) -- but do this with t12,
        % and t23 with repsect to t1
        % Guess at the Amplitudes and rates.  Rates = log(2)/t_half
        A2=abs(T1); %% Decay amplitue
        kf_12=log(2)/(t12half-t0);
        A3=abs(T3); %% T2, T3, or T2 and T3 diference?
        kf_23=log(2)/(t23half-t0);
        kf_df=log(2)/(t23half-t2);

        %% So, now we should fit the data:
        % Subtract Tesion and time to make 'Relative Tension and Relative Time'
        T_Fit=Stress(it1:end, 1)-T0;
        Strain_Fit=Strain(it1:end, 1);
        %t_Fit=t(it1:end, 1)-t(it0, 1);
        t_Fit=t(it1:end, 1)-t(it1, 1);

        % % %% Estimate the fast and slow exp, based on 1/2 times data.
        % % phase2_test=A2*exp(-kf_12*t_Fit);
        % % phase3_test=A3*(1-exp(-kf_df*t_Fit));
        % % %  this looks better on the rising edge for the phase 3 plot
        % 
        % % %% How does this fit look? Plot over top of data?
        % % subplot(2,3,3)
        % %plot(t_Fit, T_Fit, 'b-'), hold on
        % plot(t_Fit+t1, phase2_test, 'm-')
        % plot(t_Fit+t1, phase3_test, 'c-')

        %Test only looking for the next 1/2 second after t1--to fit data
        %more to have the dip region vs. the flat regions.
        %% So, now we should fit the data:
        % Subtract Tesion and time to make 'Relative Tension and Relative Time'
        %T_Fit=Stress(it1:end, 1)-T0;
        T_Fit=Stress(it1:it1+Single_Fiber{i,4}*0.95, 1)-T0; %% Clip at 1/2 second past it1
        %Strain_Fit=Strain(it1:end, 1);
        Strain_Fit=Strain(it1:it1+Single_Fiber{i,4}*0.95, 1);
        %t_Fit=t(it1:end, 1)-t(it0, 1);
        t_Fit=t(it1:it1+Single_Fiber{i,4}*0.95, 1)-t(it0, 1);


        %% Fitting on: A2*exp(-kf_12*t)+A3*(1-exp(-kf_df*t))
        %% where here--x returns the parameters in order of ParamGuess
        ParamGuess=[A2; kf_12; A3; kf_df];
        % If you want or need to test and use the ParamGuess, then
        % Uncomment below here  Otherwise, initial guess will be all 1s
        %
        % Dual Exponential Fit
        %        [x_1, fit_1, exitflag_1] = BT_Phase2_3_Fit(t_Fit, T_Fit, 'initial_p', ParamGuess', 'figure_number', 11);
        [x_1, fit_1, exitflag_1] = BT_Phase2_3_Fit(t_Fit, T_Fit, 'initial_p', ParamGuess');
        R = corrcoef(T_Fit, fit_1);


        figure(1)
        subplot(2,3,4)
        plot(t_Fit, T_Fit, 'b-'), hold on
        plot(t_Fit, fit_1, 'g-', 'linewidth', 2), hold on
        plot(t_Fit,  x_1(1)*exp(-x_1(2)*t_Fit), 'm-') % Fast Exp Fit
        plot(t_Fit, x_1(3)*(1-exp(-x_1(4)*t_Fit)), 'c-') %Slow Exp Fit
        text(t12half, mean([T1,TF]), ['A_{fast} = ' num2str(x_1(1,1), '%.1f'), ' kN/m2, k_{fast} = ' num2str(x_1(1,2), '%.3f') ' s^{-1}'])
        text(t12half, TF/2, ['A_{slow} = ' num2str(x_1(1,3), '%.1f'), ' kN/m2, k_{slow} = ' num2str(x_1(1,4), '%.3f') ' s^{-1}'])
        title(['Dual Exp Fit R^2=' num2str(R(1,2)*R(1,2), '%.2f')])
        xlabel('Time-t0 (s)')
        ylabel('Stress-T0 (kN m^{-2})')
        legend( 'Data', 'Fit', 'Fast Exp', 'Slow Exp')
        xlim([0, 1])

        %% Fitting on: A2*exp(-kf_12*t)+A3*(1-exp(-kf_df*t))+C
        %% where here--x returns the parameters in order of ParamGuess
        ParamGuess2=[ParamGuess; 0];
        % If you want or need to test and use the ParamGuess, then
        % Uncomment below here  Otherwise, initial guess will be all 1s
        %
        % Dual Exponential Fit
        %[x_2, fit_2, exitflag_2] = BT_Phase2_3_Offset(t_Fit, T_Fit, 'initial_p', ParamGuess2', 'figure_number', 12);
        [x_2, fit_2, exitflag_2] = BT_Phase2_3_Offset(t_Fit, T_Fit, 'initial_p', ParamGuess2');
        R_x2 = corrcoef(T_Fit, fit_2);

        figure(1)
        subplot(2,3,5)
        plot(t_Fit, T_Fit, 'b-'), hold on
        plot(t_Fit, fit_2, 'g-', 'linewidth', 2), hold on
        plot(t_Fit,  x_2(1)*exp(-x_2(2)*t_Fit), 'm-') % Fast Exp Fit
        plot(t_Fit, x_2(3)*(1-exp(-x_2(4)*t_Fit)), 'c-') %Slow Exp Fit
        text(t12half, mean([T1,TF]), ['A_{fast} = ' num2str(x_2(1,1), '%.1f'), ' kN/m2, k_{fast} = ' num2str(x_2(1,2), '%.3f') ' s^{-1}'])
        text(t12half, TF/2, ['A_{slow} = ' num2str(x_2(1,3), '%.1f'), ' kN/m2, k_{slow} = ' num2str(x_2(1,4), '%.3f') ' s^{-1}'])
        text(t12half, mean([T2,T0]), ['Offset = ' num2str(x_2(1,5), '%.1f'), ' kN/m2'])
        title(['Dual Exp Fit + Offset R^2=' num2str(R_x2(1,2)*R_x2(1,2), '%.2f')])
        xlabel('Time-t0 (s)')
        ylabel('Stress-T0 (kN m^{-2})')
        legend( 'Data', 'Fit', 'Fast Exp', 'Slow Exp')
        xlim([0, 1])

        %% Fitting on the ABC Process for the Step vs. Time fit:
        %  StepForce_Fit = ...
        %      p(1) * (x_data .^ (-p(2)) ) - ...
        %     (p(3)*exp( -(2*pi*p(4)*x_data) )) +...
        %     (p(5)*exp( -(2*pi*p(6)*x_data) ));

        %% where here--x returns the parameters in order of ParamGuess
        %ParamGuess3=[A; 0.2; abs(T1-TF); kf_df; abs(T1-TF)/2; kf_12];
        % If you want or need to test and use the ParamGuess, then
        % Uncomment below here  Otherwise, initial guess will be all 1s
        %
        % Dual Exponential Fit
        %[x_3, fit_3, exitflag_3] = Step_ABC_Time_Fit_v4(t_Fit, T_Fit, 'initial_p', ParamGuess3', 'figure_number', 13);
        [x_3, fit_3, exitflag_3] = Step_ABC_Time_Fit_v4(t_Fit, T_Fit, 'figure_number', 13);
        R = corrcoef(T_Fit, fit_3);

        figure(1)
        subplot(2,3,6)
        plot(t_Fit, T_Fit, 'b-'), hold on
        plot(t_Fit, fit_3, 'g-', 'linewidth', 1), hold on
        plot(t_Fit,  x_3(5)*exp(-(2*pi*x_3(6))*t_Fit), 'm-') % Fast Exp Fit
        plot(t_Fit, -x_3(3)*exp(-(2*pi*x_3(4))*t_Fit), 'c-') %Slow Exp Fit
        plot(t_Fit, x_3(1) * (t_Fit .^ (-x_3(2)) ), 'k-') %A Process
        text(t12half, 1.25*TF, ['C_T = ' num2str(2*pi*x_3(5), '%.3f') ' mN/mm2, 2\pic = ' num2str(2*pi*x_3(6), '%.3f') ' s^{-1}'])
        text(t12half, 0.25, ['B_T = ' num2str(2*pi*x_3(3), '%.3f') ' mN/mm2, 2\pib = ' num2str(2*pi*x_3(4), '%.3f')  ' s^{-1}'])
        text(t12half, -0.25, ['A_T = ' num2str(2*pi*x_3(1), '%.3f') ' mN/mm2, k = ' num2str(2*pi*x_3(2), '%.3f')])
        title(['Step ABC Fit R^2=' num2str(R(1,2)*R(1,2), '%.2f')])
        xlabel('Time-t0 (s)')
        ylabel('Stress-T0 (kN m^{-2})')
        legend( 'Data', 'Fit', 'C->Fast Exp', 'B-> Slow Exp', 'A proc.', 'location', 'SouthEast')
        ylim([-max(T_Fit), 1.2*max(T_Fit)])
        % Make x-lim the full data time, even if it was stripped
        % off to use a smaller set of Force vs. Time data.
        xlim([0, 1])

        if i==1
            clf(figure(3))
        else
            figure(3)
        end
        subplot (3,1,1)
        plot(t, Strain, 'linewidth', 0.005), hold on
        title(['Fiber Name = ' Single_Fiber{i,2}])
        xlabel('time (s)')
        xlim([0, 1])
        ylabel('Strain')

        figure(3)
        subplot (3,1,2)
        plot(t, Stress, 'linewidth', 0.005), hold on
        xlabel('time (s)')
        xlim([0, 1])
        ylabel('\Delta Stress')

        subplot(3,1,3)
        plot(t_Fit, fit_3), hold on
        xlabel('time (s)')
        xlim([0, 1]) %xlim([0, 1])
        ylabel('ABC Fit')


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
        set(gcf, 'Position', [150, 150, pix_per_inch*12, pix_per_inch*8])

        figure(1)
        set(figure(1), 'Position', [50, 50, pix_per_inch*10, pix_per_inch*8])
        pause(1)

        %% Test for BERT -- OUTPUTS?
        disp(['ifiber=' num2str(ifiber) ', i (i.e. run)=' num2str(i)])

        % % Write Out Fit Step Figure for each Run.
        % Out_Fig_Dir = [Single_Fiber{i,1} filesep 'Step_Fit_Figs' filesep];
        % Out_Fig_Name = [Single_Fiber{i,2} '_Run' num2str(Single_Fiber{i,3}) '_StepFits'];
        % % if the Out Directory Exists
        % if exist(Out_Fig_Dir, 'dir') == 7
        %     % Write out the figure
        %     saveas(figure(1), [Out_Fig_Dir Out_Fig_Name], 'png')
        %     saveas(figure(1), [Out_Fig_Dir Out_Fig_Name], 'fig')
        % else % Need to make the dir and write the file
        %     mkdir(Out_Fig_Dir)
        %     as(figure(1), [Out_Fig_Dir Out_Fig_Name], 'png')
        %     saveas(figure(1), [Out_Fig_Dir Out_Fig_Name], 'fig')
        % end

        % % If we are done with this fiber--then we can write out Fig. 3
        % % which is the summary figure.
        % if i == r
        %     % Write Out Fit Step Figure for each Run.
        %     Out_SummaryFig_Name = [Single_Fiber{i,2} '_Summary_StepFits'];
        %     saveas(figure(3), [Out_Fig_Dir Out_SummaryFig_Name], 'png')
        %     saveas(figure(3), [Out_Fig_Dir Out_SummaryFig_Name], 'fig')
        % end

        %% Fill some temp data for looking at the kinetics for each fiber as a whole or summary plots.

if i == 1
            Hashcode = {Single_Fiber{i,11}};
            Fiber = {Single_Fiber{i,2}};
            Region = {Single_Fiber{i,12}};
            Sex = {Single_Fiber{i,10}};
            Cond = {Single_Fiber{i,13}};
            Run = Single_Fiber{i,3};
            pCa = Single_Fiber{i,7};
            ATP_mM = Single_Fiber{i,8};
            SL_um = Single_Fiber{i,9};
            t1_s = t1;
            t12_s = t12half;
            t2_s = t2;
            t23_s = t23half;
            t3_s = t3;
            tF_s = tF;
            T1_mNmm2 = T1;
            T12_mNmm2 = T12half;
            T2_mNmm2 = T2;
            T23_mNmm2 = T23half;
            T3_mNmm2 = T3;
            TF_mNmm2 = TF;
            kf_12_s1=kf_12;
            kf_23_s1=kf_23;
            kf_df_s1=kf_df;
            Afast = x_2(1,1);
            kfast = x_2(1,2);
            Aslow = x_2(1,3);
            kslow = x_2(1,4);
            offset = x_2(1,5);
            R2 = R_x2(1,2)*R_x2(1,2);
            A_kPa = x_3(1,1);
            k = x_3(1,2);
            B_kPa = x_3(1,3);
            b_Hz = x_3(1,4);
            C_kPa = x_3(1,5);
            c_Hz = x_3(1,6);
            r2 = R(1,2)*R(1,2);
        else
            Hashcode = [Hashcode ; Single_Fiber{i,11}];
            Fiber =[Fiber ; Single_Fiber{i,2}];
            Region =[Region ;Single_Fiber{i,12}];
            Sex =[Sex ;Single_Fiber{i,10}];
            Cond =[Cond ;Single_Fiber{i,13}];
            Run =[Run ;Single_Fiber{i,3}];
            pCa =[pCa ;Single_Fiber{i,7}];
            ATP_mM =[ATP_mM ;Single_Fiber{i,8}];
            SL_um =[SL_um ;Single_Fiber{i,9}];
            t1_s =[t1_s ;t1];
            t12_s =[t12_s ;t12half];
            t2_s =[t2_s ;t2];
            t23_s =[t23_s ;t23half];
            t3_s =[t3_s ;t3];
            tF_s =[tF_s ;tF];
            T1_mNmm2 =[T1_mNmm2 ;T1];
            T12_mNmm2 =[T12_mNmm2 ;T12half];
            T2_mNmm2 =[T2_mNmm2 ;T2];
            T23_mNmm2 =[T23_mNmm2 ;T23half];
            T3_mNmm2 =[T3_mNmm2 ;T3];
            TF_mNmm2 =[TF_mNmm2 ;TF];
            kf_12_s1=[kf_12_s1; kf_12];
            kf_23_s1=[kf_23_s1; kf_23];
            kf_df_s1=[kf_df_s1; kf_df];
            Afast =[Afast ;x_2(1,1)];
            kfast =[kfast ;x_2(1,2)];
            Aslow =[Aslow ;x_2(1,3)];
            kslow =[kslow ;x_2(1,4)];
            offset = [offset ;x_2(1,5)];
            R2 =[R2 ; R_x2(1,2)*R_x2(1,2)];
            A_kPa =[A_kPa ;x_3(1,1)];
            k =[k ;x_3(1,2)];
            B_kPa =[B_kPa ;x_3(1,3)];
            b_Hz =[b_Hz ;x_3(1,4)];
            C_kPa =[C_kPa ;x_3(1,5)];
            c_Hz =[c_Hz ;x_3(1,6)];
            r2 =[r2 ;R(1,2)*R(1,2)];
        end


        % If we are done with this fiber--then we can write out the data
        % Table, and Fig. 3 which is the summary figure.
        if i == r

            OutTable = table( Fiber, Hashcode, Region, Sex, Cond, ...
                Run, pCa, ATP_mM, SL_um, t1_s, t12_s, t2_s,  t23_s, t3_s, ...
                tF_s, T1_mNmm2, T12_mNmm2, T2_mNmm2, T23_mNmm2, T3_mNmm2, ...
                TF_mNmm2, kf_12_s1, kf_23_s1, kf_df_s1, Afast, kfast, ...
                Aslow, kslow, offset, R2, A_kPa, k,  B_kPa, b_Hz, C_kPa, c_Hz, r2);

            % %% Write out excel file
            Out_Fiber_Data = [Single_Fiber{i,1} filesep Single_Fiber{i,2} '_StepFits.xlsx'];
            writetable(OutTable,Out_Fiber_Data)
            %
            figure(3)
            subplot(3,2,5)
            plot(OutTable.ATP_mM, OutTable.kf_12_s1, 'ko'), hold on
            xlabel('MgATP')
            ylabel('kf,rel (from t1/2)')
            xlim([0, 8])

            %% Fit the detachment rate vs. MgATP relationship:
            %% Set our values the parameter guesses , where x(1)=kADP_release, x(2)=kATP_Binding:
            %% Take guesses of k_ADP=100 s-1 and k+ATP=300 s-1 (from Alpha Beta Paper)
            x_guess=[100, 300];

            %% Set our function for the fitting, xdata=MgATP
            %% kf_12_s1=kADP_release*MgATP/((kADP_release/kATP_binding) + MgATP)
            %% Also return the 2 norm as ResNorm=sum {(FUN(X,XDATA)-YDATA).^2}
            [x, ResNorm] = lsqcurvefit(@(x, xdata) x(1,1)*xdata./( (x(1,1)/x(1,2) ) + xdata ), x_guess, OutTable.ATP_mM, OutTable.kf_12_s1 );
            x_fit = x(1,1)*OutTable.ATP_mM./( (x(1,1)/x(1,2) ) + OutTable.ATP_mM);
            %R_fit = corrcoef(OutTable.kf_12_s1, x_fit);

            MgATP_Fit=[min(OutTable.ATP_mM):0.1:max(OutTable.ATP_mM)];
            detach_Fit=x(1,1)*MgATP_Fit./( (x(1,1)/x(1,2) ) + MgATP_Fit);


            %% plot this fit on panel 2
            plot(MgATP_Fit, detach_Fit, 'k-')
            axis_limits = axis; % will be a 1x4 vector: [xmin xmax ymin ymax]
            text(0.5*axis_limits(1,2), 0.5*axis_limits(1,4), ['k_{-ADP} = ' num2str(x(1), '%.2f') ' s^{-1}'])
            text(0.5*axis_limits(1,2), 0.3*axis_limits(1,4), ['k_{+ATP} = ' num2str(x(2), '%.2f') ' mM^{-1}s^{-1}'])
            text(0.5*axis_limits(1,2), 0.1*axis_limits(1,4), ['[MgATP]_{50} = ' num2str(1000*(x(1)/x(2)), '%.2f') ' \muM'])
            %title(['detachment vs. MgATP Fit, R^2=' num2str(R_fit(1,2)*R_fit(1,2), '%.2f')])
            title(['detachment vs. MgATP Fit, R^2= []'])

            subplot(3,2,6)
            plot(OutTable.ATP_mM,  2*pi*OutTable.c_Hz, 'ko'), hold on
            xlabel('MgATP')
            ylabel('2*pi*c (step fit)')
            xlim([0, 5])

            % % % Write Out Fit Step Figure for each Run.
            % Out_SummaryFig_Name = [Single_Fiber{i,2} '_Summary_StepFits'];
            % saveas(figure(3), [Out_Fig_Dir Out_SummaryFig_Name], 'png')
            % as(figure(3), [Out_Fig_Dir Out_SummaryFig_Name], 'fig')
        end

    end

end


