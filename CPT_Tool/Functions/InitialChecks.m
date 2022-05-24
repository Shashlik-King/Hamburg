function values = InitialChecks(settings,Folder,values)
%%%-------------------------------------------------------------------------%%%
% Function for making small initial settings etc.


%% Re-calculate units
values.unitWeight.water = values.unitWeight.water/1000;             % kN/m3 --> MN/m3
values.unitWeight.soil = values.unitWeight.soil/1000;               % kN/m3 --> MN/m3
values.P_a = values.P_a/1000;                                       % kPa --> MPa

%% Check for warnings regarding the settings of the code
% Check if plots are set to be saved but not created
if settings.plots == 0 && settings.savePlots
    disp('Cant save plots when setting for generating plots is off')
end

% Check if self-defined units are used while changes in stratigraphy can is made
if settings.calc.Unit == 2 && settings.runLayerSelec == 1
    disp('Cant use self-defined units when changes in layering can be performed')
end

% Check if QA mode is on when no summary file is available 
if ~exist(fullfile(Folder.Output,settings.Files.Output),'file') && settings.QAmode
    disp('QAmode is turned on dispite no summary file is found - consider changing QAmode = 0')
end

%% Turn MATLAB warnings off which does not affect the code from running 
% Turn off warning for function for making plot full screen in LayerSelection plot
id = 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame';
warning('off',id)