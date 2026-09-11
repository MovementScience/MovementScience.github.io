% Imagine that we are simulating an experiment to test the effects of a new
% supplement to increase long-jump performance in Olympic male athletes.
% What is this magic supplement? Well, it's water. One ounce of plain tap
% water to be precise.
%
% This is an extreme example of an experiment where we expect the null
% hypothesis to be true. Below, we will use a set of simulations to
% understand the range of results we would expect if many labs tested the
% effect of our magic supplement. 

% Population parameters when the null hypothesis is true. In reality, we
% almost never know the true population parameters, but we do in
% simulation. The parameters below represent the mean and standard
% deviation of long jump performance if we split all Olympic long jumpers
% into Test and Control groups. Our Test group takes the
% supplement, but our Control group does not.
Mean_Control = 8; 
SD_Control = 0.2;

Mean_Test = 8;
SD_Test = 0.2;

% Sample size for simulated experiments
Samp_Size = 100;
N_Experiments = 1000;

% Initialize vector to store effect sizes and p-values
p = zeros(N_Experiments,1);

% Simulate experiments and conduct statistical analysis
for Expt_Num = 1:N_Experiments
    
    % Sample from the population
    Control = SD_Control*randn(Samp_Size,1) + Mean_Control;
    Test = SD_Test*randn(Samp_Size,1) + Mean_Test;
    
    % Perform inferential statistics using a t-test
    [~, p(Expt_Num)] = ttest(Control,Test);
end

% Plot
figure;
histogram(p);
title('Distribution of P-Values When Null Hypothesis is True');
xlabel('P-value'); 

% Fraction of virtual experiments with p < 0.05
False_Pos_Rate = sum(p < 0.05)/N_Experiments
