% Read the data from the CSV file containing Anscombe's quartet
Data = readmatrix('anscombe_quartet.csv');

% Preallocate arrays to store regression coefficients and statistics
b = zeros(2,4); % Each column will hold [slope; intercept] for one dataset
stats = zeros(4,4); % Each row will hold regression statistics for one dataset

% Create a new figure window
figure;

% Loop through the four datasets
for i = 1:4
    subplot(2,2,i); % Create a 2x2 grid of subplots and select the i-th subplot
    
    % Extract x and y data for the i-th dataset
    x = Data(:,2*i-1); % x1, x2, x3, x4 are in columns 1, 3, 5, 7
    y = Data(:,2*i); % y1, y2, y3, y4 are in columns 2, 4, 6, 8

    % Plot the data points
    plot(x, y, 'o');
    hold on

    % Add a least squares regression line to the plot
    lsline; 

    % Perform linear regression: y = b1*x + b0
    % The design matrix includes x and a column of ones for the intercept
    [b(:,i), ~, ~, ~, stats(i,:)] = regress(y,[x ones(numel(x),1)]); 

    % Add labels and title to the subplot
    title(['Dataset ' num2str(i)]);
    xlabel('x'); ylabel('y');
end

% Add a super title for the entire figure
sgtitle('Anscombe''s Quartet');