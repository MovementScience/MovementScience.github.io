%% BCWT; March. 16, 2011

%% Bring in the raw frequency and Complex Modulus values.  Down sample it
%% given N_AVG.  Then, fit the data and write out the files for each fiber
%% yeah boyeee.  Also write the fits and data to a fig for each file.
%% 
%% BCWT, Modify on October 20, 2011
%% Modify to output the ATP as well as pCa and Pi in header.
%% Also modify to fit to a passive/rigor fit if pCa <= 8.0 or ATP <= 0.01 mM
%%
%% This file (Export_MSNtoABC_XLD_v1.m) is modified from Export_GWNtoABC_XLD_Downsample_v4.m
%% To simply bring in an MSN run, correct it, fit it with the ABC model
%% and write the corrected XLD file out and the ABC model parameters.
function Export_MSNorGWNtoABC_XLD_Cardiac_Human_S2(Corr_File_Path, Corr_File_Name, FigHand1, FigHand2, First, FileTags, Quality, VarNames)

DataDir=FileTags{1, 1};
FileNameBase=FileTags{1, 2};
Run=FileTags{1, 3};
fs=FileTags{1, 4};
fc=FileTags{1, 5};
duration = FileTags{1, 9};
FittingFunc=FileTags{1, 10};
Var1=FileTags{1, 11};
Var2=FileTags{1, 12};
Var3=FileTags{1, 13};
Series=FileTags{1, 14};
pCa=FileTags{1, 15};
Pi=FileTags{1, 16};
ATP=FileTags{1,17};


%Mod guesses and bounds here. This is only place this needs to be done
% A, k, B, b, C, c
ParamGuess=[200; 0.2; 100; 2; 200; 10]; %% Skeletal Mod -AJF June 22, 2015
LowerBounds = [0; 0; 0; 0; 0; 0];
UpperBounds=[1000; 1; 5000; 12; 5000; 30];


global x_dat;   %Fitting function needs access                   
global y_dat; 
    
    
if Series == 1  %Process Multisine (MSN)

    % Grab the f, Em, and Vm for a given run:
    [f, Em, Vm] = Import_MSN_Run_EmVm_v1(DataDir, FileNameBase, Run);

    % %% MOD HERE to adjust for Blown Area Entry/Calculation
    % Area1=1;
    % Area2=9;
    % Em=Em*(Area1/Area2);
    % Vm=Vm*(Area1/Area2);

    % Write the data for the EM nad VM data to the extention of an
    % MSN file--append using header from above file 'In_MSN'
    Out_XLD_Path=[DataDir filesep FileNameBase '_XLD_MSN.txt'];
    Out_ABC_Path=[DataDir filesep FileNameBase '_ABC_MSN.txt'];

    %% Out figure for the fit and the Run
    OutFigFile=[FileNameBase '_Corr_Run_' num2str(Run) '.fig'];
    Out_Fig=[DataDir filesep 'GWN_Processed' filesep OutFigFile];


    %% Unpack the data from the import--these are raw, uncorrected values
%     if f(end,end)==250
%          i200=find(f==200);
%          f_raw=f(1:i200, 1);
%          Em_raw=Em(1:i200, 1);
%          Vm_raw=Vm(1:i200, 1);
%     else
    f_raw=f;
    Em_raw=Em;
    Vm_raw=Vm;
