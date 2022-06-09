function [out] = AGSheading(search)
%%%-------------------------------------------------------------------------%%%
% out = HeadingsAGS(search)
% Function for defining variable name from Heading in AGS file(s)
% Not defined variable names can be added to vector in function
%
% Variables:
% - search:     The heading from AGS file
% - out:        The variable name used for post-processing
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     07-07-2020

[GROUPS,COLUMNS] = DB_tables; 


%% Find variable to use
index = find(strcmp(COLUMNS(:,1),search));
if ~isempty(index)
    out = COLUMNS(index,2:3);  % Creating output in the form of variable name and unit
else
    out = nan;
end