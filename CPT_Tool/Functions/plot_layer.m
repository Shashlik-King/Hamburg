function [Q_tn, F_r, I_c] = plot_layer(z,qt,fs,sigma_v0,sigma_v0_eff,values)
%%%-------------------------------------------------------------------------%%%
% Function for calculating Qtn, Fr and Ic from iteration
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     07-07-2020

sigma_atm = values.P_a;             % Defined atmospheric pressure
F_r = fs./(qt-sigma_v0)*100;        % Calculate Fr [%]

%% Iterate for Q_tn and Ic
%imaginaryCounter = 0;
I_c_end = NaN(length(F_r),1);       % Pre-define Ic vector by NaN
n_end = NaN(length(F_r),1);         % Pre-define n vector by NaN
Q_tn_end = NaN(length(F_r),1);      % Pre-define Qtn vector by NaN
for i = 1:length(F_r)
    if isnan(F_r(i))
        I_c = NaN;
    else
        I_c = 0;
    end
    n = 1.0;
    Q_tn = ((qt(i)-sigma_v0(i))/sigma_atm)*((sigma_atm/sigma_v0_eff(i))^n); % modified by SDNN 15-07-2020
    counter = 0;
    n_delta = 1;
    while n_delta > 0.01
        counter = counter+1;
        if isinf(abs(I_c - (sqrt(((3.47-log10(Q_tn))^2+(1.22+log10(F_r(i)))^2))))) || counter > 10000
            I_c = NaN;
            Q_tn = NaN;
            n = NaN;
            break
        else
            Q_tn = ((qt(i)-sigma_v0(i))/sigma_atm)*((sigma_atm/sigma_v0_eff(i))^n); % modified by SDNN 15-07-2020
            I_c = ((3.47-log10(Q_tn))^2+(1.22+log10(F_r(i)))^2)^0.5;
            n_new = min(0.381*I_c+0.05*(sigma_v0_eff(i)/sigma_atm)-0.15,1.0);
            n_delta = abs(n-n_new);
            n = n_new;
        end
    end
    if imag(I_c) == 0 && imag(Q_tn) == 0 && imag(n) == 0
        I_c_end(i) = I_c;
        n_end(i) = n;
        Q_tn_end(i) = Q_tn;
    else
        I_c_end(i) = NaN;
        n_end(i) = NaN;
        Q_tn_end(i) = NaN;
        %imaginaryCounter = imaginaryCounter+1;
        %imaginaryIndex(imaginaryCounter,1) = i;
    end
end

I_c = I_c_end;
Q_tn = Q_tn_end;
