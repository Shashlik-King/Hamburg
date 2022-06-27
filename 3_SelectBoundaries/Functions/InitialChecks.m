function values = InitialChecks(settings,values)
%%%-------------------------------------------------------------------------%%%
% Function for making small initial settings etc.


%% Re-calculate units
values.unitWeight.water = values.unitWeight.water/1000;             % kN/m3 --> MN/m3
values.unitWeight.soil = values.unitWeight.soil/1000;               % kN/m3 --> MN/m3
values.P_a = values.P_a/1000;                                       % kPa --> MPa

%% Check if output plots is saved and create folder
if settings.plots || settings.savePlots
    if ~exist('Output', 'dir')
       mkdir('Output')
    end
end

if ~exist('Log', 'dir')
    mkdir('Log')
end

%% Turn MATLAB warnings off which does not affect the code from running 
% Turn off warning for function for making plot full screen in LayerSelection plot
id = 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame';
warning('off',id)