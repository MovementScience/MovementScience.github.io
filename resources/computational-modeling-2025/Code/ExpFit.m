% Bert Tanner
% Sept. 19, 2003
% Working to use a single exponential to fit a curve of a 
% force prodution with the Ca2filMC code.  Where the asymGuess is the guess
% of the asymtotic F value, and the tGuess is the guess for the kTr value.

% Note, this file fits with xdata as a column and makes a fit across
% each given ydata(a column of ydata) for many columns in ydata.
% Or more to the point--feed it columns.

function [asym, t_half, yfit, nRMS, fit_status] = ExpFit(xdata, ydata, asymGuess, tGuess);
L_of_t=length(xdata)
%ydata=fmean2(:,length(Ca));
[row col dep]=size(ydata)  % Get the size
fun=inline('x(1)*(1-exp(-x(2)*xdata))', 'x', 'xdata');
for(iDep = 1:dep)
    for(nCol = 1:col)
        x=0.0;
        resnorm=0.0;
        residuals=0.0;
        disp('Reset fit options to default')
        options = optimset;
        [x,resnorm,residuals, exitflag] = lsqcurvefit(fun, [asymGuess tGuess], xdata, ydata(:, nCol, iDep),[],[],options);
        % If the exit flag does not reach the convegence, then adjust the
        % number of evaluations in the option structure.
        %if exitflag<1
        while exitflag<1
            disp('  Modifying the MaxFunEvals to 1000 (default 500)')
            OPTIONS = OPTIMSET('MaxFunEvals', 1000);
            %x=0.0;
            resnorm=0.0;
            residuals=0.0;
            disp('Trying to fit again')
            %[x,resnorm,residuals, exitflag] = lsqcurvefit(fun, [asymGuess tGuess], xdata, ydata(:, nCol, iDep),[],[],options);
            [x,resnorm,residuals, exitflag] = lsqcurvefit(fun, [x], xdata, ydata(:, nCol, iDep),[],[],options);
            if exitflag<1
                disp('  A proper fit was not reached')
            end
        end
        asym(1, nCol, iDep)=x(1);  % The asymtotic value in ydata units
        t_half(1, nCol, iDep)=x(2);  % The half asymtotoic value point, in 1/(xdata units), example time:  s^-1
        yfit(:, nCol, iDep)=x(1)*(1-exp(-x(2)*xdata));
        nRMS(1, nCol, iDep)=sqrt(sum(residuals.^2))/(row*asym(1, nCol, iDep)); %normalized RMS of residuals
        fit_status(1, nCol, iDep)=exitflag;
        % Plot some things for trial to look at max Ca level
%                 figure(nCol)
%                 clf
%                 plot(xdata,ydata(:, nCol, iDep),'k-', xdata, yfit(:, nCol, iDep), 'b-');
%                 xlabel('Time (s)')
%                 ylabel('mean F (pN)')
%                 text(xdata(10), ydata(end, nCol, iDep)*1.2, ['Fit: ' num2str(asym(1, nCol, iDep)) '(1 - exp(-t*' num2str(t_half(1, nCol, iDep)) ') )'])
        % title(['Force pCa = 5 regulation, nRuns = ' num2str(nRuns) ', TwofilMC.m ' date])
        % saveas(gcf,'C:\Documents and Settings\danielab\Desktop\Bert\Twofil_Figs\Ca2fil_F_pCa5','fig');
        % saveas(gcf,'C:\Documents and Settings\danielab\Desktop\Bert\Twofil_Figs\Ca2fil_F_pCa5','jpg');
        
    end
end
