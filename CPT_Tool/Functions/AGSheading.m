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


naming = [%{'HEADING'},{'variable name'},{'Unit'};
    % LOCA group
    {'LOCA_GL'},{'h_water'},{'m'};           % Water level
    {'LOCA_NATE'},{'Coord_E'},{'m'};         % Coordinate Easting
    {'LOCA_NATN'},{'Coord_N'},{'m'};         % Coordinate Northing
    
    % SCPG group
    {'SCPG_CAR'},{'CAR'},{''};              % Cone area ratio used to calculate qt
    {'SCPG_SLAR'},{'SLAR'},{''};            % Sleeve area ratio used to calculate ft
    {'SCPG_WAT'},{'WAT'},{'m'};             % Groundwater level at time of test
    
    % SCPT group
    {'SCPG_TESN'},{'PushNo'},{''};          % Test reference or push number
    {'SCPT_DPTH'},{'z'},{'m'};              % Depth of result
    {'SCPT_RES'},{'qc'},{'MPa'};            % Cone resistance (qc)
    {'SCPT_FRES'},{'fs'},{'MPa'};           % Local unit side friction resistance (fs)
    {'SCPT_PWP1'},{'u1'},{'MPa'};           % Face porewater pressure (u1)
    {'SCPT_PWP2'},{'u2'},{'MPa'};           % Shoulder porewater pressure (u2)
    {'SCPT_PWP3'},{'u3'},{'MPa'};           % Top of sleeve porewater pressure (u3)
    {'SCPT_FRR'},{'Rf'},{'%'};              % Friction ratio (Rf)
    {'SCPT_QT'},{'qt'},{'MPa'};             % Corrected cone resistance (qt) piezocone only
    {'SCPT_FT'},{'ft'},{'MPa'};             % Corrected sleeve resistance (ft) piezocone only
    {'SCPT_QE'},{'qe'},{'MPa'};             % Effective cone resistance (qe) piezocone only
    {'SCPT_QNET'},{'qn'},{'MPa'};           % Net cone resistance (qn)
    {'SCPT_BQ'},{'Bq'},{''};                % Pore pressure ratio (Bq) piezocone only
    {'SCPT_NQT'},{'Qt'},{''};               % Normalised cone resistance (Qt)
    {'SCPT_NFR'},{'Fr'},{'%'};              % Normalised friction ratio (Fr)
    
    ];


%% Find variable to use
index = find(strcmp(naming(:,1),search));
if ~isempty(index)
    out = naming(index,2:3);  % Creating output in the form of variable name and unit
else
    out = nan;
end