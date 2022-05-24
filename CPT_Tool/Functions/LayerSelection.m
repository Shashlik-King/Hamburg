function data = LayerSelection(settings,Folder,data,i)
%%%-------------------------------------------------------------------------%%%
% Function for creating plot used for layer selection
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020
% Added additional plots, SDNN      16-07-2020


if settings.LayerSelec.plot
    
    plotsSubplots = 6;
    plotsSubplot = 0;
    % Figure CPT and Robertson indication side-by-side
    %figure('units','normalized','outerposition',[0 0 1 1])
    figure('Name',data.name{i});
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);
    pause(0.1);
    
    hold all
    names.zoneNames = fieldnames(data.postprocess.(data.nameSave{i}).ZoneData);     % Find all names in structure for Zone determination
    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    if length(names.zoneNames) == 1
        deltaScatter = 0;
    else
        deltaScatter = linspace(-0.15,0.15,length(names.zoneNames));
    end
    for j = 1:length(names.zoneNames)
        scatter(data.postprocess.(data.nameSave{i}).ZoneData.(names.zoneNames{j})+deltaScatter(j),data.postprocess.(data.nameSave{i}).z,10,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
    end
    set(gca, 'YDir','reverse')
    grid on
    ylabel('Depth [m]')
    xlabel('SBT [-]')
    xlim([0.5 7.5])
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    xticks([1:7])
    xticklabels({'1','2','3','4','5','6','7'})
    pLim.xLimits1 = get(gca,'XLim');  %# Get the range of the x axis
    
    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        plot(data.postprocess.(data.nameSave{i}).Ic(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),'b')
    end
    set(gca, 'YDir','reverse')
    xlim([1 4])
    xlabel('Ic [-]')
    grid on
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    pLim.xLimits2 = get(gca,'XLim');  %# Get the range of the x axis
    pLim.yLimits2 = get(gca,'YLim');  %# Get the range of the y axis
    
    colorboxDefinitions = [2, 3.6, pLim.xLimits2(2), 181, 105, 60;
        3, 2.95, 3.6, 71, 87, 120;
        4, 2.6, 2.95, 67, 145, 133;
        5, 2.05, 2.6, 122, 196, 161;
        6, 1.31, 2.05, 191, 161, 98;
        7 pLim.xLimits2(1), 1.31, 237, 153, 71];
    
    for j = 1:size(colorboxDefinitions,1)
        object = fill([colorboxDefinitions(j,2:3) flip(colorboxDefinitions(j,2:3))],[pLim.yLimits2(1)*ones(1,2) pLim.yLimits2(2)*ones(1,2)],colorboxDefinitions(j,4:6)/255,'LineStyle','none');
        alpha(object,0.5)
    end
    plot(data.postprocess.(data.nameSave{i}).Ic,data.postprocess.(data.nameSave{i}).z)
    xlim(pLim.xLimits2)  % Make sure the boxes doesn't change the limits of plot
    
    %     %%%%%% LOOP FOR subplots %%%%%%
    %     settings.LayerPar = {'qc','Rf','u2'};
    %     plotIndex = 2;
    %     plotTotal = plotIndex+length(settings.LayerPar);
    %
    %     for j = 1:length(settings.LayerPar)
    %         plotIndex = plotIndex+1;        % Increase subplot index by 1
    %         subplot(1,plotTotal,plotIndex)
    %         hold all
    %         for k = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
    %             plot(data.postprocess.(data.nameSave{i}).(settings.LayerPar{k})(data.postprocess.(data.nameSave{i}).pushIndex(k,1):data.postprocess.(data.nameSave{i}).pushIndex(k,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(k,1):data.postprocess.(data.nameSave{i}).pushIndex(k,2)),'b')
    %         end
    %         % Insert labels
    %         pLim.(strcat('xLimits',num2str(plotIndex))) = get(gca,'XLim');  %# Get the range of the x axis
    %         pLim.(strcat('yLimits',num2str(plotIndex))) = get(gca,'YLim');  %# Get the range of the y axis
    %
    %         % Insert limits
    %
    %         plotSpecialVariables(settings.LayerPar{j})
    %
    %     end
    %     %%%%%%% END %%%%%%%%%%%%%%%%
    
    
    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        scatter(data.postprocess.(data.nameSave{i}).qc(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','MarkerEdgeColor',[0, 0.4470, 0.7410],'MarkerFaceColor',[0, 0.4470, 0.7410])
    end
    set(gca, 'YDir','reverse')
    
    xlabel('q_c [MPa]')
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
    grid on
    %xlim([0 inf])
    if max(data.postprocess.(data.nameSave{i}).qc) > 50
        xlim([0 100])
    end
    xlim([0 100])
    pLim.xLimits3 = get(gca,'XLim');  %# Get the range of the x axis

    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        scatter(data.postprocess.(data.nameSave{i}).fs(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','MarkerEdgeColor',[0, 0.4470, 0.7410],'MarkerFaceColor',[0, 0.4470, 0.7410])
    end
    set(gca, 'YDir','reverse')
    
    xlabel('f_s [MPa]')
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
    grid on
%     xlim([0 inf])
    xlim([0, 2])
    %     if max(data.postprocess.(data.nameSave{i}).qc) > 50
    %         xlim([0 50])
    %     end
    pLim.xLimits4 = get(gca,'XLim');  %# Get the range of the x axis
    
    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        scatter(data.postprocess.(data.nameSave{i}).Rf(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','MarkerEdgeColor',[0, 0.4470, 0.7410],'MarkerFaceColor',[0, 0.4470, 0.7410])
    end
    set(gca, 'YDir','reverse')
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    xlabel('R_f [%]')
    %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
    grid on
    xlim([0 inf])
    if max(data.postprocess.(data.nameSave{i}).Rf) > 5
        xlim([0 5])
    end
    pLim.xLimits5 = get(gca,'XLim');  %# Get the range of the x axis
    
    plotsSubplot = plotsSubplot+1;
    subplot(1,plotsSubplots,plotsSubplot)
    hold all
    plot(data.postprocess.(data.nameSave{i}).u0,data.postprocess.(data.nameSave{i}).z,'k')
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        scatter(data.postprocess.(data.nameSave{i}).u2(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','MarkerEdgeColor',[0, 0.4470, 0.7410],'MarkerFaceColor',[0, 0.4470, 0.7410])
    end
    set(gca, 'YDir','reverse')
    ylim([0 max(data.postprocess.(data.nameSave{i}).z)])
    xlabel('u_2 [MPa]')
    xlim([-2, 4])
    %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
    grid on
    pLim.xLimits6 = get(gca,'XLim');  %# Get the range of the x axis
    
    
    sgtitle(data.nameSave{i},'Interpreter','none')
    
    % Add lines for horisonts and BH layering if any defined
    if settings.LayerSel.BH     % If BH to be added
        indexBH = find(strcmp(data.BH(:,1),data.name{i}));
        if ~isempty(indexBH)
            for j = 1:plotsSubplots
                subplot(1,plotsSubplots,j)
                hold all
                BHplotLevels = cell2mat(data.BH(indexBH(1:end-1),3));
                BHplotIndex = sum(BHplotLevels<max(data.postprocess.(data.nameSave{i}).z));
                if ~isempty(BHplotIndex)
                    plot(pLim.(strcat('xLimits',num2str(j))),BHplotLevels(1:BHplotIndex)*ones(1,2),'--g')
                end
            end
        else
        end
    else
    end
    
    
    if settings.LayerSel.Horizon    % If horisonts to be added
        indexHorizont = find(strcmp(data.Horizonts(:,1),data.name{i}));
        if ~isempty(indexHorizont)
            for j = 1:plotsSubplots
                subplot(1,plotsSubplots,j)
                hold all
                for k = 2:size(data.Horizonts,2)
                    if data.Horizonts{indexHorizont,k} < max(data.postprocess.(data.nameSave{i}).z) %% data.Horizonts{indexHorizont,k} < maxBH &&
                        plot(pLim.(strcat('xLimits',num2str(j))),data.Horizonts{indexHorizont,k}*ones(1,2),'b')
                        if j == plotsSubplots
                            txt = data.Horizonts{1,k};
                            text(pLim.(strcat('xLimits',num2str(j)))(2),data.Horizonts{indexHorizont,k},txt,'FontSize',6)
                        end
                    end
                end
            end
        end
    end
    
    if settings.LayerSel.Horizon || settings.LayerSel.BH
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Layer_BHonly']),'png')
    end
    %% Start selection of boundaries at plot
    pause(0.1)
    counter = 0;            % Counter to keep overview of number of remaining lines
    counterT = 0;           % Counter to give each click an unique ID to ensure lines are ordered
    if settings.QAmode      % Include previous defined layer boundaries
        try                 % Search for previously defined levels in excel summary sheet and plot these in plot
            if i == 1
                QA.InitialBasis = readcell(fullfile(Folder.Output,settings.Files.Output));
                data.Layering.LayerSelectionData = QA.InitialBasis;
            else
                QA.InitialBasis = data.Layering.LayerSelectionData;
            end
            QA.layerIndex = find(strcmp(QA.InitialBasis(:,1),data.nameSave{i}));
            counter = length(QA.layerIndex)-1;
            if counter < 1
                counter = 0;
            else
                data_DL_ori = [cell2mat(QA.InitialBasis(QA.layerIndex(1:end-1),4)), NaN(length(QA.layerIndex(1:end-1)),2), (1:counter)'];
                
                % Check layer boundaries are in relevant zone for CPT
                RelevantIndex = max(data.postprocess.(data.nameSave{i}).z) > data_DL_ori(:,1);
                data_DL = data_DL_ori(RelevantIndex,:);
                counterT = size(data_DL,1);
                counter = counterT;
                
                for j = 1:size(data_DL,1)   % Add layers to subplots
                    for k = 1:plotsSubplots
                        subplot(1,plotsSubplots,k)
                        hold all
                        plotLevel.(strcat('layerplotlevel',num2str(k))).(['index',num2str(j)]) = plot([pLim.(strcat('xLimits',num2str(k)))(1) pLim.(strcat('xLimits',num2str(k)))(2)],[data_DL(j,1) data_DL(j,1)],'r');
                    end
                end
            end
        catch
            disp('No previous defined boundary layer data included')
        end
    end
    if settings.runLayerSelec
        while 1 < 2     % "while" to handle click on plot options
            T = waitforbuttonpress;
            if T == 0
                [x,y,button] = ginput(1);
                if button == 1
                    counter = counter + 1;
                    counterT = counterT + 1;
                    data_DL(counter,:) = [round(y,1), x, button, counterT];
                    
                    for k = 1:plotsSubplots     % Add new line in all subplots
                        subplot(1,plotsSubplots,k)
                        hold all
                        plotLevel.(strcat('layerplotlevel',num2str(k))).(['index',num2str(counterT)]) = plot([pLim.(strcat('xLimits',num2str(k)))(1) pLim.(strcat('xLimits',num2str(k)))(2)],[data_DL(counter,1) data_DL(counter,1)],'r');
                    end
                elseif button == 3
                    if ~counter == 0
                        [~, indexDelete] = min(abs(data_DL(:,1)-y)); % Find index for line closest to deletion point
                        for k = 1:plotsSubplots     % Delete existing line in all subfigures
                            subplot(1,plotsSubplots,k)
                            hold all
                            delete(plotLevel.(strcat('layerplotlevel',num2str(k))).(['index',num2str(data_DL(indexDelete,4))]))
                        end
                        data_DL(indexDelete,:) = []; % Delete line data data matrix
                        counter = counter-1;
                    end
                end
            else
                break
            end
        end
    end
    if settings.savePlots
        %saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Layer']),'png')
        exportgraphics(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Layer.png']),'BackgroundColor','none')
    end
    if settings.closePlots == 1 || and(settings.closePlots==-1,length(fieldnames(data.postprocess))>1)
        close all
    end
else
    try                 % Search for previously defined levels in excel summary sheet and use these for routine
        QA.InitialBasis = readcell(fullfile(Folder.Output,settings.Files.Output));
        QA.layerIndex = find(strcmp(QA.InitialBasis(:,1),data.nameSave{i}));
        counter = length(QA.layerIndex)-1;
        if counter < 1
            error('break try-catch as no layers available')
        else
            data_DL_ori = [cell2mat(QA.InitialBasis(QA.layerIndex(1:end-1),4)), NaN(length(QA.layerIndex(1:end-1)),2), (1:counter)'];   % List all layers for position defined in the layering file
            RelevantIndex = max(data.postprocess.(data.nameSave{i}).z) > data_DL_ori(:,1);  % Check layer boundaries are in relevant zone for CPT
            data_DL = data_DL_ori(RelevantIndex,:);                                         % If not relevant, remove layers
        end
    catch
        error('No previous defined layers found / file found - cant run through data when no layers found')
    end
end

%% Save new defined layers from plot
data.postprocess.(data.nameSave{i}).layerLevel = sortrows(data_DL(:,1));     % Save layer levels / boundaries

indexLayer = NaN(length(data.postprocess.(data.nameSave{i}).layerLevel),1);
for j = 1:length(data.postprocess.(data.nameSave{i}).layerLevel)
    indexLayer(j,1) = sum(data.postprocess.(data.nameSave{i}).layerLevel(j)>data.postprocess.(data.nameSave{i}).z);
end

indexLayer = [[1; indexLayer+1],[indexLayer; length(data.postprocess.(data.nameSave{i}).z)]];
data.postprocess.(data.nameSave{i}).indexLayer = indexLayer;



%% Extra functions
%     function plotSpecialVariables(var)
%         if strcmp(var,'qc')
%             
%             
%             
%         elseif strcmp(var,'u2')
%             
%         end
%     end

