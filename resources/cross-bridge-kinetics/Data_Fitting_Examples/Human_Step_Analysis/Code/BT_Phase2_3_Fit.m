%% BCWT, Jan 18, 2010
%% Bring in time and stress data
%% dedicated to fitting the phase 2 and phase 3 responses
%% where zero time will be the time forward from Phase 1 ends
%% at max force.
%function [x, RESNORM, RESIDUAL, EXITFLAG] = A_Proc_Phase2_3_Fit(t, Force, x)

function [best_p, StepForce_Fit, exit_flag] = BT_Phase2_3_Fit(varargin)

% Handle inputs
params = inputParser;
addRequired(params,'time');
addRequired(params,'force');
addOptional(params,'scaling_vector',[1 10 1 1]);
addOptional(params,'initial_p',[1 1 1 1]);
addOptional(params,'lower_bounds',zeros(1,4));
addOptional(params,'upper_bounds',1e3*ones(1,4));
addOptional(params,'figure_number',0);
parse(params,varargin{:})
params = params.Results;

% Code
expt_data.t = params.time;
expt_data.F = params.force;

%disp(['Initial Guess = '])
%params.initial_p

[best_p, feval, exit_flag] = fminsearchbnd( ...
    @return_StepForce_fit, ...
    params.initial_p, ...
    params.lower_bounds,params.upper_bounds, ...
    optimset('MaxFunEvals',15000), ...
    expt_data, ...
    params.scaling_vector, ...
    0);

for in_exit=1:10
    if  exit_flag == 0

        [best_p, feval, exit_flag] = fminsearchbnd( ...
            @return_StepForce_fit, ...
            best_p, ...
            params.lower_bounds,params.upper_bounds, ...
            optimset('MaxFunEvals',15000), ...
            expt_data, ...
            params.scaling_vector, ...
            0);
    end
end

%disp(['feval = ' num2str(feval)])
%disp(['exit flag = ' num2str(exit_flag)])

%% Get the time-series force data that was best fit
StepForce_Fit = return_StepForce_values(best_p, expt_data.t, params.scaling_vector);


%plot_fit(params.figure_number, expt_data, [], best_p, params.scaling_vector);

% Store for output
best_p = best_p .* params.scaling_vector;

end

function StepForce_Fit = return_StepForce_values(p, time, scaling_vector)

x_data = time;

p = p.*scaling_vector;

StepForce_Fit = ...
    (p(1)*exp(-p(2)*x_data))+...
    (p(3)*(1-exp(-p(4)*x_data))); % (p(3)*(1-exp(-p(4)*x_data)));
 
% Store for fit to Frequency Component for ABC process
% StepForce_values = ...
%     p(1) * (x_data .^ p(2)) - ...
%     p(3) * (x_data ./ (2*pi*p(4) + x_data)) + ...
%     p(5) * (x_data ./ (2*pi*p(6) + x_data));
end

function error_value = return_StepForce_fit(p, expt_data, scaling_vector, figure_display)

% Calculate StepForce_values
StepForce_Fit = return_StepForce_values(p, expt_data.t, scaling_vector);

% Split into elastic and viscous components
fit_data = StepForce_Fit;


% Calculate sum of squares
error_value = ...
    sum((fit_data - expt_data.F).^2); 

% Display if required
if (figure_display)
    plot_fit(figure_display, expt_data, fit_data);
end

end

function plot_fit(figure_display, expt_data, fit_data, p, scaling_vector)

figure(figure_display);
cla;
hold on;
plot(expt_data.t, expt_data.F,'k^');

if (isempty(fit_data))
    % Calculate StepForce_values
    StepForce_values = return_StepForce_values(p,expt_data.t, scaling_vector);
    % Split into elastic and viscous components
    fit_data = StepForce_values;
end

plot(expt_data.t, fit_data,'bo-');
%     for i=1:numel(fit_data.elastic_mod)
%         plot([fit_data.elastic_mod(i) expt_data.elastic_mod(i)], ...
%             [fit_data.viscous_mod(i) expt_data.viscous_mod(i)],'r-');
%     end
end


