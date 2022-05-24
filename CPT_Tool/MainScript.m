%% Script for reading AGS format
close all; clear all; clc;
addpath('Functions');
%% Info and settings

%%% Settings - positions to run
settings.input_file=2;              % 1: Read AGS format input; 2: Read excel input
settings.runAll = 1;                % 1: Run all files in "Data" folder; 0: Run below specified files
settings.runLoc = [{'EQ21452-BH-012A.ags'}];% [{'EQ21452_BH_001'},{'EQ21452_BH_003'},{'EQ21452_BH_005B'},{'EQ21452_BH_006'},{'EQ21452_BH_008A'},{'EQ21452_BH_009A'},{'EQ21452_BH_010A'},{'EQ21452_BH_011A'},{'EQ21452_BH_012A'},{'EQ21452_BH_013A'},{'EQ21452_BH_014A'},{'EQ21452_BH_015A'},{'EQ21452_BH_016'},{'EQ21452_BH_018'},{'EQ21452_BH_020'},{'EQ21452_BH_021'},{'EQ21452_BH_022B'},{'EQ21452_BH_023A'},{'EQ21452_BH_025A'},{'EQ21452_BH_027A'},{'EQ21452_BH_027'},{'EQ21452_BH_028'},{'EQ21452_BH_030'},{'EQ21452_BH_032A'},{'EQ21452_BH_033'},{'EQ21452_BH_035A'},{'EQ21452_BH_036A'},{'EQ21452_BH_037B'},{'EQ21452_BH_039'},{'EQ21452_BH_040B_B'},{'EQ21452_BH_040C_B'},{'EQ21452_BH_040D'},{'EQ21452_BH_041C'},{'EQ21452_BH_042'},{'EQ21452_BH_044'},{'EQ21452_BH_044A'},{'EQ21452_BH_045A'},{'EQ21452_BH_045C'},{'EQ21452_BH_046'},{'EQ21452_BH_046A'},{'EQ21452_BH_046B'},{'EQ21452_BH_047'},{'EQ21452_BH_049A'},{'EQ21452_BH_050A'},{'EQ21452_BH_051A'},{'EQ21452_BH_052A'},{'EQ21452_BH_053B'},{'EQ21452_BH_054A'},{'EQ21452_BH_055A'},{'EQ21452_BH_055B'},{'EQ21452_BH_057'},{'EQ21452_BH_059'},{'EQ21452_BH_061A'},{'EQ21452_BH_065'},{'EQ21452_BH_069A'},{'EQ21452_BH_070A'},{'EQ21452_BH_072A'},{'EQ21452_BH_073A'},{'EQ21452_BH_078A'},{'EQ21452_BH_082A'},{'EQ21452_BH_090A'},{'EQ21452_BH_098A'}]

settings.Locations = "" ;           % "": Run all CPT-locations in file; Else specify location name
settings.maxDepth = 500 ;           % Maximum depth [m] included in analysis

%%% Settings - Layer selection plot
settings.QAmode = 1;                % 1: QA mode is on, plotting existing data on plots to easily update layer boundaries during QA
settings.runLayerSelec = 0;         % 1: Select layers when running routine, 0: Run routine with previously defined layers
settings.LayerSelec.plot = 1;       % 1: Plot layer selection and/or able to select layers
settings.LayerSel.BH = 0;           %
settings.LayerSel.Horizon = 0;      %
settings.Rob.zoneDet = [1,2,3];   % Vector with different ways to determine Robertson zone - first method defined used as SBT determination in summary file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Standard set to 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Write "help ZoneDetermination" in command window for reading about possibilities in vector.


