function data = postCalculation(settings,data,values)
%%%-------------------------------------------------------------------------%%%
% Function for performing post-processing calculations for determine
% further parameters if needed and compare calculated parameters to
% received parameters if any double information is found
%
% If any new post-processed parameters are added to this function please
% also add this in the "ParametersFunction" vector
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     08-07-2020




ParametersFunction = [{'u0'},{'delta_u'},{'qt'},{'Rf'},{'sigma_v0'},{'sigma_v0_eff'},{'Qt'},{'Qtn'},{'Bq'},{'Fr'},{'Ic'}];

pos = fieldnames(data.postprocess);
for i = 1:length(pos)    % Looping over all locations where data is defined
    IDi = pos{i};
    for j = 1:length(data.postprocess.(IDi).LOCA_ID)
        if ~isnan(data.postprocess.(IDi).CPTavail(j))
            IDj = strcat('SCPT',num2str(j));
            IDj_G = strcat('SCPG',num2str(j));
            dat = data.postprocess.(IDi).(IDj);
            
            %% Define Cone Area Ratio (CAR) in the SCPT structure
            dat.CAR = nan(length(dat.z),1);
            dat.pushIndex = nan(length(data.postprocess.(IDi).(IDj_G).push),2);
            for k = 1:length(data.postprocess.(IDi).(IDj_G).push)
                idx = strcmp(dat.pushNo,data.postprocess.(IDi).(IDj_G).push{k});
                dat.CAR(idx) = data.postprocess.(IDi).(IDj_G).CAR(k);
                
                pStart = find(idx,1,'first');
                pEnd = find(idx,1,'last');
                dat.pushIndex(k,:) = [pStart, pEnd];
            end
            
            %% Post-processing (calculate standard definitions for usage in post-processing)
            newParameter.u0 = dat.z.*values.unitWeight.water;
            newParameter.delta_u = dat.u2-newParameter.u0;
            
            newParameter.qt = dat.qc + dat.u2.*(1-dat.CAR);
            newParameter.Rf = (dat.fs./newParameter.qt).*100;
            
            newParameter.sigma_v0 = dat.z.*values.unitWeight.soil;%+values.unitWeight.water*data.postprocess.(data.nameSave{i}).h_water); modified by SDNN 15-07-2020
            newParameter.sigma_v0_eff = dat.z.*(values.unitWeight.soil-values.unitWeight.water);
            
            %% Robertson parameter calculation and saving
            [newParameter.Qtn, newParameter.Fr, newParameter.Ic] = plot_layer(dat.z, newParameter.qt, dat.fs, newParameter.sigma_v0, newParameter.sigma_v0_eff,values);
            
            newParameter.Qt = (newParameter.qt-newParameter.sigma_v0)./newParameter.sigma_v0_eff;
            newParameter.Bq = (newParameter.delta_u)./(newParameter.qt-newParameter.sigma_v0);
            
            %% Check if post-processed parameters are defined in AGS file and / or create values in data structure
            for k = 1:length(ParametersFunction)    % Loop over all post-processed variables determined
                if isfield(dat,(ParametersFunction{k}))     % Check if parameter already exist in structure
                    % Compare calculated parameter to provided data structure
                    %compareData(settings,data,newParameter,Folder,ParametersFunction{k},i)    % Function for making comparison plot
                    dat.CAL.(ParametersFunction{k}) = newParameter.(ParametersFunction{k});     % Save calculated post-processed variables in "CAL" structure
                else % Save calculated parameter to structure
                    dat.(ParametersFunction{k}) = newParameter.(ParametersFunction{k});
                end
            end
            
            % Store calculated parameters
            data.postprocess.(IDi).(IDj) = dat;
        end
    end
end


