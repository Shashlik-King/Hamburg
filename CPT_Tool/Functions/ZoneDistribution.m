function data = ZoneDistribution(data,i)
%%%-------------------------------------------------------------------------%%%
% Function for determining zone for each layer (statistically)
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     08-07-2020

names.zoneNames = fieldnames(data.postprocess.(data.nameSave{i}).ZoneData);     % Find all names in structure for Zone determination
zoneDis = cell(length(names.zoneNames),size(data.postprocess.(data.nameSave{i}).indexLayer,1));     % Define cell for zone distribution
for j = 1:length(names.zoneNames)       % Loop over all methods used for determining zones
    Layer = NaN(size(data.postprocess.(data.nameSave{i}).indexLayer,1),4);
    for k = 1:size(data.postprocess.(data.nameSave{i}).indexLayer,1)            % Loop over all layers
        uniqueZone = unique(data.postprocess.(data.nameSave{i}).ZoneData.(names.zoneNames{j}));     % Find unique zones
        uniqueZone = uniqueZone(~isnan(uniqueZone)); % Remove NaN from vector with unique zones
        if data.postprocess.(data.nameSave{i}).indexLayer(k,1) == data.postprocess.(data.nameSave{i}).indexLayer(k,2)
            zoneDis{j,k} = [uniqueZone, zeros(size(uniqueZone))];
        else
            zoneDis{j,k} = [uniqueZone,histc(data.postprocess.(data.nameSave{i}).ZoneData.(names.zoneNames{j})(data.postprocess.(data.nameSave{i}).indexLayer(k,1):data.postprocess.(data.nameSave{i}).indexLayer(k,2)),uniqueZone)]; % Distribution of unique zones in layer(s)
            zoneDis{j,k} = sortrows(zoneDis{j,k},2,'descend');
        end
        if isempty(zoneDis{j,k})
            Layer(k,:) = [NaN, NaN, NaN, NaN];
        elseif size(zoneDis{j,k},1) < 2
            Layer(k,:) = [round(zoneDis{j,k}(1,2)/sum(zoneDis{j,k}(:,2))*100,2),zoneDis{j,k}(1,1), NaN, NaN];
        else
            Layer(k,:) = [round(zoneDis{j,k}(1,2)/sum(zoneDis{j,k}(:,2))*100,2),zoneDis{j,k}(1,1),   round(zoneDis{j,k}(2,2)/sum(zoneDis{j,k}(:,2))*100,2),zoneDis{j,k}(2,1)];
        end
    end
    [SBTsoil1, MAT1] = ZoneSBT(Layer(:,2),names.zoneNames{j});
    [SBTsoil2, MAT2] = ZoneSBT(Layer(:,4),names.zoneNames{j});
    data.postprocess.(data.nameSave{i}).zone.LocationSum{j} = [num2cell(Layer(:,1:2)), SBTsoil1, num2cell(Layer(:,3:4)), SBTsoil2, MAT1];
    
    % Test if any index is NaN
    indexNaN = cell2mat(cellfun(@isnan,data.postprocess.(data.nameSave{i}).zone.LocationSum{j}(:,[1 2 4 5]),'UniformOutput',false));
    if any(any(indexNaN))   % If NaN encountered, rewrite this in cell matrix
        indexMatrixNaN = [indexNaN(:,1:2), zeros(size(indexNaN,1),1),indexNaN(:,3:4), zeros(size(indexNaN,1),1)];
        
        for k = 1:size(indexMatrixNaN,2)
            for l = 1:size(indexMatrixNaN,1)
                if indexMatrixNaN(l,k)
                    data.postprocess.(data.nameSave{i}).zone.LocationSum{j}{l,k} = NaN;   % 'N/A'
                    data.postprocess.(data.nameSave{i}).zone.LocationSum{j}{l,k+1} = NaN;
                    if k == 1 || k == 4
                        data.postprocess.(data.nameSave{i}).zone.LocationSum{j}{l,k+2} = NaN;
                    end
                end
            end
        end
    end
    
    % Change description where 0% of layer is present (if no sub-units are encountered)
    zeroLayers = find(cell2mat(data.postprocess.(data.nameSave{i}).zone.LocationSum{j}(:,4))==0);
    if ~isempty(zeroLayers)
        for k = 1:length(zeroLayers)
            data.postprocess.(data.nameSave{i}).zone.LocationSum{j}{zeroLayers(k),5} = NaN;
            data.postprocess.(data.nameSave{i}).zone.LocationSum{j}{zeroLayers(k),6} = NaN;
        end
    end
end

data.postprocess.(data.nameSave{i}).zone.Distribution = zoneDis;
data.postprocess.(data.nameSave{i}).zone.Methods = names.zoneNames;

data.postprocess.(data.nameSave{i}).SBT = cell(length(data.postprocess.(data.nameSave{i}).z),1);
for ii=1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
    data.postprocess.(data.nameSave{i}).SBT(data.postprocess.(data.nameSave{i}).indexLayer(ii,1):data.postprocess.(data.nameSave{i}).indexLayer(ii,2),1) = data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1}(ii,3);
end