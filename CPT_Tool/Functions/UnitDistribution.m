function data = UnitDistribution(settings,Folder,data)
% Function for generating unit plots across the site
% Type of units can be defined from "settings.UnitCategory"
%   1) Unit plots based on Robertson chart (first defined - the one saved in excel sheet)
%   2) Units based on self-defined units in excel sheet
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     21-09-2020


%% Code start
dataBasis = readcell(fullfile(Folder.Output,settings.Files.Output));       % Load all basis data
dataUnit = dataBasis(3:end,:);                                      % Remove headers for data series to get clean cell array with data

if settings.UnitCat == 1 % if based on Robertson index
    UnitsDataIndex = 9;                                             % Get index from layer file
    folderSave = 'UnitRobertson';
elseif settings.UnitCat == 2 % if based on self defined units from layering file
    UnitsDataIndex = 5;                                             % Get index from layer file
    folderSave = 'UnitSelfDefined';
else
    error('Select proper way to base unit categories on ("UnitDistribution")')
end
Units = dataUnit(:,UnitsDataIndex);                                 % Get vector with units
UnitsNumeric = cellfun(@isnumeric,Units);                           % Find indexes where units are numerical

% Convert all units to strings
UnitAll = cell(length(Units),1);
for i = 1:length(Units)
    if UnitsNumeric(i)
        UnitAll{i,1} = num2str(Units{i});
    else
        UnitAll{i,1} = Units{i};
    end
end

dataUnit(:,UnitsDataIndex) = UnitAll;                                            % Insert all units in "data" variable as strings
UnitUnique_upd = unique(UnitAll);                                       % Find all unique units defined in profiles saved in excel files

UnitUnique = regexprep(UnitUnique_upd, '/','');                     % Remove backslash from strings for naming (backslash cant be used for structure names)
UnitUnique = regexprep(UnitUnique, ' ','');                     % Remove spacing from strings for naming (spacing cant be used for structure names)


if settings.UnitLAB
    labData = readcell(Folder.LAB);
    labDataStiffness = readcell(Folder.LABstiff);
    cohesionLayers = {'PgOrganic','PgClay','GcClay','GcTill','PreQClay'};
    frictionLayers = {'PgSilt','GcSilt','PreQSilt','PgSand','GcSand','PreQSand','PreQCoarse'};
end
%% Adjustment of unit groups - self-defined unit groups

% UnitUnique{1} = {'200','201','202','203','207','211','220','DK151'};
% UnitUnique{2} = {'300','301','302','303','310'};
% UnitUnique{3} = {'400','401','402','403','404','407','410','412','501','504','506','701','DK141','DK153'};
% UnitUnique{4} = {'DK171'};
% UnitUnique{5} = {'601'};


%% Loop over each unit
UnitParametersPlot = settings.UnitParameters;

%%%%%%%%% INPUT FOR ROBERTSON CHARTS XXXXX
UnitPlotRobertson = 1;
if UnitPlotRobertson
    RobertsonParameters = {'Ic','Qtn','Fr','Bq'};
    UnitParameters = [UnitParametersPlot, RobertsonParameters];
end
%%%%%%%%%%

for i = 1:length(UnitUnique)                                        % Loop over all units encountered in profiles analysed
    % % Normal code - use following line
    indexUnit = find(strcmp(dataUnit(:,UnitsDataIndex),UnitUnique_upd{i}));
    
    % % Code for using self-defined unit groups - use following lines
    % 	indexUnit = [];
    %     for j = 1:length(dataUnit(:,5))
    %         if any(strcmp(UnitUnique{i},dataUnit(j,5)))
    %             indexUnit = [indexUnit;j];
    %         end
    %     end
    % % End of loop for using different code setup
    counter = 0;
    for j = 1:length(indexUnit)
        location = dataUnit{indexUnit(j),1};
        zStart = dataUnit{indexUnit(j),3};
        zEnd = dataUnit{indexUnit(j),4};
        
        if any(strcmp(location,data.nameSave))
            counter = counter+1;
            indexStart = sum(data.postprocess.(location).z<zStart)+1;
            indexEnd = sum(data.postprocess.(location).z<zEnd);
            for k = 1:length(UnitParameters)
                if isstruct(data.postprocess.(location).(UnitParameters{k}))
                    %counter = counter-1;
                    for L = 1:size(data.postprocess.(location).(UnitParameters{k}).values,2)
                        %counter = counter+1;
                        data.Units.(strcat('Unit',UnitUnique{i})).(UnitParameters{k}).(strcat('m',num2str(L))){counter,1} = location;
                        data.Units.(strcat('Unit',UnitUnique{i})).(UnitParameters{k}).(strcat('m',num2str(L))){counter,2} = data.postprocess.(location).(UnitParameters{k}).methods(L);
                        data.Units.(strcat('Unit',UnitUnique{i})).(UnitParameters{k}).(strcat('m',num2str(L))){counter,3} = [data.postprocess.(location).(UnitParameters{k}).values(indexStart:indexEnd,L),data.postprocess.(location).z(indexStart:indexEnd)];
                    end
                else
                    data.Units.(strcat('Unit',UnitUnique{i})).(UnitParameters{k}){counter,1} = location;
                    data.Units.(strcat('Unit',UnitUnique{i})).(UnitParameters{k}){counter,3} = [data.postprocess.(location).(UnitParameters{k})(indexStart:indexEnd),data.postprocess.(location).z(indexStart:indexEnd)];
                end
            end
        end
    end
    close all
