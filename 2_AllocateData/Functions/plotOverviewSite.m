function plotOverviewSite(settings,data,Folder)
%%%-------------------------------------------------------------------------%%%
% Function for creating site overview for received data
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     14-08-2020

if settings.plot.Overview && settings.runAll
    xscatter = NaN(length(data.nameSave),1);
    yscatter = NaN(length(data.nameSave),1);
    for i = 1:length(data.nameSave)
        try
            xdata = data.postprocess.(data.nameSave{i}).Coord_E{1};
            ydata = data.postprocess.(data.nameSave{i}).Coord_N{1};
            xdata(regexp(xdata,','))=[];
            ydata(regexp(ydata,','))=[];
            xscatter(i,1) = str2double(xdata);
            yscatter(i,1) = str2double(ydata);
        catch
            xscatter(i,1) = data.postprocess.(data.nameSave{i}).Coord_E;
            yscatter(i,1) = data.postprocess.(data.nameSave{i}).Coord_N;
        end
    end
    figure;
    pause(0.00001);
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);
    hold all
    scatter(xscatter,yscatter,'+')
    grid on
    xlabel('Easting [m]')
    ylabel('Northing [m]')
    
    % Add text
    xLimits = get(gca,'XLim');  %# Get the range of the x axis
    yLimits = get(gca,'YLim');  %# Get the range of the y axis
    dx = (xLimits(2)-xLimits(1))*0.01;
    dy = (yLimits(2)-yLimits(1))*0.01;
    text(xscatter+dx,yscatter+dy,data.name,'FontSize',5)
    xlim([xLimits(1) xLimits(2)+(xLimits(2)-xLimits(1))*0.1])
    if settings.savePlots
        saveas(gcf, fullfile(Folder.Figures,'General/SiteOverview'),'png')
    end
    
    % Close all plots if looping over multiple locations
    if settings.closePlots == 1 || and(settings.closePlots==-1,length(fieldnames(data.Raw))>1)
        close all
    end
end


