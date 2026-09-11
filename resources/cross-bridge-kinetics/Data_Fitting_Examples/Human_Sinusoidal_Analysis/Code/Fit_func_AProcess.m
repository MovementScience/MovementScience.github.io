function [ func_out ] = Fit_func_AProcess( x )

    %% Process the fitting
    %% Complex_Modulus= A*((i*w).^k) - B*((i*w)./(2*pi*b +(j*w) )) + C*((j*w)./(2*pi*c +(j*w) ));
    %% Set guess for A, k, B, b, C, c as an array
    %% here A=x(1), k=x(2), B=(x3), b=x(4), C=x(5), c=x(6)

global x_dat;
global y_dat;


y_fit =    x(1) * ( x_dat .^ x(2) );

     % For vectors...
     % NORM(V,P) = sum(abs(V).^P)^(1/P), but when a single vector
     % as we use here, NORM(V) = norm(V,2).
     % so we are minimizing the sum squared of the residuals
     % by calculating Euclidean Distance between y_fit and y_dat
func_out = norm( real(y_fit) - real(y_dat) )...         
         + norm( imag(y_fit) - imag(y_dat) );

end