end



%% Make unit plots from available data for selected parameters
if 1
    for i = 1:length(UnitUnique)
        if any(strcmp(strcat('Unit',UnitUnique{i}),fieldnames(data.Units)))
            for j = 1:length(UnitParametersPlot)
                
                if isstruct(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}))
                    fieldName = fieldnames(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}));
                    fieldNr = length(fieldName);
                    structSwithch = 1;
                else
                    fieldNr = 1;
                    structSwithch = 0;
                end
                
                for II = 1:fieldNr
                    figure
                    ColOrd = get(gca,'ColorOrder');
                    hold all
                    set(gca, 'YDir','reverse')
                    % Make correct plot title
                    if strcmp(UnitParametersPlot{j},'phi_prime_p')
                        title(['Unit ',UnitUnique{i},', with phi'])
                        xlabel('Friction angle, \phi [°]')
                    elseif strcmp(UnitParametersPlot{j},'cu')
                        title(['Unit ',UnitUnique{i},', with c_u'])
                        xlabel('Undrained shear strength, c_u [kPa]')
                    elseif strcmp(UnitParametersPlot{j},'G_max')
                        title(['Unit ',UnitUnique{i},', with G_{max}'])
                        xlabel('Shear modulus, G_{max} [MPa]')
                    elseif strcmp(UnitParametersPlot{j},'OCR')
                        title(['Unit ',UnitUnique{i},', with OCR'])
                        xlabel('Overconsolidation ratio, OCR [-]')
                    elseif strcmp(UnitParametersPlot{j},'I_D')
                        title(['Unit ',UnitUnique{i},', with I_D'])
                        xlabel('Relative density, I_D [%]')
                    elseif strcmp(UnitParametersPlot{j},'qc')
                        title(['Unit ',UnitUnique{i},', with q_c'])
                        xlabel('Cone tip resistance, q_c [MPa]')
                    elseif strcmp(UnitParametersPlot{j},'Rf')
                        title(['Unit ',UnitUnique{i},', with R_f'])
                        xlabel('Friction ratio, R_f [%]')
                    else
                        title(['Unit ',UnitUnique{i},', with ',UnitParametersPlot{j}])
                        xlabel(UnitParametersPlot{j})
                    end
                    ylabel('Depth, z [m BSB]')
                    if structSwithch == 0
                        title(['Unit ',UnitUnique{i},', with ',char(UnitParametersPlot{j})])
                        for k = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}),1)
                            test(1) = scatter(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}){k,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}){k,3}(:,2),10,'b','filled');
                            test.MarkerFaceAlpha = 0.2;
                            test.MarkerEdgeAlpha = 0.2;
                        end
                    elseif structSwithch == 1
                        title(['Unit ',UnitUnique{i},', with ',char(UnitParametersPlot{j}),' - ',data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}).(fieldName{II}){1,2}{1}])
                        for k = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}).(fieldName{II}),1)
                            test(1) = scatter(data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}).(fieldName{II}){k,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}).(fieldName{II}){k,3}(:,2),10,'b','filled');
                            test.MarkerFaceAlpha = 0.2;
                            test.MarkerEdgeAlpha = 0.2;
                        end
                    end
                    xlim([0 inf])
                    grid on
                    
                    % Insert lab data
                    if settings.UnitLAB && or(and(strcmp(UnitParametersPlot{j},'phi_prime_p'),any(strcmp(frictionLayers,UnitUnique{i}))),and(strcmp(UnitParametersPlot{j},'cuPlot'),any(strcmp(cohesionLayers,UnitUnique{i}))))
                        columnIndexLAB = find(strcmp(labData(2,:),UnitUnique{i}));
                        indexValue = find(~cellfun(@ismissing, labData(3:end,columnIndexLAB)))+2;
                        testTypes = unique(labData(indexValue,3));
                        if ~isempty(testTypes)
                            for k = 1:length(testTypes)
                                indexTests = find(strcmp(labData(indexValue,3),testTypes{k}));
                                test(k+1) = scatter(cell2mat(labData(indexValue(indexTests),columnIndexLAB)),cell2mat(labData(indexValue(indexTests),2)),15,[ColOrd(k+1,:)],'filled');
                            end
                            legend(test(2:end),testTypes,'location','best')
                            clear test
                        end
                    elseif settings.UnitLAB && strcmp(UnitParametersPlot{j},'G_max')
                        %% CODE HERE GMAX
                        columnIndexLAB = find(strcmp(labDataStiffness(2,:),UnitUnique{i}));
                        indexValue = find(~cellfun(@ismissing, labDataStiffness(3:end,columnIndexLAB)))+2;
                        testTypes = unique(labDataStiffness(indexValue,3));
                        if ~isempty(testTypes)
                            for k = 1:length(testTypes)
                                indexTests = find(strcmp(labDataStiffness(indexValue,3),testTypes{k}));
                                test(k+1) = scatter(cell2mat(labDataStiffness(indexValue(indexTests),columnIndexLAB)),cell2mat(labDataStiffness(indexValue(indexTests),2)),15,[ColOrd(k+1,:)],'filled');
                            end
                            legend(test(2:end),testTypes,'location','best')
                            clear test
                        end
                    end
                    if structSwithch == 0
                        saveas(gcf, fullfile(Folder.UnitDis,folderSave,[UnitUnique{i},'_',UnitParametersPlot{j}]),'png')
                    else
                        saveas(gcf, fullfile(Folder.UnitDis,folderSave,[UnitUnique{i},'_',UnitParametersPlot{j},'_',data.Units.(strcat('Unit',UnitUnique{i})).(UnitParametersPlot{j}).(fieldName{II}){1,2}{1}]),'png')
                    end
                    close all
                    
                end
            end
        end
    end
