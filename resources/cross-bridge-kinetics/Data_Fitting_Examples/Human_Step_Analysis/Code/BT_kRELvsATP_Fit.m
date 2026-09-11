%% BCWT, Dec. 1 2022
%% Bring in ATP and k_rel data
%% Fit to the following fucntion:
%% k_rel(ATP)=kADP_release*MgATP/((kADP_release/kATP_binding) + MgATP)



function [best_p, rateATP_Fit, exit_flag] = BT_kRELvsATP_Fit(varargin)

% Handle inputs
params = inputParser;
addRequired(params,'ATP');
addRequired(params,'k_rel');
addOptional(params,'scaling_vector',[10 100]);
addOptional(params,'initial_p',[1 1]);
%addOptional(params,'initial_p',[0.1 1.5 0.2 3 0.5 1.2]);
addOptional(params,'lower_bounds',zeros(1,2));
%addOptional(params,'lower_bounds',[10 0 100 0.1 100 1]);
addOptional(params,'upper_bounds',inf*ones(1,2));
%addOptional(params,'upper_bounds',[inf 1 inf 10 inf 100]);
addOptional(params,'figure_number',0);
parse(params,varargin{:})
params = params.Results;

% Code
expt_data.x = params.ATP;
expt_data.y = params.k_rel;



%disp(['Initial Guess = '])
%params.initial_p

[best_p, feval, exit_flag] = fminsearchbnd( ...
    @return_rateATP_Fit, ...
    params.initial_p, ...
    params.lower_bounds,params.upper_bounds, ...
    optimset('MaxFunEvals',15000), ...
    expt_data, ...
    params.scaling_vector, ...
    0);

for in_exit=1:10
    if  exit_flag == 0

        [best_p, feval, exit_flag] = fminsearchbnd( ...
            @return_rateATP_Fit, ...
            best_p, ...
            params.lower_bounds,params.upper_bounds, ...
            optimset('MaxFunEvals',15000), ...
            expt_data, ...
            params.scaling_vector, ...
            0);
    end
end

disp(['feval = ' num2str(feval)])
disp(['exit flag = ' num2str(exit_flag)])

%% Get the k_rel vs. ATP curve thta was best fit
rateATP_Fit = return_Stepk_rel_values(best_p, expt_data.x, params.scaling_vector);


plot_fit(params.figure_number, expt_data, [], best_p, params.scaling_vector);

% Store for output
best_p = best_p .* params.scaling_vector;

end

function rateATP_Fit = return_Stepk_rel_values(p, ATP, scaling_vector)

x_data = ATP;

p = p.*scaling_vector;

%k_rel=kADP_release*MgATP/((kADP_release/kATP_binding) + MgATP)
rateATP_Fit = ...
    p(1)*ATP./((p(1)/p(2)) + ATP);

end

function error_value = return_rateATP_Fit(p, expt_data, scaling_vector, figure_display)

% Calculate Stepk_rel_values
rateATP_Fit = return_Stepk_rel_values(p, expt_data.x, scaling_vector);

% Split into elastic and viscous components
fit_data = rateATP_Fit;


% Calculate sum of squares
error_value = ...
    sum((fit_data - expt_data.y).^2); 

% Display if required
if (figure_display)
    plot_fit(figure_display, expt_data, fit_data);
end

end

function plot_fit(figure_display, expt_data, fit_data, p, scaling_vector)

figure(figure_display);
cla;
hold on;
plot(expt_data.x, expt_data.y,'k^');

if (isempty(fit_data))
    % Calculate Stepk_rel_values
    Stepk_rel_values = return_Stepk_rel_values(p,expt_data.x, scaling_vector);
    % Split into elastic and viscous components
    fit_data = Stepk_rel_values;
end

plot(expt_data.x, fit_data,'bo-');
%     for i=1:numel(fit_data.elastic_mod)
%         plot([fit_data.elastic_mod(i) expt_data.elastic_mod(i)], ...
%             [fit_data.viscous_mod(i) expt_data.viscous_mod(i)],'r-');
%     end
end


