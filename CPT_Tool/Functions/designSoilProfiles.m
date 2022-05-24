function designProfile = designSoilProfiles(settings,Folder,Files,data,values)
%%%-------------------------------------------------------------------------%%%
excelName=fullfile(Folder.Output,'Design soil profiles.xlsx');
excelNameAll=fullfile(Folder.Output,'Design soil profilesAll.xlsx');
namesheet='strata';
inter_conf1=[10 90];    % Removing lowest 10% and highest 10% of each layer to account for outliers
ExcelLayers = data.Stratigraphy;

parameters = settings.DSPpar;
 
for i = 1:length(fieldnames(data.postprocess))
    indexPos=find(strcmp(ExcelLayers(:,1),(data.nameSave{i})));
    Table = [{'Position'}, {'Layer'};{'-'}, {'-'};{'-'}, {'-'};num2cell((1:size(data.postprocess.(data.nameSave{i}).indexLayer,1))'),num2cell((1:size(data.postprocess.(data.nameSave{i}).indexLayer,1))')];
    Table(4:end,1) = {data.name{i}};

    for j = 1:length(parameters)
        for k = 1:size(data.postprocess.(data.nameSave{i}).(parameters{j}).values,2)
            value = nan(size(data.postprocess.(data.nameSave{i}).indexLayer,1),1);
            for ii=1:size(data.postprocess.(data.nameSave{i}).indexLayer,1)
                value(ii,1)=round(mean(rmmissing(rmoutliers(data.postprocess.(data.nameSave{i}).(parameters{j}).values(data.postprocess.(data.nameSave{i}).indexLayer(ii,1):data.postprocess.(data.nameSave{i}).indexLayer(ii,2),k),'percentiles',inter_conf1))),6);
            end
            column = [{parameters{j}};{data.postprocess.(data.nameSave{i}).(parameters{j}).methods{k}};{data.postprocess.(data.nameSave{i}).(parameters{j}).unit{1}};num2cell(value)];
            Table = [Table, column];
        end
    end
    designProfile.(data.nameSave{i}) = Table;
    % Save file with design soil profile
    %writecell(Table,excelName,'Sheet',data.nameSave{i}) % ,'Range',['A',num2str(indexPos(1)),':','H',num2str(indexPos(end))]
end

togetherAll = []; 
for i = 1:length(fieldnames(data.postprocess))
    if i == 1
        togetherAll = designProfile.(data.nameSave{i});
    else
        if isequal(designProfile.(data.nameSave{i})(1:3,:),togetherAll(1:3,:))
            togetherAll = [togetherAll; designProfile.(data.nameSave{i})(4:end,:)];
        else
            disp('Missing position')
        end
    end
end 

writecell(togetherAll,excelNameAll,'Sheet','Profiles')