%%% Settings - Strength and stiffness parameters
settings.calc.strength  = 1;        % 1: Calculate strength par, stiffness par, etc. after layer selection
settings.calc.Unit = 1;             % 1) Parameter calculation based on Robertson units; 2) Parameter calculation based on self-defined units from excel sheet (only when "settings.runLayerSelec = 0")
settings.calc.soils = {'SAND','Sand';   % Define {'Self-defined unit','handle as "clay", "sand" or "silt"}'
    'SAND.S','Sand';
    'CLAY','Clay';
    'CLAY.S','Clay';
    'SILT','silt';
    'SILT.S','silt';
    'SILT.C','silt'};
values.Nkt = [20];
values.NktName = {'Nkt 20'};
settings.NktLegend = {'N_{kt} 20'};

values.Id_methods = [1 1 1 1 0];    % [Baldi et al. (1986)  Lunne et al. NC Sands (1997)  Lunne et al. OC Sands (1997)]
values.phi_methods = [1 1 1];   % [Kulhawy and Mayne (1990)   Schmertmann (1978)  Robertson and Campanella (1983)]
values.Gmax_methods = [1 1 1];  % [Baldi et. al (1989)   Rix and Stokoe (1991)   DNVGL-RP-CP212 (2017)]
values.OCR_methods = [1 1 1];     % [Robertson (1990),   Mayne - Sand (2012),  Mayne - Clay (2012)]


%%% Settings - Unit plots for groups
settings.UnitDis = 0;               % 1: Group selected units from layering
settings.UnitCategory = 1;          % 0) Run both settings; 1) Unit plots based on Robertson; 2) Units based on self-defined units in excel sheet;
settings.UnitParameters = {'qc','Rf','Ic'};  % Parameters to generate plots for  %{'qc','Rf','cu','phi','Ic'}
settings.UnitLAB = 0;               % 1: Add lab data to plots


%%% Settings - smoothening (NOT FINALIZED YET)
settings.smooth = 0;                % Use smootened CPT data for calculation / documentation
settings.smoothPar = 'BE';          % Smoothened parameters to use for calculation; 'BE', 'LB', 'UB'
settings.Smoothened.Vector = [{'qc'}]; % Insert variables which is wanted to be smoothened (smoothened parameters are used in post-processing)


%%% Settings - plot
settings.plots          = 1;        % 1: Make plots during the routine; 0: No plots generated
settings.savePlots      = 1;        % 1: Save plots generated from routine; 0: No plots saved
settings.closePlots     = -1;       % 1: Closing Plots, 0: Not closing plots, -1: Close if looping more than 1 position

settings.plot.Overview  = 0;        % 1: Plot overview map from all received data, 0: No overview plot

settings.SaveOutput     = 1;        % 1: Save layering info in excel summary sheet, 0: Don't save results


%%% Export options
settings.DSP = 1;       % Make design soil profiles from determined parameters
settings.DSPpar = {'phi','cu','Id','OCR','Gmax','rho','V_s'}; % Parameters defined in the design soil profile
settings.exportPar = 0;    % Make file with all calculated parameters related to depth

%%% Folders
Folder.Data.CPT         = 'Data\CPT';                               % Folder storing the CPT data files used as basis
Folder.Data.BH          = 'Data\BH';                                % Folder storing the BH data files used as basis
Folder.Data.Geophys     = 'Data\Geophysical';                       % Folder storing the received geophysical layer interpretation
Folder.Output           = 'Output';                            % Folder where output will be stored
Folder.Figures          = 'Output\Figures';                    % Folder where figures will be stored
Folder.figurePath       = 'Functions\FigureBasis';                  % Folder where plots used as basis are stored (Backgrounds etc.)
Folder.UnitDis          = 'Output\Figures\UnitDistribution';   % Folder for storing figures from Unit distribution overview


%%% File names
Folder.LAB = 'Data\LABdata.xlsx';
Folder.LABstiff = 'Data\LABdataStiff.xlsx';
Files.Output = 'Layering.xlsx';
Files.BH = 'BH_data';
Files.Geophys = 'Horizon_at_wells';


