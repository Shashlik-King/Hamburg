function plotOutput(settings,Folder,values,data,i)
%%%-------------------------------------------------------------------------%%%
% Function for creating documentation plots and charts from the calculated
% basis.
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020

legendString = cell(size(data.postprocess.(data.nameSave{i}).indexLayer,1),1);
indexLayer = data.postprocess.(data.nameSave{i}).indexLayer;
closeAllIndex = 1; 
if settings.plots
    %% Plot raw qc value directly from AGS data
    figure
    hold all
    for j = 1:size(data.postprocess.(data.nameSave{i}).pushIndex,1)
        plot(data.postprocess.(data.nameSave{i}).qc(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).pushIndex(j,1):data.postprocess.(data.nameSave{i}).pushIndex(j,2)),'b')
    end
    set(gca, 'YDir','reverse')
    xlabel('q_c [MPa]')
    ylabel('Depth [m]')
    title('Raw measured qc')
    grid on
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' SCPT']),'png')
    end
    if closeAllIndex
        close all 
    end
    
    %% Smoothening plot
    if settings.smooth
        for j = 1:length(settings.Smoothened.Vector)   % Loop over all smoothened parameters
            try
                figure
                hold all
                plot(data.postInitial.(data.nameSave{i}).(settings.Smoothened.Vector{j}),data.postInitial.(data.nameSave{i}).z)
                plot(data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).BE,data.postInitial.(data.nameSave{i}).z)
                plot(data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).LB,data.postInitial.(data.nameSave{i}).z)
                plot(data.Smoothened.(data.nameSave{i}).(settings.Smoothened.Vector{j}).UB,data.postInitial.(data.nameSave{i}).z)
                set(gca, 'YDir','reverse')
                legend('Raw','BE','LB','UB')
                xlabel('Res')
                ylabel(['Depth [', data.Basis.(data.nameSave{i}).SCPT{2,4} ,']'])
                title('SCPT - Smooth')
                grid on
                if settings.savePlots
                    saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' SCPT_smooth']),'png')
                end
                if closeAllIndex
        close all 
    end
            catch
            end
        end
    end
    
    
    %% Robertson 2009 - Equation based Fr-Qtn
    figure
    Robertson2009(data.postprocess.(data.nameSave{i}).Qtn,data.postprocess.(data.nameSave{i}).Fr)
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson2009']),'png')
    end
    if closeAllIndex
        close all 
    end
    
    %% Robertson 1986 - CPT (SBT) charts Fr–Fr and Qt-Bq
    %     figure      % Rf–qc
    %     hold all
    %     set(gca, 'YScale', 'log')
    %     I = imread(fullfile(Folder.figurePath,'Robertson_1986_Rf.JPG'));
    %     image('CData',I,'XData',[0 8],'YData',[100 0.1])
    %     for j = 1:size(indexLayer,1)
    %         scatter(data.postprocess.(data.nameSave{i}).Rf(indexLayer(j,1):indexLayer(j,2)),data.postprocess.(data.nameSave{i}).qc(indexLayer(j,1):indexLayer(j,2))) % Edit. SDNN, from Qt to Qtn
    %         legendString{j} = ['Layer ',num2str(j)];
    %     end
    %     xlim([0 8])
    %     ylim([0.1 100])
    %     xlabel('Friction ratio, R_f [%]')
    %     ylabel('Cone resistance, q_c [MPa]')
    %     title('Robertson 1986 Rf')
    %     legend(legendString,'location','eastoutside')
    %     if settings.savePlots
    %         saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1986_Rf']),'png')
    %     end
    %
    figure      % Rf–qc
    hold all
    I = imread(fullfile(Folder.figurePath,'Robertson_1986_Rf.JPG'));
    image('CData',I,'XData',[0 8],'YData',[3 0])
    for j = 1:size(indexLayer,1)
        yVal = log10(data.postprocess.(data.nameSave{i}).qc(indexLayer(j,1):indexLayer(j,2)))+1;
        yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
        scatter(data.postprocess.(data.nameSave{i}).Rf(indexLayer(j,1):indexLayer(j,2)),yVal)
        legendString{j} = ['Layer ',num2str(j)];
    end
    xlim([0 8])
    ylim([0 3])
    yticks([0 1 2 3])
    yticklabels({'0.1','1','10','100'})
    xlabel('Friction ratio, R_f [%]')
    ylabel('Cone resistance, q_c [MPa]')
    title('Robertson 1986 Rf')
    legend(legendString,'location','eastoutside')
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1986_Rf']),'png')
    end
    if closeAllIndex
        close all 
    end
    
    
    %% Robertson 1990 - Normalized CPT (SBTn) charts Qt–Fr and Qt-Bq
    % Qt–Fr     - All in one chart
    figure
    hold all
    I = imread(fullfile(Folder.figurePath,'Robertson_1990_normFr.png'));
    image('CData',I,'XData',[0 2],'YData',[3 0])
    for j = 1:size(indexLayer,1)
        xVal = log10(data.postprocess.(data.nameSave{i}).Fr(indexLayer(j,1):indexLayer(j,2)))+1;
        yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
        xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
        yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
        scatter(xVal,yVal)
        legendString{j} = ['Layer ',num2str(j)];
    end
    xlim([0 2])
    ylim([0 3])
    xticks([0 1 2])
    xticklabels({'0.1','1','10'})
    yticks([0 1 2 3])
    yticklabels({'1','10','100','1000'})
    xlabel('Normalised Friction Ratio, F_r [%]')
    ylabel('Q_t [-]')
    title('Robertson 1990 Normalized')
    legend(legendString,'location','eastoutside')
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1990_Fr']),'png')
    end
    if closeAllIndex
        close all 
    end
    % Qt–Fr     - Per layer
    %I = imread(fullfile(Folder.figurePath,'Robertson_1990_normFr.png'));
    if size(indexLayer,1) <= 12     % If all plots can be in one chart
        column = ceil(sqrt(size(indexLayer,1)));
        row = ceil(size(indexLayer,1)/column);
        plotLayer = 1;
        plotIndex = 1:size(indexLayer,1);
    else
        column = 4;
        row = 3;
        plotLayer = ceil(size(indexLayer,1)/12);
        plotIndex = sort([[1:12:12*plotLayer],[12:12:12*plotLayer-1],size(indexLayer,1)]);
    end
    for k = 1:plotLayer
        figure
        frame_h = get(handle(gcf),'JavaFrame');
        set(frame_h,'Maximized',1);
        pause(0.1);
        hold all
        for j = plotIndex(k*2-1):plotIndex(k*2)
            subplot(row,column,j-(k-1)*row*column)
            hold all
            title(['Layer ',num2str(j)])
            image('CData',I,'XData',[0 2],'YData',[3 0])
            xVal = log10(data.postprocess.(data.nameSave{i}).Fr(indexLayer(j,1):indexLayer(j,2)))+1;
            yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
            xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
            yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
            scatter(xVal,yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
            xlim([0 2])
            ylim([0 3])
            xticks([0 1 2])
            xticklabels({'0.1','1','10'})
            yticks([0 1 2 3])
            yticklabels({'1','10','100','1000'})
            xlabel('F_r [%]')
            ylabel('Q_t [-]')
        end
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1990_Fr_Layer_',num2str(k)]),'png')
        end
    end
    if closeAllIndex
        close all 
    end
    % Qt-Bq
    figure
    hold all
    I = imread(fullfile(Folder.figurePath,'Robertson_1990_normBq.png'));
    image('CData',I,'XData',[-0.6 1.4],'YData',[3 0])
    for j = 1:size(indexLayer,1)
        yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
        yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
        scatter(data.postprocess.(data.nameSave{i}).Bq(indexLayer(j,1):indexLayer(j,2)),yVal)
        legendString{j} = ['Layer ',num2str(j)];
    end
    xlim([-0.6 1.4])
    ylim([0 3])
    yticks([0 1 2 3])
    yticklabels({'1','10','100','1000'})
    xlabel('B_q [%]')
    ylabel('Q_t [-]')
    title('Robertson 1990 Normalized')
    legend(legendString,'location','eastoutside')
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1990_Bq']),'png')
    end
    if closeAllIndex
        close all 
    end
    
    % Qt–Fr     - Per layer
    for k = 1:plotLayer
        figure
        frame_h = get(handle(gcf),'JavaFrame');
        set(frame_h,'Maximized',1);
        pause(0.1);
        hold all
        for j = plotIndex(k*2-1):plotIndex(k*2)
            subplot(row,column,j-(k-1)*row*column)
            hold all
            title(['Layer ',num2str(j)])
            image('CData',I,'XData',[-0.6 1.4],'YData',[3 0])
            yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
            yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
            scatter(data.postprocess.(data.nameSave{i}).Bq(indexLayer(j,1):indexLayer(j,2)),yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
            xlim([-0.6 1.4])
            ylim([0 3])
            yticks([0 1 2 3])
            yticklabels({'1','10','100','1000'})
            xlabel('Normalised pore pressure, B_q [%]')
            ylabel('Q_t [-]')
        end
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1990_Bq_Layer_',num2str(k)]),'png')
        end
    end
    if closeAllIndex
        close all 
    end
    %% Robertson 1986 / 2010 - Non-normalized CPT SBT chart
    figure
    hold all
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    I = imread(fullfile(Folder.figurePath,'Robertson1986_2010_nonNorm.png'));
    image('CData',I,'XData',[0.1 10],'YData',[1000 1.64])
    %scatter(data.postprocess.(data.nameSave{i}).Rf,data.postprocess.(data.nameSave{i}).qc./values.P_a)
    for j = 1:size(indexLayer,1)
        scatter(data.postprocess.(data.nameSave{i}).Rf(indexLayer(j,1):indexLayer(j,2)),data.postprocess.(data.nameSave{i}).qc(indexLayer(j,1):indexLayer(j,2))./values.P_a)
        legendString{j} = ['Layer ',num2str(j)];
    end
    xlim([0.1 10])
    ylim([1 1000])
    xlabel('Friction Ratio, R_f')
    ylabel('Cone Resistance, q_c/values.P_a')
    title('Robertson 1986 / 2010 Non-normalized')
    legend(legendString,'location','eastoutside')
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1986']),'png')
    end
    if closeAllIndex
        close all 
    end
    
    %% Robertson 1990 / 2010 - Normalized CPT (SBTn) chart, Qt - F
    % Fr-Qtn
    figure
    hold all
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    I = imread(fullfile(Folder.figurePath,'Robertson1990_2010_norm.png'));
    image('CData',I,'XData',[0.1 10],'YData',[1000 1.64])
    for j = 1:size(indexLayer,1)
        scatter(data.postprocess.(data.nameSave{i}).Fr(indexLayer(j,1):indexLayer(j,2)),data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)))
        legendString{j} = ['Layer ',num2str(j)];
    end
    xlim([0.1 10])
    ylim([1 1000])
    xlabel('Normalised Friction Ratio, F_r [%]')
    ylabel('Q_t [-]')
    title('Robertson 1990 / 2010 Normalized')
    legend(legendString,'location','eastoutside')
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Robertson1990_2010']),'png')
    end
    if closeAllIndex
        close all 
    end
    %% Jardine
    I = imread(fullfile(Folder.figurePath,'JardineRobertson.png'));
    if size(indexLayer,1) <= 12     % If all plots can be in one chart
        column = ceil(sqrt(size(indexLayer,1)));
        row = ceil(size(indexLayer,1)/column);
        plotLayer = 1;
        plotIndex = 1:size(indexLayer,1);
    else
        column = 4;
        row = 3;
        plotLayer = ceil(size(indexLayer,1)/12);
        plotIndex = sort([[1:12:12*plotLayer],[12:12:12*plotLayer-1],size(indexLayer,1)]);
    end
    if settings.calc.Unit == 2  % If based on self-defined units the plot can be dependent of the layer material
        data.postprocess.(data.nameSave{i}).LayersUnitSelf = data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),data.nameSave{i})),5);