%     end


    %% Build the Correction filename and import the correction file
    Corr_File=[Corr_File_Path Corr_File_Name];
    data=importdata(Corr_File);

    % Here the system error will be brought in as
    % data(1:3)=with each col being freq, Em_Corr, Vm_Corr
    % So from the analysis data--we take the Em and Vm from the correction file
    % and Normalize this to the 0 frequency value
    Correction_MSN=complex(data.data(:,2), data.data(:,3))/abs(complex(data.data(1,2), data.data(1,3)));
    % Theoretically, the adjustment should all come in the Vm, not any in the
    % Em--so the Em should be 1 and the Vm should be a constant
    % phase shift, or a straight line in the Vm frequency domain.
    %% Fit the line for the Vm with polynomial (frequency, Vm)
    P=polyfit(data.data(:,1), imag(Correction_MSN), 1)
    %% Now, rebuild the actuall correction at each known frequency for
    %% Em=1 and Vm= polyfit
    Correction=complex(ones(size(f_raw)), polyval(P, f_raw));
    %% Apply the correction:
    Comp_Mod=complex(Em_raw, Vm_raw)./Correction;



    %% Do the fitting.  Pass in frequency, Complex Modulus
    % returns x(row vector):
    % A, k, B, b, C, c, t_on, R^2, ExitFlag
    if ((pCa >= 8.0) || (ATP <= 0.001)) %% MOD on May 18, 2014
        [Fit_Params] = NyqFit_Passive_Generic(f_raw, Comp_Mod,ParamGuess,LowerBounds,UpperBounds);
        x_dat=2*pi*1i*f_raw;
        x=Fit_Params(1,1:2)';
        Y_Fit = x(1,1)*(x_dat.^x(2,1));
    else     
        %% 1) Initially Process the A-Process only
        [Fit_Params] = NyqFit_Passive_Generic(f_raw, Comp_Mod,ParamGuess,LowerBounds,UpperBounds);


        %% 2)Now process the B and C Processes only, with the A-Process Fixed

        i=find(f_raw<250);   % Frequency cut-off
        f_temp=f_raw(i(1:end), 1);
        Comp_Mod_temp=Comp_Mod(i(1:end), 1);
        x_dat = 2*pi*1i*f_temp;             
        y_dat = Comp_Mod_temp;              

         x=ParamGuess(3:6); % Fit to just BbCc
    %     [x,fval,exitflag] = fmincon( @Fit_func_BCProcesses  , x , [],[],[],[],LowerBounds(3:6),UpperBounds(3:6),[],[], Fit_Params(1,1), Fit_Params(1,2) );
    %     
    %     while exitflag==0  % Exit flag of 0 = not enough default iterations to reach a min
    %         [x,fval,exitflag] = fmincon( @Fit_func_BCProcesses  , x , [],[],[],[],LowerBounds(3:6),UpperBounds(3:6),[],[], Fit_Params(1,1), Fit_Params(1,2) );
    %     end
        x=[Fit_Params(1,1); Fit_Params(1,2); x]; %Repack x


        %% 3)Process the fitting for all 6 paramaters

        [x,fval,exitflag] = fmincon( @Fit_func_ABC  , x , [],[],[],[],LowerBounds,UpperBounds,[],[]);
        while exitflag==0
            [x,fval,exitflag] = fmincon( @Fit_func_ABC  , x , [],[],[],[],LowerBounds,UpperBounds,[],[]);
        end


        %% Calculate the residual
        % Check the fit to plot
        x_dat=2*pi*1i*f_raw;
        Y_Fit = x(1,1)*(x_dat.^x(2,1))-x(3,1)*(x_dat./(2*pi*x(4,1) +x_dat))+x(5,1)*(x_dat./(2*pi*x(6,1) + x_dat));
        % calculate corrcoeff (R--not R2)
        R=corrcoef([real(Comp_Mod); imag(Comp_Mod)], [real(Y_Fit); imag(Y_Fit)]);

        %% Recast into a row vector
        % x, R^2, t_on (ms), exitflag
        Fit_Params=[x; R(2,1)^2; 1000/(2*pi*x(6,1)); exitflag]';

        x_dat=2*pi*1i*f_raw;
        x=Fit_Params(1,1:6)';
        Y_Fit = x(1,1)*(x_dat.^x(2,1))-x(3,1)*(x_dat./(2*pi*x(4,1) +x_dat))+x(5,1)*(x_dat./(2*pi*x(6,1) + x_dat));
    end