%%% Standard definitions
values.unitWeight.water = 10;       % Water unit weight [kN/m3]
values.unitWeight.soil  = 20;       % Soil unit weight (assumed) [kN/m3]
values.P_a              = 101.3;    % Atmospheric pressure [kPa] (Converted to MPa in function)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF MANUAL SETTINGS - CODE STARTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-calculations and checks
settings.Files = Files;
values = InitialChecks(settings,Folder,values);

%% Load AGS files and prepare data for post-processing
if settings.input_file == 1
    data = AGSread(settings,Folder);                                % Function for reading CPT data from AGS format
else
    data = XLSXread(settings,Folder);
end
data = FileRead(settings,Folder,Files,data);                        % Function for additional reading of data from files

%% Smoothening
if settings.smooth
    data.postInitial = data.postprocess;                            % Save the initial "data.postprocess" data before smoothening of the data is performed
    for i = 1:length(fieldnames(data.Basis))                        % Loop around locations
        for j = 1:length(settings.Smoothened.Vector)                % Loop around parameters to smoothen
            [data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).BE, data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).LB, data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).UB] = smoothening_CPT([data.postprocess.(data.nameSave{i}).z, data.postprocess.(data.nameSave{i}).(settings.Smoothened.Vector{j})]);
            data.postprocess.(data.nameSave{i}).(settings.Smoothened.Vector{j}) = data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).(settings.smoothPar);
        end
    end
end

%% Post-processing
data = postCalculation(settings,data,values,Folder);                % Post-calculation for calculating more parameters from the received data
plotOverviewSite(settings,data,Folder)                              % Plot overview of the site with the locations analysed

%%
for i = 1:length(fieldnames(data.postprocess))                      % Loop around all locations found in the AGS files
    disp(data.name{i})                                              % Display name in command window
    for j = 1:length(settings.Rob.zoneDet)                           % Loop over all selected zone determination methods
        data = ZoneDetermination(data, i, settings.Rob.zoneDet(j));  % Determining Robertson zone
    end
    data = LayerSelection(settings,Folder,data,i);                  % Generate plot and select layering for each location
    %plotOutput(settings,Folder,values,data,i);                      % Generate plots for SBT from layer selections
    data = ZoneDistribution(data,i);                                % Create zone distribution for each layer
    if settings.SaveOutput                                          % Check if layer selections should be saved
        %summarySaving(settings,Folder,data,i);                      % Save layers and zone distribution in excel summary sheet
    end
    if settings.calc.strength
        [data, settings] = postCalculation_addition(settings,data,values,Folder,i);   % Calculate additional parameters
        %plotOutput_addition(settings,Folder,values,data,i)
    end
end

% Load final stratigraphy from layering file
data.Stratigraphy = readcell(fullfile(Folder.Output,Files.Output));

%%%%%%%%%%%%%%%%%%%%%% CODE SECTION AFTER LAYERING HAS BEEN PERFORMED %%%%%%%%%%%%%%%%%%%%%%
%% Unit distribution
if settings.UnitDis
    disp('Create documentation for unit plots')
    if settings.UnitCategory == 0
        for i = 1:2
            settings.UnitCat = i;
            data = UnitDistribution(settings,Folder,data);                  % Function for creating overview for each unit
        end
    else
        settings.UnitCat = settings.UnitCategory;
        data = UnitDistribution(settings,Folder,data);                  % Function for creating overview for each unit
    end
end

%% Output
if settings.DSP || settings.exportPar
    disp('Create output documentation')
    % Create design soil profile based on parameters
    if settings.DSP && 0
        design_profile = designSoilProfiles(settings,Folder,Files,data,values);
    end
    design_profileNew = designSoilProfilesNew(settings,Folder,Files,data,values);
    % Export all calculated parameters
    if settings.exportPar
        Exportfunction(data,Folder,settings);
    end
end
%save([Folder.Output,'\Workspace.mat'])         % Save workspace in output folder 
disp('Calculation finalized')