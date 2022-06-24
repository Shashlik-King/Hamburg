function plotOutput(settings,values,data,i)
%%%-------------------------------------------------------------------------%%%
% Function for creating documentation plots and charts from the calculated
% basis.
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020

Folder.figurePath = 'Functions\FigureBasis';
Folder.Figures = 'Output';

datG = data.postprocess.(settings.loc{i});
loopIndex = data.postprocess.(settings.loc{i}).CPTavail;
loopIndex = loopIndex(~isnan(loopIndex));


color = [0.0000, 0.4470, 0.7410
    0.8500, 0.3250, 0.0980
    0.93  , 0.69  , 0.13
    0.4940, 0.1840, 0.5560
    0.4660, 0.6740, 0.1880
    0.3010, 0.7450, 0.9330
    0.6350, 0.0780, 0.1840];




legendString = cell(size(datG.stratigraphy,1),1);


% indexLayer = data.postprocess.(settings.loc{i}).indexLayer;
closeAllIndex = 1;
if settings.plots && ~isempty(loopIndex)
    %% Robertson 2009 - Equation based Fr-Qtn
    if settings.plotSwitch.Robertson2009
        figure
        Qtn = [];
        Fr = [];
        for II = 1:length(loopIndex)
            III = loopIndex(II);
            dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
            Qtn = [Qtn;dat.Qtn];
            Fr = [Fr;dat.Fr];
        end
        Robertson2009(Qtn,Fr)
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson2009']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson2009.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson2009.png']));
            end
        end
        if closeAllIndex
            close all
        end
    end
    %% Robertson 1986 - Rf,log(qc)
    if settings.plotSwitch.Robertson1986_Rf
        figure      % Rf–qc
        hold all
        I = imread(fullfile(Folder.figurePath,'Robertson_1986_Rf.JPG'));
        image('CData',I,'XData',[0 8],'YData',[3 0])
        clear legendScat
        for j = 1:size(datG.stratigraphy,1)        % Loop over layer
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                yVal = log10(dat.qc(idx))+1;
                yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                legendScat(j) = scatter(dat.Rf(idx),yVal,6,'MarkerEdgeColor',color(j,:),'MarkerFaceColor',color(j,:));
            end
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([0 8])
        ylim([0 3])
        yticks([0 1 2 3])
        yticklabels({'0.1','1','10','100'})
        xlabel('Friction ratio, R_f [%]')
        ylabel('Cone resistance, q_c [MPa]')
        title('Robertson 1986 Rf')
        legend(legendScat',legendString,'location','eastoutside')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1986_Rf']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1986_Rf.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1986_Rf.png']));
            end
        end
        if closeAllIndex
            close all
        end
    end
    
    %% Robertson 1990 - Normalized CPT (SBTn) charts Qt–Fr and Qt-Bq
    % Qt–Fr     - All in one chart
    if settings.plotSwitch.Robertson1990_Fr
        figure
        hold all
        I = imread(fullfile(Folder.figurePath,'Robertson_1990_normFr.png'));
        image('CData',I,'XData',[0 2],'YData',[3 0])
        clear legendScat
        for j = 1:size(datG.stratigraphy,1)        % Loop over layer
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                xVal = log10(dat.Fr(idx))+1;
                yVal = log10(dat.Qtn(idx));
                xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                legendScat(j) = scatter(xVal,yVal,6,'MarkerEdgeColor',color(j,:),'MarkerFaceColor',color(j,:));
            end
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
        legend(legendScat',legendString,'location','eastoutside')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Fr']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Fr.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1990_Fr.png']));
            end
        end
        if closeAllIndex
            close all
        end
        % Qt–Fr     - Per layer
        %I = imread(fullfile(Folder.figurePath,'Robertson_1990_normFr.png'));
        clear legendScat
        if size(datG.stratigraphy,1) <= 12     % If all plots can be in one chart
            column = ceil(sqrt(size(datG.stratigraphy,1)));
            row = ceil(size(datG.stratigraphy,1)/column);
            plotLayer = 1;
            plotIndex = [1,size(datG.stratigraphy,1)];
        else
            column = 4;
            row = 3;
            plotLayer = ceil(size(datG.stratigraphy,1)/12);
            plotIndex = sort([[1:12:12*plotLayer],[12:12:12*plotLayer-1],size(datG.stratigraphy,1)]);
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
                
                for II = 1:length(loopIndex)
                    III = loopIndex(II);
                    dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                    idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                    xVal = log10(dat.Fr(idx))+1;
                    yVal = log10(dat.Qtn(idx));
                    xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                    yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                    scatter(xVal,yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                        'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
                end
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
                saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Fr_Layer_',num2str(k)]),'png')
                if settings.crop
                    RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Fr_Layer_',num2str(k),'.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1990_Fr_Layer_',num2str(k),'.png']));
                end
            end
        end
        if closeAllIndex
            close all
        end
    end
    
    % Qt-Bq
    if settings.plotSwitch.Robertson1990_Bq
        clear legendScat
        figure
        hold all
        I = imread(fullfile(Folder.figurePath,'Robertson_1990_normBq.png'));
        image('CData',I,'XData',[-0.6 1.4],'YData',[3 0])
        for j = 1:size(datG.stratigraphy,1)
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                yVal = log10(dat.Qtn(idx));
                yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                legendScat(j) = scatter(dat.Bq(idx),yVal,4,'filled','MarkerFaceColor',color(j,:),'MarkerEdgeColor',color(j,:),...
                    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
            end
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([-0.6 1.4])
        ylim([0 3])
        yticks([0 1 2 3])
        yticklabels({'1','10','100','1000'})
        xlabel('B_q [%]')
        ylabel('Q_t [-]')
        title('Robertson 1990 Normalized')
        legend(legendScat',legendString,'location','eastoutside')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Bq']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Bq.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1990_Bq.png']));
            end
        end
        if closeAllIndex
            close all
        end
        
        % Qt–Bq     - Per layer
        clear legendScat
        if size(datG.stratigraphy,1) <= 12     % If all plots can be in one chart
            column = ceil(sqrt(size(datG.stratigraphy,1)));
            row = ceil(size(datG.stratigraphy,1)/column);
            plotLayer = 1;
            plotIndex = [1,size(datG.stratigraphy,1)];
        else
            column = 4;
            row = 3;
            plotLayer = ceil(size(datG.stratigraphy,1)/12);
            plotIndex = sort([[1:12:12*plotLayer],[12:12:12*plotLayer-1],size(datG.stratigraphy,1)]);
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
                image('CData',I,'XData',[-0.6 1.4],'YData',[3 0])
                
                for II = 1:length(loopIndex)
                    III = loopIndex(II);
                    dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                    idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                    yVal = log10(dat.Qtn(idx));
                    yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                    scatter(dat.Bq(idx),yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                        'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
                end
                xlim([-0.6 1.4])
                ylim([0 3])
                yticks([0 1 2 3])
                yticklabels({'1','10','100','1000'})
                xlabel('Normalised pore pressure, B_q [%]')
                ylabel('Q_t [-]')
            end
            if settings.savePlots
                saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Bq_Layer_',num2str(k)]),'png')
                if settings.crop
                    RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_Bq_Layer_',num2str(k),'.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1990_Bq_Layer_',num2str(k),'.png']));
                end
            end
        end
        if closeAllIndex
            close all
        end
    end
    %% Robertson 1986 / 2010 - Non-normalized CPT SBT chart
    if settings.plotSwitch.Robertson1986
        figure
        hold all
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Robertson1986_2010_nonNorm.png'));
        image('CData',I,'XData',[0.1 10],'YData',[1000 1.64])
        %scatter(data.postprocess.(settings.loc{i}).Rf,data.postprocess.(settings.loc{i}).qc./values.P_a)
        for j = 1:size(datG.stratigraphy,1)
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                legendScat(j) = scatter(dat.Rf(idx),dat.qc(idx)./values.P_a,4,'filled','MarkerFaceColor',color(j,:),'MarkerEdgeColor',color(j,:),...
                    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
            end
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([0.1 10])
        ylim([1 1000])
        xlabel('Friction Ratio, R_f')
        ylabel('Cone Resistance, q_c/values.P_a')
        title('Robertson 1986 / 2010 Non-normalized')
        legend(legendScat',legendString,'location','eastoutside')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1986']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1986.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1986.png']));
            end
        end
        if closeAllIndex
            close all
        end
    end
    %% Robertson 1990 / 2010 - Normalized CPT (SBTn) chart, Fr-Qtn
    if settings.plotSwitch.Robertson1990_2010
        figure
        hold all
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Robertson1990_2010_norm.png'));
        image('CData',I,'XData',[0.1 10],'YData',[1000 1.64])
        for j = 1:size(datG.stratigraphy,1)
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                legendScat(j) = scatter(dat.Fr(idx),dat.Qtn(idx),4,'filled','MarkerFaceColor',color(j,:),'MarkerEdgeColor',color(j,:),...
                    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
            end
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([0.1 10])
        ylim([1 1000])
        xlabel('Normalised Friction Ratio, F_r [%]')
        ylabel('Q_t [-]')
        title('Robertson 1990 / 2010 Normalized')
        legend(legendScat',legendString,'location','eastoutside')
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_2010']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Robertson1990_2010.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Robertson1990_2010.png']));
            end
        end
        if closeAllIndex
            close all
        end
    end
    %% Jardine
    if settings.plotSwitch.Jardine
        I = imread(fullfile(Folder.figurePath,'JardineRobertson.png'));
        if size(datG.stratigraphy,1) <= 12     % If all plots can be in one chart
            column = ceil(sqrt(size(datG.stratigraphy,1)));
            row = ceil(size(datG.stratigraphy,1)/column);
            plotLayer = 1;
            plotIndex = [1,size(datG.stratigraphy,1)];
        else
            column = 4;
            row = 3;
            plotLayer = ceil(size(datG.stratigraphy,1)/12);
            plotIndex = sort([[1:12:12*plotLayer],[12:12:12*plotLayer-1],size(datG.stratigraphy,1)]);
        end
        
        
        %data.postprocess.(settings.loc{i}).LayersUnitSelf = data.Layering.LayerSelectionData(find(strcmp(data.Layering.LayerSelectionData(:,1),settings.loc{i})),5);
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
                
                for II = 1:length(loopIndex)
                    III = loopIndex(II);
                    dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                    idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                    xVal = log10(dat.Fr(idx))+1;
                    yVal = log10(dat.Qtn(idx));
                    xVal(imag(xVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                    yVal(imag(yVal)~=0) = nan;  % Change all imaginary numbers from the vector to NaN
                    scatter(xVal,yVal,4,'filled','MarkerFaceColor','b','MarkerEdgeColor','b',...
                        'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
                end
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
                saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Jardine_',num2str(k)]),'png')
                if settings.crop
                    RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Jardine_',num2str(k),'.png']), 'output', fullfile(Folder.Figures,['CROP_',settings.loc{i},' Jardine_',num2str(k),'.png']));
                end
            end
        end
        if closeAllIndex
            close all
        end
    end
    %% Schneider 2008
    if settings.plotSwitch.Schneider
        figure
        hold all
        set(gca, 'YScale', 'log')
        I = imread(fullfile(Folder.figurePath,'Schneider2008.png'));
        image('CData',I,'XData',[-2 10],'YData',[1000 1.64])
        for j = 1:size(datG.stratigraphy,1)
            for II = 1:length(loopIndex)
                III = loopIndex(II);
                dat = data.postprocess.(settings.loc{i}).(strcat('SCPT',num2str(III)));
                idx = and(dat.z>datG.stratigraphy(j,2),dat.z<=datG.stratigraphy(j,3));
                legendScat(j) = scatter(dat.delta_u(idx)./dat.sigma_v0_eff(idx),dat.Qt(idx),4,'filled','MarkerFaceColor',color(j,:),'MarkerEdgeColor',color(j,:),...
                    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
            end
            legendString{j} = ['Layer ',num2str(j)];
        end
        xlim([-2 10])
        ylim([1 1000])
        xlabel('\Delta u / \sigma_v_{eff} [-]')
        ylabel('Q_t [-]')
        title('Schneder 2008')
        %             legend(legendString,'location','eastoutside')
        
        if settings.savePlots
            saveas(gcf, fullfile(Folder.Figures,[settings.loc{i},' Schneider']),'png')
            if settings.crop
                RemoveWhiteSpace([], 'file', fullfile(Folder.Figures,[settings.loc{i},' Schneider.png']), 'output', fullfile(Folder.Figures,['CROP',settings.loc{i},' Schneider.png']));
            end
        end
    end
    close all
end