elseif Series == 2 %Process Noise (GWN)

    FileName=[FileNameBase '_GWN_Run_' num2str(Run) '.txt'];
    OutFigFile=[FileNameBase '_Corr_Run_' num2str(Run) '.fig'];


    % Write the GWN data for the EM nad VM data to the extention of an
    % MSN file--append using header from above file 'In_MSN'
    Out_XLD_Path=[DataDir filesep FileNameBase '_XLD_GWN.txt'];
    Out_ABC_Path=[DataDir filesep FileNameBase '_ABC_GWN.txt'];

    % Modify HERE for GWN_Processed, grabbing the run to pull
    % Only write out the file up to the content that we hold
    In_File_Run=[DataDir filesep 'GWN_Processed' filesep FileName];
    Out_Fig=[DataDir filesep 'GWN_Processed' filesep OutFigFile];

    %% Raw Length of File will be f_sample*duration (Hz*sec)
    %% for us this is 200,000 points--but we only have content up to
    %% 250 Hz, sampled at 5 kHz, data every 1/40 Hz (40 pts per Hz).
    %% So we only need to import/keep track of data up to
    %% f_cutoff*duration
    Length_Raw=fs*duration;
    Length_Content=fc*duration;

    data=importdata(In_File_Run);
    data_1=[ data(1:Length_Content, 1), data(1:Length_Content, 2), data(1:Length_Content, 3)];

    f_test=[
    %0.2:0.2:4, ...
    %0.2, 0.5, 1, 1.5, 2, ...
    0.05, 0.125, 0.25, 0.5, 0.75, 0.9, 1, 1.2, 1.4, 1.6, 1.8, 2, 2.25, ...
    2.5:0.25:4, ...
    4.5:0.5:10, ...
    11:1:20, ...
    22:2:40, ...
    45:3:57, ...
    65:5:130, ...
    180:10:250]';  %8/8/17


    f_index_temp=zeros(size(f_test));
    for i=1:length(f_test)
    [val, index]=min(abs(data_1(:,1)-f_test(i, 1)));
        f_index_temp(i,1)=index;
    end
    %% Calculate lower and upper indices based on the frequency separation
    bound_for_mean=[ceil((f_index_temp+1)-[diff(f_index_temp)/2; 0]), floor((f_index_temp)+[diff(f_index_temp)/2; 0])];

    %% Stuff all the means into our data set for fitting, except for the final
    %% at 250, as 245 Hz will be soon and good enough.
    f_raw=zeros(length(f_test)-1, 1);
    Em_raw=zeros(length(f_test)-1, 1);
    Vm_raw=zeros(length(f_test)-1, 1);
    for i=1:(length(f_test)-1) %% Loop over all but last one, for averaging
        f_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),1));
        %Em_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),2));
        %if f_test(i)<0.5
        if f_test(i)<=0.5
        Vm_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),3))/1;  %Divide by ten to control first few points 
        Em_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),2))/1;
        else
            Vm_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),3));
            Em_raw(i, 1)=mean(data_1(bound_for_mean(i, 1):bound_for_mean(i,2),2));
        end
    end
    display('Data Out')
    %[f_raw, Em_raw, Vm_raw] %% Check our data
    %Throw out lowest frequency
    f_raw=f_raw(3:end,:);    %MOD 8/9/17 
    Em_raw=Em_raw(3:end,:);
    Vm_raw=Vm_raw(3:end,:);

    %% Build the Correction filename and import the correction file
    Corr_File=[Corr_File_Path Corr_File_Name];
    data=importdata(Corr_File);

    % Here the system error will be brought in as
    % data(1:3)=with each col being freq, Em_Corr, Vm_Corr
    % So from the analysis data--we take the Em and Vm from the correction file
    % and Normalize this to the 0 frequency value
    Correction_MSN=complex(data.data(:,2), data.data(:,3))/abs(complex(data.data(1,2), data.data(1,3)));
    % Theoretically, the adjustment should all come in the Vm, not any in the
    % Em--so the Em should be 1 and the Vm should be a constant
    % phase shift, or a straight line in the Vm frequency domain.
    %% Fit the line for the Vm with polynomial (frequency, Vm)
    P=polyfit(data.data(:,1), imag(Correction_MSN), 1)
    %% Now, rebuild the actuall correction at each known frequency for
    %% Em=1 and Vm= polyfit
    Correction=complex(ones(size(f_raw)), polyval(P, f_raw));
    %% Apply the correction:
    Comp_Mod=complex(Em_raw, Vm_raw)./Correction;

    % %% ADD ON SOME FREQ and EM and VM INFO: (BERT MOD, May 12 2015)
    % f_add=[110; 130; 160; 190; 220; 250];
    % f_raw=[f_raw; f_add];
    % %P=polyfit(f_raw(end-3,1), Em_raw(end-3,1), 1); %% Polyfit on slope
    % %Em_new=polyval(P, f_add);
    % %Em_raw=[Em_raw; Em_new]; %% ADD Em as slope
    % Em_raw=[Em_raw; Em_raw(end,1)*ones(size(f_add))];
    % Vm_raw=[Vm_raw; Vm_raw(end,1)*ones(size(f_add))]; %% ADD Vm as flat
    % Comp_Mod=complex(Em_raw, Vm_raw);


    %% Do the fitting.  Pass in frequency, Complex Modulus
    % returns x(row vector):
    % A, k, B, b, C, c, t_on, R^2, ExitFlag
    if ((pCa >= 8.0) || (ATP <= 0.001)) %% MOD on May 18, 2014
        [Fit_Params] = NyqFit_Passive_Generic(f_raw, Comp_Mod,ParamGuess,LowerBounds,UpperBounds);
        x_dat=2*pi*1i*f_raw;
        x=Fit_Params(1,1:2)';
        Y_Fit = x(1,1)*(x_dat.^x(2,1));
    else     
        %% 1) Initially Process the A-Process only
        [Fit_Params] = NyqFit_Passive_Generic(f_raw, Comp_Mod,ParamGuess,LowerBounds,UpperBounds);


        %% 2)Now process the B and C Processes only, with the A-Process Fixed

        i=find(f_raw<250);   % Frequency cut-off
        f_temp=f_raw(i(1:end), 1);
        Comp_Mod_temp=Comp_Mod(i(1:end), 1);
        x_dat = 2*pi*1i*f_temp;             
        y_dat = Comp_Mod_temp;              

        x=ParamGuess(3:6); % Fit to just BbCc
        [x,fval,exitflag] = fmincon( @Fit_func_BCProcesses  , x , [],[],[],[],LowerBounds(3:6),UpperBounds(3:6),[],[], Fit_Params(1,1), Fit_Params(1,2) );

        while exitflag==0  % Exit flag of 0 = not enough default iterations to reach a min
            [x,fval,exitflag] = fmincon( @Fit_func_BCProcesses  , x , [],[],[],[],LowerBounds(3:6),UpperBounds(3:6),[],[], Fit_Params(1,1), Fit_Params(1,2) );
        end
        x=[Fit_Params(1,1); Fit_Params(1,2); x]; %Repack x


        %% 3)Process the fitting for all 6 paramaters

        [x,fval,exitflag] = fmincon( @Fit_func_ABC  , x , [],[],[],[],LowerBounds,UpperBounds,[],[]);
        while exitflag==0
            [x,fval,exitflag] = fmincon( @Fit_func_ABC  , x , [],[],[],[],LowerBounds,UpperBounds,[],[]);
        end


        %% Calculate the residual
        % Check the fit to plot
        x_dat=2*pi*1i*f_raw;
        Y_Fit = x(1,1)*(x_dat.^x(2,1))-x(3,1)*(x_dat./(2*pi*x(4,1) +x_dat))+x(5,1)*(x_dat./(2*pi*x(6,1) + x_dat));
        % calculate corrcoeff (R--not R2)
        R=corrcoef([real(Comp_Mod); imag(Comp_Mod)], [real(Y_Fit); imag(Y_Fit)]);

        %% Recast into a row vector
        % x, R^2, t_on (ms), exitflag
        Fit_Params=[x; R(2,1)^2; 1000/(2*pi*x(6,1)); exitflag]';

        x_dat=2*pi*1i*f_raw;
        x=Fit_Params(1,1:6)';
        Y_Fit = x(1,1)*(x_dat.^x(2,1))-x(3,1)*(x_dat./(2*pi*x(4,1) +x_dat))+x(5,1)*(x_dat./(2*pi*x(6,1) + x_dat));
    end

