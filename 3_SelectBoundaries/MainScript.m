%% Script for reading AGS format
close all; clear all; clc;
addpath('Functions');


%% Load settings
if 1
    [settings,plots,values] = readSettings;
else
    settings.Proj = 'Test';     % Project ID
    settings.rev = '01';        % Main revision from "ControlPanel" DB
    settings.locAll = 0;        % 1) Will consider all WTG positions for Project and Rev in "Overview_WTG"; 0) Will use defined positions below
    %settings.loc = {'WTG01','WTG02','WTG03','WTG04','WTG05','WTG06','WTG07','WTG08','WTG09','WTG10','WTG11'};
    settings.loc = {'WTG01'};
    settings.upload = 1;        % Upload selected stratigraphy to database
    settings.delete = 1;        % Allow script to delete stratigraphy for positions considered
    
    settings.runLayerSelec = 0;         % 1: Select layers when running routine, 0: Run routine with previously defined layers
    
    %%% Settings - plot
    settings.plots          = 1;        % 1: Make plots during the routine; 0: No plots generated
    settings.savePlots      = 1;        % 1: Save plots generated from routine; 0: No plots saved
    settings.crop           = 1;        % 1: Save a cropped version of the images
    
    % Activate plots
    plots.Schneider         = 0;
    plots.Robertson1986     = 0;
    plots.Robertson1986_Rf  = 0;
    plots.Robertson1990_2010= 0;
    plots.Robertson1990_Bq  = 0;
    plots.Robertson1990_Fr  = 0;
    plots.Robertson2009     = 0;
    plots.Jardine           = 1;
    
    %%% Database input
    settings.db.Name ='owdb';         % Database name
    settings.db.Serv ='DKLYCOPILOD1';  % Databse server
    settings.db.User ='owdb_user';    % Database user
    settings.db.Pass ='ituotdowdb';   % Database pass
    
    %%% Predefined Standard Definitions
    values.unitWeight.water = 10;       % Water unit weight [kN/m3]
    values.unitWeight.soil  = 20;       % Soil unit weight (assumed) [kN/m3]
    values.P_a              = 101.3;    % Atmospheric pressure [kPa] (Converted to MPa in function)
end

settings.LayerSel.BH = 0;           %
settings.LayerSel.Horizon = 0;      %
settings.Rob.zoneDet = [1,2,3];   % Vector with different ways to determine Robertson zone - first method defined used as SBT determination in summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Standard set to 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Write "help ZoneDetermination" in command window for reading about possibilities in vector.

%% Load data from database
[data, strat] = DBread(settings);

%% Post-processing
values = InitialChecks(settings,values);
data = postCalculation(settings,data,values);                % Post-calculation for calculating more parameters from the received data

%% Layer selection
for i = 1:length(settings.loc)                      % Loop around all locations found in the AGS files
    disp(settings.loc{i})                                              % Display name in command window
    for j = 1:length(settings.Rob.zoneDet)                           % Loop over all selected zone determination methods
        data = ZoneDetermination(settings, data, i, settings.Rob.zoneDet(j));  % Determining Robertson zone
    end
    try
        data = LayerSelection(settings,data,strat,i);                  % Generate plot and select layering for each location
    catch ME
        close all;
    end
    data = ZoneDistribution(settings,data,i);                                % Create zone distribution for each layer
end

%% Upload stratigraphy for database
if settings.upload                                        % Check if layer selections should be saved
    errorLog = DBupload(settings,data);
end

%% Plot loop
settings.plotSwitch = plots;
if settings.plots
    disp('Plots are created and saved at local directory in the "Output" folder')
    for i = 1:length(settings.loc)                      % Loop around all locations found in the AGS files
        plotOutput(settings,values,data,i);                      % Generate plots for SBT from layer selections
    end
end

%% Save workspace for log
clear i j plots
dateSTR = getDate;
save(['Log\',dateSTR])

