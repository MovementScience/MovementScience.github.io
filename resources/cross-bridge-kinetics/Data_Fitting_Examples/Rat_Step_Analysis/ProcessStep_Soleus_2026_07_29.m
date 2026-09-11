% Bert Tanner
% 10/19/2025
%Process step data from the file list, parsing on only the step data. Omit
% analysis of the force-velocity or isometric activatio trials.
% 
%Read in fiber filenames from selected excel file. Read the data from each
%fiber and estimate kinetic characteristics.

clear
close all
clc


%Set defaults
TimeToBath3=1.5; %[seconds] after initial movement (Movement_to_bath_3) to bath 3 (when activated)
plot_interval=5; %[seconds] time interval to plot after initial activation
StepBegin = 0; %[seconds] when begin estimating Step and Step RespOffset34onse
StepEnd = 1.4; %[seconds] when end estimating Step and Step Response
IsotonicBegin=0.005; %[seconds] when begin estimating isotonic force and velocity
IsotonicEnd=0.015; %[seconds] when to end estimating isotonic force and velocity

% Creat some variables (empty structures for now) to save some data we
% analyze from the Step trials, 2 SL = 2.7 and 2.4 uM.  Two conditions one
% is Control (not add to variable name) the other is OM (add lable to variable name).
StepData_27 = struct('Animal_ID', [], 'Fiber_Num', [], 'Protocol', [], ....
    'Fiber_Type', [], 'Species', [], 'Sex', [], 'Cond', [], 'SL_um', [], ...
    'ML_Working_mm', [], 'Fiber_D_um', [], 'Iso_F_mN', [], 'Iso_Stress_mNmm2', [], ....
    't0', [], 'Stress_t0', [], 't1', [], 'Stress_t1', [], 't12', [], ...
    'Stress_t12', [], 't2', [], 'Stress_t2', [], 't3', [], 'Stress_t3', ...
    [], 't4', [], 'Stress_t4', [], 'k_t12', [], 'k_t23', [], 'k_df', []);  % 0 uM OM
% Now for other conditions--mirror data structure
StepData_24 = StepData_27;  % 0 uM OM

% And for the Time-Series Data in a paralell stucture
StepTS_27 = struct('Step_time', [], 'Step_Stress', [], 'Step_Strain', []); % 0 uM OM
StepTS_24 = StepTS_27; % 0 uM OM


