function factor = AGSunitConversion(unit1,unit2,varAGS)
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


if strcmp(unit1,unit2)
    factor = 1;
else
    
    %% Unit definitions
    % Length - reference of [m]
    Unit.length = [{'mm'},{'cm'},{'m'},{'km'};
        {1/1000}, {1/100}, {1}, {1000}];
	
	% Area - reference of [m2]
	Unit.area = [{'mm2'},{'cm2'},{'m2'},{'km2'};
        {(1/1000)^2}, {(1/100)^2}, {1}, {1000^2}];
    
	% Volume - reference of [m3]
	Unit.area = [{'mm3'},{'cm3'},{'m3'},{'km3'};
        {(1/1000)^3}, {(1/100)^3}, {1}, {1000^3}];
	
    % Stresses - reference of [MPa]
    Unit.stress = [{'Pa'},{'kPa'},{'MPa'},{'GPa'};
        {1/1000000}, {1/1000}, {1}, {1000}];
    
    % Unitless
    Unit.noUnit = [{'-'},{''},{' '};
        {1}, {1}, {1}];
    
    % Percentage - reference of [%]
    Unit.percentage = [{''},{'%'};
        {1/100}, {1}];
    
    
    
    %% Unit factor calculation
    unitNames = fieldnames(Unit);
    for i = 1:length(fieldnames(Unit))
        indexUnit1(i) = ~isempty(find(strcmp(Unit.(unitNames{i})(1,:),unit1)));
    end
    
    % indexUnit2 = find(strcmp(Unit.(unitNames{i})(1,:),unit2));
    for i = 1:length(fieldnames(Unit))
        indexUnit2(i) = ~isempty(find(strcmp(Unit.(unitNames{i})(1,:),unit2)));
    end
    
    if all(isempty(indexUnit1))
        error(['Cant find unit1 in defined units [',unit1,']'])
    end
    if all(isempty(indexUnit2))
        error(['Cant find unit1 in defined units [',unit2,']'])
    end
    
    index1 = find(indexUnit1);
    index2 = find(indexUnit2);
    
    interVal = intersect(index1,index2); 
    
    if all(isempty(interVal)) || length(interVal) > 1.5
        error(['Cant find unit2 in same type unit as unit1. Var=',varAGS,'; Unit1 [',unit1,'], Unit2 [',unit2,']'])
    end
    
    indexUnit1 = find(strcmp(Unit.(unitNames{interVal})(1,:),unit1));
    indexUnit2 = find(strcmp(Unit.(unitNames{interVal})(1,:),unit2)); 
    
    % Calculate factor between unit1 and unit2
    factor = Unit.(unitNames{interVal}){2,indexUnit1} / Unit.(unitNames{interVal}){2,indexUnit2};
end


