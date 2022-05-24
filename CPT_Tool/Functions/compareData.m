function compareData(settings,data,calData,Folder,parameter,i)
%%%-------------------------------------------------------------------------%%%
% Function for comparing data if received data contains parameters which
% are also calculated during the process.
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     08-07-2020

test.value = {parameter};

if settings.plots && settings.savePlots
    figure(998)
    hold all
    plot(data.postprocess.(data.nameSave{i}).(test.value{1}),data.postprocess.(data.nameSave{i}).z)
    plot(calData.(test.value{1}),data.postprocess.(data.nameSave{i}).z,'--')
    
    legend('Received','Calculated','location','best')
    set(gca, 'YDir','reverse')
    xlabel(parameter)
    ylabel('Depth [m]')
    grid on
    title(['Comparison of ',parameter])
    saveas(gcf, fullfile(Folder.Figures,'Comparison',[data.nameSave{i},'_',parameter]),'png')
    close 998
end