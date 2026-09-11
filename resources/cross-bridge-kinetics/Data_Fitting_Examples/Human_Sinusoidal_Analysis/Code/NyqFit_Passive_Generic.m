%% BCWT Jan 25, 2010
%% Use this to take in a frequency and complex modulus
%% pass this to the ABC fitting
%% then return the parameters, ton (ms), residual^2, exit flag

function [x_out] = NyqFit_Passive_Generic(f, Comp_Mod,ParamGuess,LowerBounds,UpperBounds)

    %% Process the fitting
    % Complex_Modulus= A*((i*w).^k) - B*((i*w)./(2*pi*b +(j*w) )) + C*((j*w)./(2*pi*c +(j*w) ));
% Set guess for A, K, B, b, C, c as an array
% ParamGuess=[200; 0.2];
% ParamGuess=[200; 0.1]; %Skeletal Mod -AJF 6-22-2015

global x_dat;                       % It is not possible to send multiple input arguments when
global y_dat;                       % the function Fit_func is passed as an argument to the fminunc function.
x_dat = 2*pi*1i*f;               % Hence, x_dat and y_dat are declared
y_dat = Comp_Mod;                   % as global so that Fit_func can access them.

x=ParamGuess(1:2);  %ParamGuess for passive

[x,fval,exitflag] = fmincon( @Fit_func_AProcess, x , [],[],[],[],LowerBounds(1:2),UpperBounds(1:2),[],[] );
        
    %% Exit flag of 0 = not enough default iterations to reach a min
    while exitflag==0
        [x,fval,exitflag] = fmincon( @Fit_func_AProcess, x , [],[],[],[],LowerBounds(1:2),UpperBounds(1:2),[],[] );
    end
    
 
    %% Calculate the residual
    %% Check the fit to plot
x_dat=2*pi*1i*f;
Y_Fit = x(1,1)*(x_dat.^x(2,1));
% calculate corrcoeff (R--not R2)
R=corrcoef([real(Comp_Mod); imag(Comp_Mod)], [real(Y_Fit); imag(Y_Fit)]);

%% Double check we are calculating norms right
% fval_test = norm( real(Y_Fit) - real(Comp_Mod) )...         
%          + norm( imag(Y_Fit) - imag(Comp_Mod) )

    %% Recast into a row vector
    %% x, R^2, t_on (ms), exitflag
x_out=[x; zeros(4,1); R(2,1)^2; 0; exitflag]';

