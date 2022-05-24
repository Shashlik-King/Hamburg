function designProfile = designSoilProfilesNew(settings,Folder,Files,data,values)
%%%-------------------------------------------------------------------------%%%
excelName=fullfile(Folder.Output,'Design soil profiles.xlsx');
excelNameAll=fullfile(Folder.Output,'Design soil profilesAll.xlsx');
namesheet='strata';
inter_conf1=[10 90];    % Removing lowest 10% and highest 10% of each layer to account for outliers
ExcelLayers = data.Stratigraphy;


parameters = settings.DSPpar;

for i = 1:length(fieldnames(data.postprocess))
    clear plotDLval
    if i == 10
        test = 1; 
    end
    indexPos=find(strcmp(ExcelLayers(:,1),(data.nameSave{i})));
    Table = [{'Position'}, {'Layer'};{'-'}, {'-'};{'-'}, {'-'};num2cell((1:size(data.postprocess.(data.nameSave{i}).indexLayer,1))'),num2cell((1:size(data.postprocess.(data.nameSave{i}).indexLayer,1))')];
    Table(4:end,1) = {data.name{i}};
    layerLevels = [0;data.postprocess.(data.nameSave{i}).layerLevel;data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).indexLayer(end,2))];
    for j = 1:length(parameters)
        plotDLval.(parameters{j}).yLevels = sort([0;data.postprocess.(data.nameSave{i}).layerLevel;data.postprocess.(data.nameSave{i}).layerLevel;data.postprocess.(data.nameSave{i}).z(data.postprocess.(data.nameSave{i}).indexLayer(end,2))]);
        delta = 1;      % Sublayer thickness for analysis
        kMax = size(data.postprocess.(data.nameSave{i}).(parameters{j}).values,2);
        for k = 1:kMax  % Loop over different methodologies for same parameter
            %value = nan(size(data.postprocess.(data.nameSave{i}).indexLayer,1),1);
            levelLayer = [0;data.postprocess.(data.nameSave{i}).layerLevel; max(data.postprocess.(data.nameSave{i}).z)];
            for ii=1:size(data.postprocess.(data.nameSave{i}).indexLayer,1) % Loop over each layer
                
                layerTopLvl = levelLayer(ii);
                layerBotLvl = levelLayer(ii+1);
                idx = data.postprocess.(data.nameSave{i}).indexLayer(ii,1):data.postprocess.(data.nameSave{i}).indexLayer(ii,2); % Index to consider
                
                steps = ceil((layerBotLvl-layerTopLvl)/delta);
                val = nan(steps,1);
                x = nan(steps,1);
                y = nan(steps,1);

                for JJ = 1:steps
                   
                    if JJ == steps
                        %idxSubLayer = and(data.postprocess.(data.nameSave{i}).z >= layerTopLvl , data.postprocess.(data.nameSave{i}).z < layerBotLvl);
                        idxSubLayer = and(data.postprocess.(data.nameSave{i}).z >= layerTopLvl+(JJ-1)*delta , data.postprocess.(data.nameSave{i}).z < layerBotLvl);
                        x(JJ) = ((layerTopLvl+(JJ-1)*delta)+layerBotLvl)/2;  % Depth
                    else
                        idxSubLayer = and(data.postprocess.(data.nameSave{i}).z >= layerTopLvl+(JJ-1)*delta , data.postprocess.(data.nameSave{i}).z < layerTopLvl+JJ*delta);
                        x(JJ) = ((layerTopLvl+(JJ-1)*delta)+(layerTopLvl+JJ*delta))/2;  % Depth
                    end
                    %idxSubLayer = idxStart:idxEnd;
                    
                    val(JJ) = round(mean(rmmissing(rmoutliers(data.postprocess.(data.nameSave{i}).(parameters{j}).values(idxSubLayer,k),'percentiles',inter_conf1))),6);
                    try
                    
                    catch
                        test  = 1; 
                    end
                    y(JJ) = val(JJ);  % Value representative for depth
                end

                delIdx = isnan(y);
                y(delIdx) = [];
                x(delIdx) = [];

                
                if steps==1     % If only 1 point available for the layer
                    SD = 0;     % TO BE CHANGED
                    if isempty(y)
                        plotDLval.(parameters{j}).TB{ii,k}.BE = [0; 0];
                    else
                        plotDLval.(parameters{j}).TB{ii,k}.BE = [y; y];
                    end
                    plotDLval.(parameters{j}).TB{ii,k}.CLB      = plotDLval.(parameters{j}).TB{ii,k}.BE-2*SD;
                    plotDLval.(parameters{j}).TB{ii,k}.CUB      = plotDLval.(parameters{j}).TB{ii,k}.BE+2*SD;
                else
                    p = polyfit(x,y,1);
                    plotDLval.(parameters{j}).poyVal{ii,k} = p; % Constants for linear fit 
                    f = polyval(p,x(:));
                    T = table(x,y,f,y-f,'VariableNames',{'X','Y','Fit','FitError'});
                    plotDLval.(parameters{j}).TB{ii,k}.BE       = (layerLevels(ii:ii+1)*p(1)+p(2));     % Top bottom values for plot
                    
                    % CALCULATE STATISTICS
                    SD = sqrt(sum((y-mean(y)).^2)/(length(y)-1));
                    
                    %plotDLval.(parameters{j}).TB{ii,k}.LB       = ;
                    plotDLval.(parameters{j}).TB{ii,k}.CLB      = plotDLval.(parameters{j}).TB{ii,k}.BE-2*SD;
                    plotDLval.(parameters{j}).TB{ii,k}.CUB      = plotDLval.(parameters{j}).TB{ii,k}.BE+2*SD;
                    %plotDLval.(parameters{j}).TB{ii,k}.UB       = ;
                end

                
            end
            test = 1;
        end
    end
    %     designProfile.(data.nameSave{i}) = Table;
try
    plotOutput_addition_wEst(settings,Folder,values,data,i,1,plotDLval)
catch ME
    test = 1; 
end

end

% togetherAll = [];
% for i = 1:length(fieldnames(data.postprocess))
%     if i == 1
%         togetherAll = designProfile.(data.nameSave{i});
%     else
%         if isequal(designProfile.(data.nameSave{i})(1:3,:),togetherAll(1:3,:))
%             togetherAll = [togetherAll; designProfile.(data.nameSave{i})(4:end,:)];
%         else
%             disp('Missing position')
%         end
%     end
% end
%
% writecell(togetherAll,excelNameAll,'Sheet','Profiles')