%         for j = 1:size(data.postprocess.(data.nameSave{i}).LayersUnitSelf,1)
%             LayerUnitType{j} = settings.calc.soils{find(strcmp(data.postprocess.(data.nameSave{i}).LayersUnitSelf{j},settings.calc.soils(:,1))),2}; % Defining how to consider self-defined unit
%         end
        
        plotIndex = 1;
        indexCount = 0;
        plotCount = 0;
        subplotCount = 0;
        for j = 1:size(indexLayer,1)
            if any(strcmpi(data.postprocess.(data.nameSave{i}).LayersUnitSelf{j},{'CLAY','CLAY.S'}))
                if subplotCount == 0
                    figure
                    frame_h = get(handle(gcf),'JavaFrame');
                    set(frame_h,'Maximized',1);
                    pause(0.1);
                    hold all
                    plotCount = plotCount+1;
                end
                subplotCount = subplotCount+1;
                %for j = plotIndex(k*2-1):plotIndex(k*2)
                subplot(row,column,subplotCount)
                hold all
                title(['Layer ',num2str(j)])
                image('CData',I,'XData',[0 2],'YData',[3 0])
                xVal = log10(data.postprocess.(data.nameSave{i}).Fr(indexLayer(j,1):indexLayer(j,2)))+1;
                yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
                xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                scatter(xVal,yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
                xlim([0 2])
                ylim([0 3])
                xticks([0 1 2])
                xticklabels({'0.1','1','10'})
                yticks([0 1 2 3])
                yticklabels({'1','10','100','1000'})
                xlabel('F_r [%]')
                ylabel('Q_t [-]')
                %end
                if subplotCount == row*column
                    subplotCount = 0; 
                    if settings.savePlots
                        saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Jardine_',num2str(plotCount)]),'png')
                    end
                end
            end
            if j == size(indexLayer,1) && subplotCount > 0.5
                saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Jardine_',num2str(plotCount)]),'png')
            end
        end
    else % If based on Robertson interpretation all layers will be plotted
        data.postprocess.(data.nameSave{i}).LayersUnitSelf = data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),data.nameSave{i})),5);
        for k = 1:plotLayer
            figure
            frame_h = get(handle(gcf),'JavaFrame');
            set(frame_h,'Maximized',1);
            pause(0.1);
            hold all
            for j = plotIndex(k*2-1):plotIndex(k*2)
                subplot(row,column,j-(k-1)*row*column)
                hold all
                title(['Layer ',num2str(j)])
                image('CData',I,'XData',[0 2],'YData',[3 0])
                xVal = log10(data.postprocess.(data.nameSave{i}).Fr(indexLayer(j,1):indexLayer(j,2)))+1;
                yVal = log10(data.postprocess.(data.nameSave{i}).Qtn(indexLayer(j,1):indexLayer(j,2)));
                xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                scatter(xVal,yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
                xlim([0 2])
                ylim([0 3])
                xticks([0 1 2])
                xticklabels({'0.1','1','10'})
                yticks([0 1 2 3])
                yticklabels({'1','10','100','1000'})
                xlabel('F_r [%]')
                ylabel('Q_t [-]')
            end
            if settings.savePlots
                saveas(gcf, fullfile(Folder.Figures,[data.nameSave{i},' Jardine_',num2str(k)]),'png')
            end
        end
    end
    if closeAllIndex
        close all 
    end
    %% Schneider 2008
    if 0	% Redefine criteria if used
        figure      % Qt-Bq
        hold all
        set(gca, 'YScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Schneider2008.png'));
        image('CData',I,'XData',[-2 10],'YData',[1000 1.64])
        for j = 1:size(indexLayer,1)
            scatter(data.postprocess.(data.nameSave{i}).delta_u(indexLayer(j,1):indexLayer(j,2))./data.postprocess.(data.nameSave{i}).sigma_v0_eff(indexLayer(j,1):indexLayer(j,2)),data.postprocess.(data.nameSave{i}).Qt(indexLayer(j,1):indexLayer(j,2)))
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([-2 10])
        ylim([1 1000])
        xlabel('\Delta u / \sigma_v_{eff} [-]')
        ylabel('Q_t [-]')
        title('Schneder 2008')
        %             legend(legendString,'location','eastoutside')
    end
    
    % Close all plots if looping over multiple locations
    if settings.closePlots == 1 || and(settings.closePlots==-1,length(fieldnames(data.postprocess))>1)
        close all
    end
end