addpath('.\Code\') % Add path to access the fitting functions.

%Set filter
LPFcutoff=50; %50 Hz lowpass
%% Scale figure size
%% Defaul screensize is pixels
set(0,'Units','inches');
scrsz_inches = get(0,'ScreenSize');
set(0,'Units','pixels');
scnsize_pix = get(0,'ScreenSize');
pix_per_inch=scnsize_pix(1,3)/scrsz_inches(1,3);


%Initialize cumulative variables


% List the name of the Excel file with the list of trials and data charcteristics
% from each experiment
fn = 'Step_Analysis_List_Soleus_2025_11_21.xlsx';
% Read in data from the file list
all_data=readtable(fn);

% Path name for where the data is stored to import.  Assume all of the 
% individual fiber folders are in this folder
pn = '.\Soleus_Data\';
cd(pn) 


animal=all_data.Animal_ID(1);     %get cell data

for file_num=1:length(all_data.Fiber_Num)
    animal=cell2mat(all_data.Animal_ID(file_num));     %get cell data

    fiber_name=cell2mat(all_data.Fiber_Num(file_num));         %get fiber_num and convert to matlab variable
    cd(fiber_name)    %change dir to  specific fiber

    trial_num=all_data.Trial(file_num);
    SarcLength=all_data.SL_um(file_num); % microns
    Diameter=all_data.Fiber_D_um(file_num); %  microns
    ML=all_data.ML_Working_mm (file_num); % mm
    OM_Conc = all_data.OM_Conc_uM(file_num); % uM
    % Import type of protocol, either Step, Iso (for Isometric), or F_Vel
    % (for Force-Velocity).
    protocol=cell2mat(all_data.Protocol(file_num));

    % If Step and Trial 1 or 2
    if (strcmp(protocol, 'Step') & (trial_num == 1 || trial_num==2) )

        %Get data from data file
        Header=107;     %set  number of lines in the header (assume 107; okay if miss some data because bath transfer in beginning)
        current_trial_name=[fiber_name '_' int2str(trial_num) '.txt'];
        fID=fopen(current_trial_name,'r');
        count = 0;
        while count < 250 % Loop over at most the first 250 lines of file
            % I picked 250 because the header begins at line 106 for the
            % old data files and at 211 for the new data files.
            line_in = fgetl(fID); % Import file 1 line at a time
            count = count + 1; % Update line number of import
            if strcmp(line_in, '*** Force and Length Signals vs Time ***')
                % If we found the matching line for:
                % '*** Force and Length Signals vs Time ***'
                % Then the next line is the header, and 2 lines later the
                % data begins.
                Header = count + 1;
                first_line_in = count + 2;
                count = 300;
            end
        end
        % Read in all data after the Header line.
        data = readmatrix(current_trial_name,'NumHeaderLines',Header); %read in data, specify number of header lines
        fclose(fID);
        time=data(:,1)/1000; %convert to [seconds] from [milliseconds]
        SamplingRate=round(1/(time(21)-time(20))); %Can't assume SamplingRate; nothing special about time(20)
        %Set filter
        [b,a]=butter(4,LPFcutoff/(SamplingRate/2));
        fiber_length=data(:,2); %[mm]
        force=data(:,4); %[mN]


        %make time=0 at which fiber enters Bath3 (initial activation)
        time_begin=all_data.Movement_to_bath_3(file_num)+TimeToBath3;
        time=time-time_begin;
        IndexTimeZero=find(time==0);

        %Find baseline force (assumed to be when in pre-activating) and adjust force
        base_force=mean(force(IndexTimeZero-TimeToBath3*SamplingRate-500:IndexTimeZero-TimeToBath3*SamplingRate-100));
        force=force-base_force;
        % Calculate Stress, now that the base_force has been subtracted
        stress = force/(pi*(Diameter/2000)*(Diameter/2000)); %[mN mm^2]

        clf(figure(1))
        subplot(311),plot(time(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate),fiber_length(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate), 'k-')
        ylabel('Fiber length (mm)')
        grid
        title([protocol '  Animal ' animal '  Fiber ' fiber_name '  Trial ' num2str(trial_num)])
        subplot(312),plot(time(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate),force(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate), 'b-')
        hold on
        ylabel('Force (mN)')
        grid
        subplot(313),plot(time(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate), stress(IndexTimeZero-2*SamplingRate:IndexTimeZero+plot_interval*SamplingRate), 'm-')
        xlabel('Time (s)')
        ylabel('Stress (mN mm-2)')
        grid

        %Estimate isometric force prior to step
        EndTimeIsometric=all_data.Step_time_s(file_num)-all_data.Movement_to_bath_3(file_num)-TimeToBath3;
        if (all_data.Step_time_s(file_num)==0) %an isometric trial will have a step_time=0 so make end of isometric be at 3 seconds
            EndTimeIsometric=3.0;
        end %if step_time
        IndexEndTimeIsometric=find(time==EndTimeIsometric);
        InitialIsometricForce=mean(force(IndexEndTimeIsometric-100:IndexEndTimeIsometric-5));
        InitialIsometricStress=mean(stress(IndexEndTimeIsometric-100:IndexEndTimeIsometric-5));
        
        % Add Isometric Force and Stress to Figure 1 Output
        figure(1), subplot(312)
        title(['Isometric Force = ' num2str(InitialIsometricForce) ' mN']);
        subplot(313), title(['Isometric Stress = ' num2str(InitialIsometricStress) ' mN/mm2'])

        % Get our analysis lined up to look at the Strain of Step,
        % Stress-Isometric Stress at step,
        % time shift to t step = time 0
        Step_time = time(IndexEndTimeIsometric-50:IndexEndTimeIsometric+StepEnd*SamplingRate) - EndTimeIsometric;
        Step_Strain = (fiber_length(IndexEndTimeIsometric-50:IndexEndTimeIsometric+StepEnd*SamplingRate)-fiber_length(IndexEndTimeIsometric, 1) )/fiber_length(IndexEndTimeIsometric, 1);
        Step_Stress = stress(IndexEndTimeIsometric-50:IndexEndTimeIsometric+StepEnd*SamplingRate)-stress(IndexEndTimeIsometric);

        % Pull of our phases of t0, t1, t2, t3, t4
        [index_t0, icol_t0] = find(Step_time==0);
        t0 = Step_time(index_t0, 1);
        Stress_t0 = Step_Stress(index_t0, 1);
        % Similar to t0, find t4 = StepEnd (for how long to analyze)
        [value, index_t4] = min(abs(Step_time-StepEnd));
        t4 = Step_time(index_t4, 1);
        Stress_t4 = Step_Stress(index_t4, 1);
        % Find t1 and Stress(t1)
        [Stress_t1, index_t1] = max(Step_Stress);
        t1 = Step_time(index_t1, 1);
        % We need to guess on how far to look, so estimate
        % where the peak for t3 might be, maybe
        t_3_estimate = 0.5; % 15 milliseconds search range following step?
        [value, index] = min(abs(Step_time-t_3_estimate));
        % find miniumum within t1 to t_3_estimate
        [Stress_t2, index_t2] = min(Step_Stress(index_t1:index));
        index_t2 = (index_t1-1)+index_t2; % update offest on search from t1
        % but need to offset 1 with min( ) just above
        t2 = Step_time(index_t2, 1);
        % Find t12
        % (time to get half way decayed from Stress_t1 to Stress_t2)
        [value, index_t12] = min(abs(Step_Stress(index_t1:index_t2)-mean([Stress_t1, Stress_t2])));
        index_t12 = (index_t1-1)+index_t12; %% Need to offset 1 with min(abs...) just above
        Stress_t12=Step_Stress(index_t12, 1);
        t12 = Step_time(index_t12, 1);
        % find maximum within t2 to t__estimate
        [Stress_t3, index_t3] = max(Step_Stress(index_t2:index_t4));
        index_t3 = (index_t2-1)+index_t3; % update offest on search from t2
        t3 = Step_time(index_t3, 1);
        % Find t23
        % (time to get half way increased rise from Stress_t2 to Stress_t3)
        [value, index_t23] = min(abs(Step_Stress(index_t2:index_t3)-mean([Stress_t2, Stress_t3])));
        index_t23 = (index_t2-1)+index_t23; %% Need to offset 1 with min(abs...) just above
        Stress_t23=Step_Stress(index_t23, 1);
        t23 = Step_time(index_t23, 1);
        
        % Work with some rough parameters for phase 2 and phase 3 fitting.  To
        % begin: A2*exp(-kf_12*t)+A3*(1-exp(-kf_df*t)) -- but do this with t12,
        % and t23 with repsect to t1
        % Guess at the Amplitudes and rates.  Rates = log(2)/t_half
        A2=abs(Stress_t1); %% Decay amplitue
        kf_12=log(2)/(t12-t0);
        A3=abs(Stress_t3); %% T2, T3, or T2 and T3 diference?
        kf_23=log(2)/(t23-t0);
        kf_df=log(2)/(t23-t2);
        

        clf(figure(2))
        subplot(3, 1, 1)
        plot(Step_time, Step_Strain, 'k-'), hold on
        ylabel('Step Strain (ML-ML_{step})/ML_{step}')
        grid
        title([protocol '  Animal ' animal '  Fiber ' fiber_name '  Trial ' num2str(trial_num)])
        xlim([-0.05, StepEnd])

        subplot(3,1,2)
        plot(Step_time, Step_Stress, 'b-'), hold on
        plot(t0, Stress_t0, 'go')
        plot(t1, Stress_t1, 'ko'), text(t1, Stress_t1, '  t_1')
        plot(t12, Stress_t12, 'ro'), text(t12, Stress_t12, '  t_{1,2}')
        plot(t2, Stress_t2, 'co'), text(t2, Stress_t2, '  t_2')
        plot(t23, Stress_t23, 'r*'), text(t23, Stress_t23, '  t_{2,3}')
        plot(t3, Stress_t3, 'mo'), text(t3, Stress_t3, '  t_3')
        plot(t4, Stress_t4, 'ko')
        ylabel('Step Stress (mN mm-2)')
        xlabel('Time (seconds)')
        xlim([-0.05, StepEnd])
        grid
        title(['Isometric Force = ' num2str(InitialIsometricForce) 'mN; Isometric Stress = ' num2str(InitialIsometricStress) ' mN/mm2'])
        xlim([-0.05, StepEnd])

        subplot(3,2,5)
        plot(Step_time, Step_Strain./(max(Step_Strain)), 'k-' ), hold on
        plot(Step_time, Step_Stress./Stress_t1, 'b-')
        ylabel('Normalized to Max')
        xlabel('Time (seconds)')
        legend('Strain', 'Stress')
        grid
        xlim([-0.05, StepEnd])
        % ylim([-1000, 1e4])
        title(['Sarc Length = ' num2str(SarcLength) ' \mum; [OM] = ' num2str(OM_Conc) ' \muM'])


        subplot(3,2,6)
        plot(Step_time(index_t0:end), (Step_Stress(index_t0:end)./Step_Strain(index_t0:end)), 'k-'), hold on
        ylabel('Step Stress/Step Strain [mN mm-2]')
        xlabel('Time (seconds)')
        grid
        xlim([0, StepEnd])

        figure(2)
        set(figure(2), 'Position', [50, 50, pix_per_inch*10, pix_per_inch*8])
        %pause(0.25)
        % file_num



        % So, now we should fit the data:
        T_Fit=Step_Stress(index_t1:end, 1); % Use only data from t1 onward
        %t_Fit=Step_time(index_t1:end, 1); % Set fit zero time at t0
        t_Fit=Step_time(index_t1:end, 1)-t1; % Set fit zero time at t1


        clf(figure(3))
        subplot(2,2,1)
        plot(Step_time(index_t1:index_t4), Step_Stress(index_t1:index_t4), 'b-'), hold on
        plot(t0, Stress_t0, 'go')
        plot(t1, Stress_t1, 'ko'), text(t1, Stress_t1, '  t_1')
        plot(t12, Stress_t12, 'ko'), text(t12, Stress_t12, '  t_{1,2}')
        plot(t2, Stress_t2, 'ro'), text(t2, Stress_t2, 't_2')
        plot(t23, Stress_t23, 'ro')
        plot(t3, Stress_t3, 'mo'), text(t3, Stress_t3, 't_3')
        plot(t4, Stress_t4, 'ko')
        ylabel('Step Stress (mN mm-2)')
        xlabel('Time (seconds)')
        xlim([0, StepEnd])
        legend('Stress(t1-end)', 'location', 'northeast')
        grid
        title(['Isometric Force = ' num2str(InitialIsometricForce) 'mN; Isometric Stress = ' num2str(InitialIsometricStress) ' mN/mm2'])
        xlim([0, StepEnd])



        
        %% Fitting on: A2*exp(-kf_12*t)+A3*(1-exp(-kf_df*t))
        %% where here--x returns the parameters in order of ParamGuess
        % So, now we should fit the data with first :
        T_Fit=Step_Stress(index_t1:index_t4, 1); % Use only data from t1 onward
        t_Fit=Step_time(index_t1:index_t4, 1); % Set fit zero time at t0
        ParamGuess=[A2; kf_12; A3; kf_23];%[A2; kf_12; A3; kf_df];
        [x_23, fit_23, exitflag_1] = BT_Phase2_3_Offset(t_Fit, T_Fit, 'initial_p', [ParamGuess; 1]');
        %R2 = R(1,2)*R(1,2);
        t_plot_23=Step_time(index_t1:end, 1);
        fit_23=(x_23(1)*exp(-x_23(2)*t_plot_23))+(x_23(3)*(1-exp(-x_23(4)*t_plot_23)))+x_23(5);


        figure(3)
        subplot(2,2,2)
        plot(Step_time(index_t1:index_t4), Step_Stress(index_t1:index_t4), 'b-'), hold on
        plot(t_plot_23, fit_23, 'k-')
        %plot(t_plot_34, fit_34, 'm-')
        text(t12, Stress_t1*0.9, ['T_{23}fit=' num2str(x_23(1,1), '%.1f') 'exp(-' num2str(x_23(1,2), '%.2f') 't)+' ...
            num2str(x_23(1,3), '%.1f') '(1-exp(-' num2str(x_23(1,4), '%.2f') 't)+' num2str(x_23(1,5), '%.1f')  ])
        % text(t34, Stress_t1*0.3, ['T_{34} = ' num2str(x_34(1,1), '%.1f') 'exp(-' num2str(1/x_34(1,2), '%.2f') 't) + ' ...
        %      num2str(x_34(1,3), '%.1f')])
        grid
        title(['2 Exp Fit Stress(t1-t4)'])
        xlim([0, StepEnd])
        ylabel('Step Stress (mN mm-2)')

        % So, now we should fit the data--but try the 'modulus' normalized
        % to Stress at t1:
        %T_Fit=Step_Stress(index_t1:end, 1); % Use only data from t1 onward
        t_Fit=Step_time(index_t1:index_t4, 1); % Set fit zero time at t0
        T_Fit=(Step_Stress(index_t1:index_t4, 1)./Step_Strain(index_t1:index_t4, 1)); % Use only data from t1 onward
        Modulus_Scaler = max(T_Fit);
        T_Fit=(T_Fit/Modulus_Scaler)*Stress_t1;
        [Yx_23, Yfit_23, exitflag_1] = BT_Phase2_3_Offset(t_Fit, T_Fit, 'initial_p', [ParamGuess; 1]');
        R = corrcoef(T_Fit, Yfit_23);
        R2 = R(1,2)*R(1,2);
        %t_plot_23=t_Fit;
        t_plot_Y23=Step_time(index_t1:end, 1);
        fit_Y23=(Yx_23(1)*exp(-Yx_23(2)*t_plot_Y23))+(Yx_23(3)*(1-exp(-Yx_23(4)*t_plot_Y23)))+Yx_23(5);

        [x_ABC, fit_ABC, exitflag_ABC] = Step_ABC_Time_Fit_v4(t_Fit, T_Fit);
        R= corrcoef(T_Fit, fit_ABC);
        R2_ABC = R(1,2)*R(1,2);


        figure(3)
        subplot(2,2,4)
        plot(Step_time(index_t1:index_t4), Step_Stress(index_t1:index_t4), 'b-'), hold on
        plot(t_Fit, fit_ABC, 'm-')
        text(t2, 0.4*Stress_t1, ['A_T = ' num2str(2*pi*x_ABC(1), '%.1f') ' mN/mm2, k = ' num2str(2*pi*x_ABC(2), '%.2f')])
        text(t2, 0.3*Stress_t1, ['B_T = ' num2str(2*pi*x_ABC(3), '%.1f') ' mN/mm2, 2\pib = ' num2str(2*pi*x_ABC(4), '%.2f')  ' s^{-1}'])
        text(t2, 0.2*Stress_t1, ['C_T = ' num2str(2*pi*x_ABC(5), '%.1f') ' mN/mm2, 2\pic = ' num2str(2*pi*x_ABC(6), '%.2f') ' s^{-1}'])
        text(t2, 0.1*Stress_t1,  ['Step ABC Fit R^2=' num2str(R2_ABC, '%.2f')])
        grid
        title(['ABC Process Fit'])
        xlim([0, StepEnd])
        ylabel('Step Stress (mN mm-2)')

        figure(3)
        set(figure(3), 'Position', [150, 150, pix_per_inch*10, pix_per_inch*8])
        %pause(2)
        % file_num

        %% Cannot figure out how to deal with the varying string lengths with
        % fiber type.  Try to pad a char string to be ...? same length = 5
        % IIa, IId/a, IId, IId/b, IIb, NAN
        in_Fiber_Type = all_data.Fiber_Type{file_num, 1}; %% Grab input string = char array from cell
        switch in_Fiber_Type
            case 'IIa'
                out_Fiber_Type = [in_Fiber_Type '  '];
            case 'IId/a'
                out_Fiber_Type = [in_Fiber_Type];
            case 'IId'
                out_Fiber_Type = [in_Fiber_Type '  '];
            case 'IId/b'
                out_Fiber_Type = [in_Fiber_Type];
            case 'IIb'
                out_Fiber_Type = [in_Fiber_Type '  '];
            case 'I'
                out_Fiber_Type = [in_Fiber_Type '    '];
            otherwise
                out_Fiber_Type = ['NAN  '];
        end

        if(SarcLength==2.7 & strcmp('Cntrl', all_data.Cond{file_num, 1}) ) % SL = 2.7 and Control Fiber
            % Update variables for our analyzed fitted parameters
            StepData_27.Animal_ID = [StepData_27.Animal_ID; all_data.Animal_ID{file_num, 1}];
            StepData_27.Fiber_Num = [StepData_27.Fiber_Num; all_data.Fiber_Num{file_num, 1}];
            StepData_27.Protocol = [StepData_27.Protocol; all_data.Protocol{file_num, 1}];
            %StepData_27.Fiber_Type = [StepData_27.Fiber_Type; all_data.Fiber_Type{file_num, 1}];
            StepData_27.Fiber_Type = [StepData_27.Fiber_Type; out_Fiber_Type];
            StepData_27.Species = [StepData_27.Species; all_data.Species{file_num, 1}];
            StepData_27.Sex = [StepData_27.Sex; all_data.Sex{file_num, 1}];
            StepData_27.Cond = [StepData_27.Cond; all_data.Cond{file_num, 1}];
            StepData_27.SL_um = [StepData_27.SL_um; all_data.SL_um(file_num, 1)];
            StepData_27.ML_Working_mm = [StepData_27.ML_Working_mm; all_data.ML_Working_mm(file_num, 1)];
            StepData_27.Fiber_D_um = [StepData_27.Fiber_D_um; all_data.Fiber_D_um(file_num, 1)];
            StepData_27.Iso_F_mN = [StepData_27.Iso_F_mN; InitialIsometricForce];
            StepData_27.Iso_Stress_mNmm2 = [StepData_27.Iso_Stress_mNmm2; InitialIsometricStress];
            StepData_27.t0 = [StepData_27.t0; t0];
            StepData_27.Stress_t0 = [StepData_27.Stress_t0; Stress_t0];
            StepData_27.t1 = [StepData_27.t1; t1];
            StepData_27.Stress_t1 = [StepData_27.Stress_t1; Stress_t1];
            StepData_27.t12 = [StepData_27.t12; t12];
            StepData_27.Stress_t12 = [StepData_27.Stress_t12; Stress_t12];
            StepData_27.t2 = [StepData_27.t2; t2];
            StepData_27.Stress_t2 = [StepData_27.Stress_t2; Stress_t2];
            StepData_27.t3 = [StepData_27.t3; t3];
            StepData_27.Stress_t3 = [StepData_27.Stress_t3; Stress_t3];
            StepData_27.t4 = [StepData_27.t4; t4];
            StepData_27.Stress_t4 = [StepData_27.Stress_t4; Stress_t4];
            StepData_27.k_t12 = [StepData_27.k_t12; kf_12];
            StepData_27.k_t23 = [StepData_27.k_t23; kf_23];
            StepData_27.k_df = [StepData_27.k_df; kf_df];
            % Now update the time series variables structure
            StepTS_27.Step_time = [StepTS_27.Step_time; Step_time'];
            StepTS_27.Step_Stress = [StepTS_27.Step_Stress; Step_Stress'];
            StepTS_27.Step_Strain = [StepTS_27.Step_Strain; Step_Strain'];

        elseif(SarcLength==2.4 & strcmp('Cntrl', all_data.Cond{file_num, 1}) ) % SL = 2.4 and Control Fiber
            % Update variables for our analyzed fitted parameters
            StepData_24.Animal_ID = [StepData_24.Animal_ID; all_data.Animal_ID{file_num, 1}];
            StepData_24.Fiber_Num = [StepData_24.Fiber_Num; all_data.Fiber_Num{file_num, 1}];
            StepData_24.Protocol = [StepData_24.Protocol; all_data.Protocol{file_num, 1}];
            %StepData_24.Fiber_Type = [StepData_24.Fiber_Type; all_data.Fiber_Type{file_num, 1}];
            StepData_24.Fiber_Type = [StepData_24.Fiber_Type; out_Fiber_Type];
            StepData_24.Species = [StepData_24.Species; all_data.Species{file_num, 1}];
            StepData_24.Sex = [StepData_24.Sex; all_data.Sex{file_num, 1}];
            StepData_24.Cond = [StepData_24.Cond; all_data.Cond{file_num, 1}];
            StepData_24.SL_um = [StepData_24.SL_um; all_data.SL_um(file_num, 1)];
            StepData_24.ML_Working_mm = [StepData_24.ML_Working_mm; all_data.ML_Working_mm(file_num, 1)];
            StepData_24.Fiber_D_um = [StepData_24.Fiber_D_um; all_data.Fiber_D_um(file_num, 1)];
            StepData_24.Iso_F_mN = [StepData_24.Iso_F_mN; InitialIsometricForce];
            StepData_24.Iso_Stress_mNmm2 = [StepData_24.Iso_Stress_mNmm2; InitialIsometricStress];
            StepData_24.t0 = [StepData_24.t0; t0];
            StepData_24.Stress_t0 = [StepData_24.Stress_t0; Stress_t0];
            StepData_24.t1 = [StepData_24.t1; t1];
            StepData_24.Stress_t1 = [StepData_24.Stress_t1; Stress_t1];
            StepData_24.t12 = [StepData_24.t12; t12];
            StepData_24.Stress_t12 = [StepData_24.Stress_t12; Stress_t12];
            StepData_24.t2 = [StepData_24.t2; t2];
            StepData_24.Stress_t2 = [StepData_24.Stress_t2; Stress_t2];
            StepData_24.t3 = [StepData_24.t3; t3];
            StepData_24.Stress_t3 = [StepData_24.Stress_t3; Stress_t3];
            StepData_24.t4 = [StepData_24.t4; t4];
            StepData_24.Stress_t4 = [StepData_24.Stress_t4; Stress_t4];
            StepData_24.k_t12 = [StepData_24.k_t12; kf_12];
            StepData_24.k_t23 = [StepData_24.k_t23; kf_23];
            StepData_24.k_df = [StepData_24.k_df; kf_df];
            % Now update the time series variables structure
            StepTS_24.Step_time = [StepTS_24.Step_time; Step_time'];
            StepTS_24.Step_Stress = [StepTS_24.Step_Stress; Step_Stress'];
            StepTS_24.Step_Strain = [StepTS_24.Step_Strain; Step_Strain'];


        end

        % % Write Out Fit Step Figure for each Run.
        Out_Fig_Dir = [pwd filesep]; %
        Out_Fig2_Name = [fiber_name '_'  int2str(trial_num) '_StepData'];
        Out_Fig3_Name = [fiber_name '_'  int2str(trial_num) '_StepFits'];
        pwd
        % % Write out the figures
        saveas(figure(2), [Out_Fig_Dir Out_Fig2_Name], 'png')
        saveas(figure(2), [Out_Fig_Dir Out_Fig2_Name], 'fig')
        saveas(figure(3), [Out_Fig_Dir Out_Fig3_Name], 'png')
        saveas(figure(3), [Out_Fig_Dir Out_Fig3_Name], 'fig')

    end %if step and SL
% Change Dir backward
    cd ..
end %for

% Change Dir backward
cd ..

pwd

%% Write out workspace
 save('StepSummarySoleus_OLD.mat', "StepData_24", "StepData_27")

% %% Write out each set of data as a table? INdividually or concatenate?
 T = struct2table(StepData_27);
 Out_Data = [pn 'Soleus_OLD_StepFitData27_0OM.xlsx'];
 writetable(T,Out_Data)

 T = struct2table(StepData_24);
 Out_Data = [pn 'Soleus_OLD_StepFitData24_0OM.xlsx'];
 writetable(T,Out_Data)


clf(figure(4))
subplot(2,2,1)
plot(StepTS_24.Step_time', StepTS_24.Step_Stress', '-')
ylabel('Step Stress [mN mm-2]')
xlabel('Time (seconds)')
title('SL = 2.4 um, [OM] = 0 \muM')

subplot(2,2,2)
plot(StepTS_24.Step_time', (StepTS_24.Step_Stress./StepData_24.Stress_t1)', '-')
ylabel('Step Stress/Stress @ t1')
xlabel('Time (seconds)')
title('SL = 2.4 um, [OM] = 0 \muM')

subplot(2,2,3)
plot(StepTS_27.Step_time', StepTS_27.Step_Stress', '-')
ylabel('Step Stress [mN mm-2]')
xlabel('Time (seconds)')
title('SL = 2.7 um, [OM] = 0 \muM')

subplot(2,2,4)
plot(StepTS_27.Step_time', (StepTS_27.Step_Stress./StepData_27.Stress_t1)', '-')
ylabel('Step Stress/Stress @ t1')
xlabel('Time (seconds)')
title('SL = 2.7 um, [OM] = 0 \muM')
% 
% % Write Out Fit Step Figure for each Run.
% Out_Fig_Dir = '';
% Out_Fig_Name = '';
% saveas(gcf, [Out_Fig_Dir Out_Fig_Name], 'png')
% saveas(gcf, [Out_Fig_Dir Out_Fig_Name], 'fig')


