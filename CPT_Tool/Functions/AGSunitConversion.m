function factor = AGSunitConversion(unit1,unit2)
%%%-------------------------------------------------------------------------%%%
% factor = AGSunitConversion(unit1,unit2)
% Function for checking units in the AGS file and re-calculate the values if
% this doesnt correlates with the expected unit for that type of unit. The
% function will provide a factor that can be multiplied to the data for
% obtaining the correct unit on the received data.
%
% unit1:    Current unit
% unit2:    Desired unit
% factor:   Factor to multiply dataset to get desired unit
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     08-07-2020

%% Unit definitions
% Length - reference of [m]
Unit.length = [{'mm'},{'cm'},{'m'},{'km'};
    {1/1000}, {1/100}, {1}, {1000}];

% Stresses - reference of [MPa]
Unit.stress = [{'Pa'},{'kPa'},{'MPa'},{'GPa'};
    {1/1000000}, {1/1000}, {1}, {1000}];

% Percentage - reference of [%]
Unit.percentage = [{''},{'%'};
    {1/100}, {1}];


%% Unit factor calculation
unitNames = fieldnames(Unit);
for i = 1:length(fieldnames(Unit))
    indexUnit1 = find(strcmp(Unit.(unitNames{i})(1,:),unit1));
    if ~isempty(indexUnit1)
        break
    end
end

if isempty(indexUnit1)
    error('Cant find unit1 in defined units')
end

indexUnit2 = find(strcmp(Unit.(unitNames{i})(1,:),unit2));
if isempty(indexUnit2)
    error('Cant find unit2 in same type unit as unit1')
end

% Calculate factor between unit1 and unit2
factor = Unit.(unitNames{i}){2,indexUnit1} / Unit.(unitNames{i}){2,indexUnit2};



