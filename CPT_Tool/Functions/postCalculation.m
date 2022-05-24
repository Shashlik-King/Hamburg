function data = postCalculation(settings,data,values,Folder)
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

for i = 1:length(fieldnames(data.postprocess))    % Looping over all locations where data is defined 
    %% Post-processing (calculate standard definitions for usage in post-processing)
	newParameter.u0 = data.postprocess.(data.nameSave{i}).z.*values.unitWeight.water;
    newParameter.delta_u = data.postprocess.(data.nameSave{i}).u2-newParameter.u0;
    
    newParameter.qt = data.postprocess.(data.nameSave{i}).qc + data.postprocess.(data.nameSave{i}).u2.*(1-data.postprocess.(data.nameSave{i}).CAR);
    newParameter.Rf = (data.postprocess.(data.nameSave{i}).fs./newParameter.qt).*100;
    
    newParameter.sigma_v0 = data.postprocess.(data.nameSave{i}).z.*values.unitWeight.soil;%+values.unitWeight.water*data.postprocess.(data.nameSave{i}).h_water); modified by SDNN 15-07-2020
    newParameter.sigma_v0_eff = data.postprocess.(data.nameSave{i}).z.*(values.unitWeight.soil-values.unitWeight.water);
    
    %% Robertson parameter calculation and saving
    [newParameter.Qtn, newParameter.Fr, newParameter.Ic] = plot_layer(data.postprocess.(data.nameSave{i}).z, newParameter.qt, data.postprocess.(data.nameSave{i}).fs, newParameter.sigma_v0, newParameter.sigma_v0_eff,values);
    
    newParameter.Qt = (newParameter.qt-newParameter.sigma_v0)./newParameter.sigma_v0_eff;
    newParameter.Bq = (newParameter.delta_u)./(newParameter.qt-newParameter.sigma_v0);    
    
    %% Check if post-processed parameters are defined in AGS file and / or create values in data structure
    for j = 1:length(ParametersFunction)    % Loop over all post-processed variables determined 
        if isfield(data.postprocess.(data.nameSave{i}),(ParametersFunction{j}))     % Check if parameter already exist in structure
            % Compare calculated parameter to provided data structure
            compareData(settings,data,newParameter,Folder,ParametersFunction{j},i)    % Function for making comparison plot
            data.postprocess.(data.nameSave{i}).CAL.(ParametersFunction{j}) = newParameter.(ParametersFunction{j});     % Save calculated post-processed variables in "CAL" structure
        else % Save calculated parameter to structure
            data.postprocess.(data.nameSave{i}).(ParametersFunction{j}) = newParameter.(ParametersFunction{j});
        end
    end
end
    
    
    