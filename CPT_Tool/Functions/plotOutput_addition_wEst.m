function plotOutput_addition(settings,Folder,values,data,i,DL,DLval)
%%%-------------------------------------------------------------------------%%%
% Function for creating plot with strength, stiffness parameters, etc.
% DL: Design Lines at plot switch
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by FKMV                     23-07-2020
% Updated by CONN                   14-08-2020

color = [0.0000, 0.4470, 0.7410
         0.8500, 0.3250, 0.0980
         0.4940, 0.1840, 0.5560
         0.4660, 0.6740, 0.1880
         0.3010, 0.7450, 0.9330
         0.6350, 0.0780, 0.1840];


if settings.plots
    yMax = ceil(max(data.postprocess.(data.nameSave{i}).z));
    yMin = floor(min(data.postprocess.(data.nameSave{i}).z));
    figure('units','normalized','outerposition',[0 0 1 1])
    % Subplot with undrained shear strength (cu)
    h(1)=subplot(1,5,1);
    hold all
    for j = 1:length(settings.NktLegend)
        scatter(data.postprocess.(data.nameSave{i}).cu.values(:,j)*1000,data.postprocess.(data.nameSave{i}).z,6,'filled','Color',color(j,:))
        max_cu(j) = max(data.postprocess.(data.nameSave{i}).cu.values(:,j)*1000);
    end
    plot([0 10000],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    set(gca, 'YDir','reverse')
    if DL   % If design lines to be added
        DesignLines('cu',DLval,settings,1000) % FUNCTION IN BOTTOM OF SCRIPT
    end
    ylim([yMin, yMax])
    ylabel('Depth [m]')
    xlabel('c_u [kPa]')
    if ~all(isnan(max_cu))
        if max(max_cu)*1.1 <= 0
            xlim([0 100])
        else
            xlim([0 max(max_cu)*1.1])
        end
    end
    h_legend=legend(settings.NktLegend);
    set(h_legend, 'location', 'southoutside')
    legend_size = get(h_legend, 'position');
    legend boxoff 
    grid on
    hold off
    
    % Subplot with friction angle (phi)
    h(2)=subplot(1,5,2);
    hold on
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        for k = 1:length(settings.method.phi)
            scatter(data.postprocess.(data.nameSave{i}).phi.values(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2),settings.method.phi(k)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','Color',color(k,:));
        end
    end
    plot([0 100],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    set(gca, 'YDir','reverse')
    if DL   % If design lines to be added
        DesignLines('phi',DLval,settings,1) % FUNCTION IN BOTTOM OF SCRIPT
    end
    ylim([yMin, yMax])
    ylabel('Depth [m]')
    xlabel('\phi'' [°]')
    for k = 1:length(settings.method.phi)
        legendstr_phi{k} = char(data.postprocess.(data.nameSave{i}).phi.methods(settings.method.phi(k)));
        legend(legendstr_phi,'Location', 'southoutside');  
    end
    legend boxoff 
    xlim([20 55])
    grid on
    hold off
    
    % Subplot with Gmax
    h(3)=subplot(1,5,3);
    hold on
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        for k = 1:length(settings.method.Gmax)
            scatter(data.postprocess.(data.nameSave{i}).Gmax.values(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2),settings.method.Gmax(k)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','Color',color(k,:))
        end
    end
    %plot([0 max(data.postprocess.(data.nameSave{i}).G_max)*1.1],data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2),'r')
    plot([0 ceil(max(max(data.postprocess.(data.nameSave{i}).Gmax.values))/100)*100],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    %plot([0 100],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    set(gca, 'YDir','reverse')
    if DL   % If design lines to be added
        DesignLines('Gmax',DLval,settings,1) % FUNCTION IN BOTTOM OF SCRIPT
    end
    ylim([yMin, yMax])
    xlim([[0 ceil(max(max(data.postprocess.(data.nameSave{i}).Gmax.values))/100)*100]])
    ylabel('Depth [m]')
    xlabel('G_{max} [MPa]')
%     if max(data.postprocess.(data.nameSave{i}).G_max)*1.1 <= 0
%         xlim([0 100])
%     else
%         xlim([0 max(data.postprocess.(data.nameSave{i}).G_max)*1.1])
%     end
    for k = 1:length(settings.method.Gmax)
        legendstr_Gmax{k} = char(data.postprocess.(data.nameSave{i}).Gmax.methods(settings.method.Gmax(k)));
        legend(legendstr_Gmax,'Location', 'southoutside')
    end
    legend boxoff 
    grid on
    hold off
    
    % Subplot with OCR
    h(4)=subplot(1,5,4);
    hold on
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
    %    plot(data.postprocess.(data.nameSave{i}).OCR(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),'b')
        for k = 1:length(settings.method.OCR)
            scatter(data.postprocess.(data.nameSave{i}).OCR.values(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2),settings.method.OCR(k)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','Color',color(k,:))
        end
    end
    plot([0 100],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    set(gca, 'YDir','reverse')
    if DL   % If design lines to be added
        DesignLines('OCR',DLval,settings,1) % FUNCTION IN BOTTOM OF SCRIPT
    end
    ylim([yMin, yMax])
    ylabel('Depth [m]')
    xlabel('OCR [-]')
    for k = 1:length(settings.method.OCR)
        legendstr_OCR{k} = char(data.postprocess.(data.nameSave{i}).OCR.methods(settings.method.OCR(k)));
        legend(legendstr_OCR,'Location', 'southoutside')
    end
    legend boxoff 
    xlim([0 10])
    grid on
    hold off
    
    % Subplot with Id
    h(5)=subplot(1,5,5);
    hold on
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
    %    plot(data.postprocess.(data.nameSave{i}).OCR(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),'b')
        for k = 1:length(settings.method.Id)
            scatter(data.postprocess.(data.nameSave{i}).Id.values(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2),settings.method.Id(k)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),6,'filled','Color',color(k,:))
        end
    end
    plot([0 100],[data.postprocess.(data.nameSave{i}).layerLevel*ones(1,2)]','r')
    if 1
        data.postprocess.(data.nameSave{i}).LayersUnitSelf = data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),data.nameSave{i})),5);
        unitLayerLvl = [yMin;data.postprocess.(data.nameSave{i}).layerLevel; yMax];
        for jjj = 1:size(data.postprocess.(data.nameSave{i}).indexLayer,1)
            txt = data.postprocess.(data.nameSave{i}).LayersUnitSelf{jjj};
            text(101,(unitLayerLvl(jjj)+unitLayerLvl(jjj+1))/2,txt,'FontSize',8)

        end
    end
    set(gca, 'YDir','reverse')
    if DL   % If design lines to be added
        DesignLines('Id',DLval,settings,1) % FUNCTION IN BOTTOM OF SCRIPT
    end
    ylim([yMin, yMax])
    ylabel('Depth [m]')
    xlabel('I_D [%]')
    for k = 1:length(settings.method.Id)
        legendstr_Id{k} = char(data.postprocess.(data.nameSave{i}).Id.methods(settings.method.Id(k)));
        legend(legendstr_Id,'Location', 'southoutside')
    end
    legend boxoff 
    xlim([0 100])
    grid on
    hold off

    
    
    sgtitle(data.nameSave{i},'Interpreter','none')

    %% Aligning bottom edge of subplots
    m=zeros(length(h),4);
    for k=1:length(h)
        m(k,:) = get(h(k),'Position');
    end
    m(:,4) = min(m(:,4));
    m(:,2) = max(m(:,2));
    for k=1:length(h)
        set(h(k),'Position',m(k,:));
    end
    
    
    % Save the final figure
    if settings.savePlots
%         saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Properties']),'png')
        exportgraphics(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Properties.png']),'BackgroundColor','none')
    end
    if abs(settings.closePlots) == 1  
        close all
    end
end
end

function DesignLines(var,DLval,settings,factor)
k = 1; % Only plot if only 1 method per parameter is used
        plotDL_BE    = DLval.(var).TB{1,settings.method.(var)(k)}.BE;
        %plotDL_LB    = DLval.(var).TB{1,settings.method.(var)(k)}.LB;
        plotDL_CLB   = DLval.(var).TB{1,settings.method.(var)(k)}.CLB;
        plotDL_CUB   = DLval.(var).TB{1,settings.method.(var)(k)}.CUB;
        %plotDL_UB    = DLval.(var).TB{1,settings.method.(var)(k)}.UB;
        for j = 2:size(DLval.(var).TB)
            plotDL_BE = [plotDL_BE;DLval.(var).TB{j,settings.method.(var)(k)}.BE];
            %plotDL_LB = [plotDL_LB;DLval.(var).TB{j,settings.method.(var)(k)}.LB];
            plotDL_CLB = [plotDL_CLB;DLval.(var).TB{j,settings.method.(var)(k)}.CLB];
            plotDL_CUB = [plotDL_CUB;DLval.(var).TB{j,settings.method.(var)(k)}.CUB];
            %plotDL_UB = [plotDL_UB;DLval.(var).TB{j,settings.method.(var)(k)}.UB];
        end
        plot(plotDL_BE*factor,DLval.(var).yLevels,'k')
        %plot(plotDL_CLB*factor,DLval.(var).yLevels,'k:')
        %plot(plotDL_CUB*factor,DLval.(var).yLevels,'k:')
end