end
%% Plot Robertson charts with all data from same unit
plotRobertsonData = 1;  % 1) Creating same color for all points; 2) Different colors in loop for analysing step-by-step plotting
if UnitPlotRobertson
    for i = 1:length(UnitUnique)
        %%% Robertson 1990 - Normalized CPT (SBTn) charts Qt–Fr and Qt-Bq
        figure      % Qt–Fr
        hold all
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Robertson_1990_normFr.png'));
        image('CData',I,'XData',[0.1 10],'YData',[1000 1.64])
        if plotRobertsonData == 1
            for j = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).Qtn,1)
                test = scatter(data.Units.(strcat('Unit',UnitUnique{i})).Fr{j,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).Qtn{j,3}(:,1),'b','filled');
                test.MarkerFaceAlpha = 0.1;
                test.MarkerEdgeAlpha = 0.1;
            end
        elseif plotRobertsonData == 2
            for j = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).Qtn,1)
                scatter(data.Units.(strcat('Unit',UnitUnique{i})).Fr{j,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).Qtn{j,3}(:,1),'filled');
            end
        end
        xlim([0.1 10])
        ylim([1 1000])
        xlabel('Normalised Friction Ratio, F_r [%]')
        ylabel('Q_t [-]')
        title('Robertson 1990 Normalized')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.UnitDis,folderSave,'RobertsonCharts',[UnitUnique{i},' Robertson1990_Fr']),'png')
        end
        
        figure      % Qt-Bq
        hold all
        set(gca, 'YScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Robertson_1990_normBq.png'));
        image('CData',I,'XData',[-0.6 1.4],'YData',[1000 1.64])
        if plotRobertsonData == 1
            for j = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).Qtn,1)
                test = scatter(data.Units.(strcat('Unit',UnitUnique{i})).Bq{j,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).Qtn{j,3}(:,1),'b','filled');
                test.MarkerFaceAlpha = 0.1;
                test.MarkerEdgeAlpha = 0.1;
            end
        elseif plotRobertsonData == 2
            for j = 1:size(data.Units.(strcat('Unit',UnitUnique{i})).Qtn,1)
                scatter(data.Units.(strcat('Unit',UnitUnique{i})).Bq{j,3}(:,1),data.Units.(strcat('Unit',UnitUnique{i})).Qtn{j,3}(:,1),'filled');
            end
        end
        xlim([-0.6 1.4])
        ylim([1 1000])
        xlabel('Normalised pore pressure, B_q [%]')
        ylabel('Q_t [-]')
        title('Robertson 1990 Normalized')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.UnitDis,folderSave,'RobertsonCharts',[UnitUnique{i},' Robertson1990_Bq.png']))
        end
        close all
    end
end