else
    disp(' Error in Export_MSNorGWNtoABC_XLD_Cardiac_Human_S2.m: Series must be 1 or 2 ')
end
    

LegendFontSize=10;
AxisFontSize=12;
MarkerType = 'ko';

clf(figure(FigHand1))
subplot(2,1,1)
semilogx(f_raw, real(Comp_Mod), 'b.'), hold on
semilogx(f_raw, real(Y_Fit), 'k-'), hold on
legend('Corr', 'Fit', 'Location', 'SouthEast')
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('Elastic Modulus (kPa)', 'FontSize', AxisFontSize)
xlabel('Frequency (Hz)', 'FontSize', AxisFontSize)
title(['XLD Fit for Fiber: ' FileNameBase ', Run ' num2str(Run)], 'FontSize', AxisFontSize)
%xlim([0.1, fc]) (BERT MOD, May 12 2015)
%ylim([-0,1])

subplot(2,1,2)
semilogx(f_raw, imag(Comp_Mod), 'b.'), hold on
semilogx(f_raw, imag(Y_Fit), 'k-'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('Viscous Modulus (kPa)', 'FontSize', AxisFontSize)
xlabel('Frequency (Hz)', 'FontSize', AxisFontSize)
title('Downsampled', 'FontSize', AxisFontSize)
%xlim([0.1, fc]) (BERT MOD, May 12 2015)
%xlim([-250, fc])

%% Write this figure out to the storage directory:
%% this will show the corrected data and the fit for Em(f) and Vm(f)
saveas(FigHand1, Out_Fig)

figure(FigHand2)
subplot(3,2,1)
plot(Run, Fit_Params(1,1), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('A (kPa)', 'FontSize', AxisFontSize)
title('ABC Parameters', 'FontSize', AxisFontSize)

subplot(3,2,2)
plot(Run, Fit_Params(1,2), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('k', 'FontSize', AxisFontSize)
title(['Fiber: ' FileNameBase], 'FontSize', AxisFontSize)

subplot(3,2,3)
plot(Run, Fit_Params(1,3), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('B (kPa)', 'FontSize', AxisFontSize)

subplot(3,2,4)
plot(Run, Fit_Params(1,4), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('b (Hz)', 'FontSize', AxisFontSize)

subplot(3,2,5)
plot(Run, Fit_Params(1,5), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('C (kPa)', 'FontSize', AxisFontSize)
xlabel('Run Num.', 'FontSize', AxisFontSize)

subplot(3,2,6)
plot(Run, Fit_Params(1,6), MarkerType, 'markerfacecolor', 'k'), hold on
set(gca, 'box', 'off')
set(gca, 'FontSize', LegendFontSize)
ylabel('c (Hz)', 'FontSize', AxisFontSize)
xlabel('Run Num.', 'FontSize', AxisFontSize)

%return
%% Write XLD File:
% Open the file, with 'append' permissions
fid=fopen(Out_XLD_Path, 'a+');
if(First) %% Write header if this is the first entry
    %% Build Generic header
    Header=sprintf('%s\t', 'Filename', 'CorrFile', 'FittingFunc', 'Run', VarNames{1}, VarNames{2}, VarNames{3}, 'Series', 'pCa', 'Pi (mM)', 'ATP (mM)', 'Freq (Hz)', 'Em (kPa)', 'Vm (kPa)', 'Em Fit', 'Vm Fit', 'Quality');
    % Because header is specified only write it once only
    fprintf(fid, [Header '\n'] );
end
%% Now write XLD data:
%% Build Generic numerical format string:
OutXLDData=[Series*ones(size(f_raw)), pCa*ones(size(f_raw)), Pi*ones(size(f_raw)), ATP*ones(size(f_raw)), f_raw, real(Comp_Mod), imag(Comp_Mod), real(Y_Fit), imag(Y_Fit), Quality*ones(size(f_raw))];
[rowH, colH]=size(OutXLDData);
FormatString=[];
for i=1:colH-1
    FormatString=[FormatString, '%6.4f\t'];
end
FormatString=[FormatString, '%6.4f\n'];

for i=1:rowH
    % Write Fiber Name, Correction File, Run#, then ABC data
    fprintf(fid, [FileNameBase '\t' Corr_File_Name '\t' FittingFunc '\t' ...
    num2str(Run) '\t' Var1 '\t' Var2 '\t' Var3 '\t']);
    % write the numeric values to the output file
    fprintf(fid, FormatString, OutXLDData(i,:)');
end
fclose(fid);


%% Write ABC File:
% Open the file, with 'append' permissions
fid=fopen(Out_ABC_Path, 'a+');
if(First) %% Write header if this is the first entry
    %% Build Generic header
    Header=sprintf('%s\t', 'Filename', 'CorrFile', 'FittingFunc', 'Run', VarNames{1}, VarNames{2}, VarNames{3}, 'Series', 'pCa', 'Pi (mM)', 'ATP (mM)', 'A (kPa)', 'k', 'B (kPa)', 'b (Hz)', 'C (kPa)', 'c (Hz)', 'R2', 't_on (ms)', 'ExitFlag', 'Quality');
    % Because header is specified only write it once only
    fprintf(fid, [Header '\n'] );
end

%% Now write ABC data:
%% Build Generic numerical format string:
OutABCData=[Series, pCa, Pi, ATP, Fit_Params, Quality]
[rowH, colH]=size(OutABCData);
FormatString=[];
for i=1:colH-1
    FormatString=[FormatString, '%6.4f\t'];
end
FormatString=[FormatString, '%6.4f\n'];

% Write Fiber Name, Correction File, Run#, then ABC data
fprintf(fid, [FileNameBase '\t' Corr_File_Name '\t' FittingFunc '\t' ...
    num2str(Run) '\t' Var1 '\t' Var2 '\t' Var3 '\t']);
% write the numeric values to the output file
fprintf(fid, FormatString, OutABCData');
fclose(fid);    

