function data = LayerSelection(settings,data,strat,i)
%%%-------------------------------------------------------------------------%%%
% Function for creating plot used for layer selection
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020
% Added additional plots, SDNN      16-07-2020

settings.LayerSelec.plot = 1;       % 1: Plot layer selection and/or able to select layers
settings.QAmode = 1;

loopIndex = data.postprocess.(settings.loc{i}).CPTavail;
loopIndex = loopIndex(~isnan(loopIndex));

color = [0.0000, 0.4470, 0.7410
         0.8500, 0.3250, 0.0980
         0.93  , 0.69  , 0.13
         0.4940, 0.1840, 0.5560
         0.4660, 0.6740, 0.1880
         0.3010, 0.7450, 0.9330
         0.6350, 0.0780, 0.1840];


if ~isempty(loopIndex)
    profile = strat.(settings.loc{i});

    for II = 1:length(loopIndex)
        III = loopIndex(II);
        dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
        yMax(II) = max(dat.z);
    end
    yMax = max(yMax);
    
    if settings.LayerSelec.plot
        
        plotsSubplots = 6;
        plotsSubplot = 0;
        % Figure CPT and Robertson indication side-by-side
        %figure('units','normalized','outerposition',[0 0 1 1])
        figure('Name',settings.loc{i});
        frame_h = get(handle(gcf),'JavaFrame');
        set(frame_h,'Maximized',1);
        pause(0.1);
        
        hold all
        names.zoneNames = fieldnames(data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(loopIndex(1)))).ZoneData);     % Find all names in structure for Zone determination
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        if length(names.zoneNames) == 1
            deltaScatter = 0;
        else
            deltaScatter = linspace(-0.15,0.15,length(names.zoneNames));
        end
        for j = 1:length(names.zoneNames)
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                scatter(dat.ZoneData.(names.zoneNames{j})+deltaScatter(j),dat.z,10,'filled',...
                    'MarkerEdgeColor',color(j,:),'MarkerFaceColor',color(j,:),'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
            end
        end
        set(gca, 'YDir','reverse')
        grid on
        ylabel('Depth [m]')
        xlabel('SBT [-]')
        xlim([0.5 7.5])
        ylim([0 yMax])
        xticks([1:7])
        xticklabels({'1','2','3','4','5','6','7'})
        pLim.xLimits1 = get(gca,'XLim');  %# Get the range of the x axis
        
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            for j = 1:size(dat.pushIndex,1)
                plot(dat.Ic(dat.pushIndex(j,1):dat.pushIndex(j,2)),dat.z(dat.pushIndex(j,1):dat.pushIndex(j,2)),'b')
            end
        end
        set(gca, 'YDir','reverse')
        xlim([1 4])
        xlabel('Ic [-]')
        grid on
        ylim([0 yMax])
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
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            plot(dat.Ic,dat.z,color,color(II,:))
        end
        xlim(pLim.xLimits2)  % Make sure the boxes doesn't change the limits of plot
        
        
        
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        clear xMax
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            scatter(dat.qc,dat.z,6,'filled','MarkerEdgeColor',color(II,:),'MarkerFaceColor',color(II,:))
            xMax(II) = max(dat.qc); 
        end
        set(gca, 'YDir','reverse')
        
        xlabel('q_c [MPa]')
        ylim([0 yMax])
        grid on
        %xlim([0 inf])
        if max(xMax) > 100
            xlim([0 100])
        end
        pLim.xLimits3 = get(gca,'XLim');  %# Get the range of the x axis
        
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        clear xMax
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            scatter(dat.fs,dat.z,6,'filled','MarkerEdgeColor',color(II,:),'MarkerFaceColor',color(II,:))
            xMax(II) = max(dat.fs); 
        end
        set(gca, 'YDir','reverse')
        
        xlabel('f_s [MPa]')
        ylim([0 yMax])
        %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
        grid on
            if max(xMax) > 2
                xlim([0 2])
            end
        pLim.xLimits4 = get(gca,'XLim');  %# Get the range of the x axis
        
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        clear xMax
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            scatter(dat.Rf,dat.z,6,'filled','MarkerEdgeColor',color(II,:),'MarkerFaceColor',color(II,:))
            xMax(II) = max(dat.Rf); 
        end
        set(gca, 'YDir','reverse')
        ylim([0 yMax])
        xlabel('R_f [%]')
        %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
        grid on
        if xMax > 5
            xlim([0 5])
        end
        pLim.xLimits5 = get(gca,'XLim');  %# Get the range of the x axis
        
        plotsSubplot = plotsSubplot+1;
        subplot(1,plotsSubplots,plotsSubplot)
        hold all
        
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            plot(dat.u0,dat.z,'k')
            scatter(dat.u2,dat.z,6,'filled','MarkerEdgeColor',color(II,:),'MarkerFaceColor',color(II,:))
        end
        set(gca, 'YDir','reverse')
        ylim([0 yMax])
        xlabel('u_2 [MPa]')
        %xlim([-2, 4])
        %ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
        grid on
        pLim.xLimits6 = get(gca,'XLim');  %# Get the range of the x axis
        
        
        sgtitle(settings.loc{i},'Interpreter','none')
        
        %     % Add lines for horisonts and BH layering if any defined
        %     if settings.LayerSel.BH     % If BH to be added
        %         indexBH = find(strcmp(data.BH(:,1),data.name{i}));
        %         if ~isempty(indexBH)
        %             for j = 1:plotsSubplots
        %                 subplot(1,plotsSubplots,j)
        %                 hold all
        %                 BHplotLevels = cell2mat(data.BH(indexBH(1:end-1),3));
        %                 BHplotIndex = sum(BHplotLevels<max(data.postprocess.(data.nameSave{i}).z));
        %                 if ~isempty(BHplotIndex)
        %                     plot(pLim.(strcat('xLimits',num2str(j))),BHplotLevels(1:BHplotIndex)*ones(1,2),'--g')
        %                 end
        %             end
        %         else
        %         end
        %     else
        %     end
        %
        %
        %     if settings.LayerSel.Horizon    % If horisonts to be added
        %         indexHorizont = find(strcmp(data.Horizonts(:,1),data.name{i}));
        %         if ~isempty(indexHorizont)
        %             for j = 1:plotsSubplots
        %                 subplot(1,plotsSubplots,j)
        %                 hold all
        %                 for k = 2:size(data.Horizonts,2)
        %                     if data.Horizonts{indexHorizont,k} < max(data.postprocess.(data.nameSave{i}).z) %% data.Horizonts{indexHorizont,k} < maxBH &&
        %                         plot(pLim.(strcat('xLimits',num2str(j))),data.Horizonts{indexHorizont,k}*ones(1,2),'b')
        %                         if j == plotsSubplots
        %                             txt = data.Horizonts{1,k};
        %                             text(pLim.(strcat('xLimits',num2str(j)))(2),data.Horizonts{indexHorizont,k},txt,'FontSize',6)
        %                         end
        %                     end
        %                 end
        %             end
        %         end
        %     end
        %
        %     if settings.LayerSel.Horizon || settings.LayerSel.BH
        %         saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Layer_BHonly']),'png')
        %     end
        
        %% Start selection of boundaries at plot
  
        pause(0.1)
        counter = 0;            % Counter to keep overview of number of remaining lines
        counterT = 0;           % Counter to give each click an unique ID to ensure lines are ordered
        if settings.QAmode      % Include previous defined layer boundaries
            % Search for previously defined levels in excel summary sheet and plot these in plot
            data_DL_ori = [profile.bottom(1:end-1), NaN(length(profile.bottom(1:end-1)),2), (1:length(profile.bottom(1:end-1)))'];
            
            % Check layer boundaries are in relevant zone for CPT
            RelevantIndex = yMax > data_DL_ori(:,1);
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
        if settings.runLayerSelec
            while 1 < 2     % "while" to handle click on plot options
                T = waitforbuttonpress;
                if T == 0
                    [x,y,button] = ginput(1);
                    if button == 1
                        counter = counter + 1;
                        counterT = counterT + 1;
                        if isempty(data_DL)
                            data_DL = [round(y,2), x, button, counterT];
                        else
                            data_DL(counter,:) = [round(y,2), x, button, counterT];
                        end
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
            saveas(gcf, fullfile('Output',[settings.loc{i},'_Layer']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile('Output',[settings.loc{i},'_Layer.png']), 'output', fullfile('Output',['CROP_',settings.loc{i},'_Layer.png']));
            end
        end
        close all
    else
        try                 % Search for previously defined levels in excel summary sheet and use these for routine
            data_DL_ori = [profile.bottom(1:end-1), NaN(length(profile.bottom(1:end-1)),2), (1:length(profile.bottom(1:end-1)))'];
            
            % Check layer boundaries are in relevant zone for CPT
            RelevantIndex = yMax > data_DL_ori(:,1);
            data_DL = data_DL_ori(RelevantIndex,:);
            counterT = size(data_DL,1);
            counter = counterT;
        catch
            error('No previous defined layers found / file found - cant run through data when no layers found')
        end
    end
    
    %% Save new defined layers from plot
    for II = 1:length(loopIndex)
        III = loopIndex(II);
        dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
        dat.layerLevel = sortrows(data_DL(:,1));     % Save layer levels / boundaries
    end
    
    data.postprocess.(settings.loc{i}).stratigraphy = [[0; data_DL(1:end,1)],[data_DL(1:end,1); ceil(yMax*100)/100]];
    data.postprocess.(settings.loc{i}).stratigraphy = [[1:size(data.postprocess.(settings.loc{i}).stratigraphy,1)]',data.postprocess.(settings.loc{i}).stratigraphy];
else
    data.postprocess.(settings.loc{i}).stratigraphy = nan; 
end



