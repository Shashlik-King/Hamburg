function [DESC, MAT] = ZoneSBT(zone,method)
%%%-------------------------------------------------------------------------%%%
% Function for determining soil behaviour type (SBT) from the Robertson
% index calculated previously
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020
DESC = cell(length(zone),1);
MAT = cell(length(zone),1);

%% Define different zones description for different charts
MethodCheck = 1;
if any(strcmp(method,{'Ic_Based','Rob1990FrQt','Rob1990BqQt','Rob2009eq'}))
        % Zone number, Robertson description, Handled by code
    SBT = [{1}, {'Clay'},                       {'Clay'};
        {2}, {'Clay, organic'},                 {'Clay'};
        {3}, {'Clay'},                          {'Clay'};
        {4}, {'Silt'},                          {'Silt'};
        {5}, {'Sand, silty'},                   {'Sand'};
        {6}, {'Sand'},                          {'Sand'};
        {7}, {'Sand, gravelly'},                {'Sand'};
        {8}, {'Sand, very stiff to clayey'},    {'Sand'};
        {9}, {'Clay, very stiff'},              {'Clay'}];
elseif any(strcmp(method,{'Rob1986Rfqt'}))
    SBT = [{1}, {'Sensitive fine grained'},     {'Clay'};
        {2}, {'Organic material'},              {'Clay'};
        {3}, {'Clay'},                          {'Clay'};
        {4}, {'Silty clay to clay'}             {'Clay'};
        {5}, {'Clayey silt to silty clay'},     {'Silt'};
        {6}, {'Sandy silt to clayey silt'},     {'Silt'};
        {7}, {'Silty sand to sandy silt'},      {'Silt'};
        {8}, {'Sand, silty sand'},              {'Sand'};
        {9}, {'Sand'},                          {'Sand'};
        {10}, {'Sand, gravelly'},               {'Sand'};
        {11}, {'Sand, very stiff to clayey'},   {'Sand'};
        {12}, {'Clay, very stiff'},             {'Clay'}];
elseif any(strcmp(method,{'Ic_Based_COWI','Rob1990FrQt_COWI'}))
    SBT = [{1}, {'Sensitive fine grained'},     {'Clay'};
        {2},    {'Organic material'},         	{'Clay'};
        {3.1},  {'Clay'},                       {'Clay'};
        {3.2},  {'Silty clay'}                  {'Clay'};
        {4.1},  {'Silty clay'},                 {'Clay'};
        {4.2},  {'Clayey silt'},                {'Silt'};
        {5.1},  {'Sandy silt'},                 {'Silt'};
        {5.2},  {'Silty sand'},                 {'Sand'};
        {6.1},  {'Silty sand'},                 {'Sand'};
        {6.2},  {'Clean sand'},                 {'Sand'};
        {7},    {'Sand, gravelly'},             {'Sand'};
        {8},    {'Sand, very stiff to clayey'}, {'Sand'};
        {9},    {'Clay, very stiff'},           {'Clay'}];
else
    disp('SBT types not defined')
    MethodCheck = 0;
end

if MethodCheck
    for j = 1:length(zone)
        index = find([SBT{:,1}]==zone(j));
        if isempty(index)
            DESC{j,1} = 'Not defined';
            MAT{j,1} = 'Not defined';
        else
            DESC{j,1} = SBT{index,2};
            MAT{j,1} = SBT{index,3};
        end
    end
end