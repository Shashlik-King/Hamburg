function data = ZoneDistribution(settings,data,i)
%%%-------------------------------------------------------------------------%%%
% Function for determining zone for each layer (statistically)
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     08-07-2020

pos = settings.loc{i};
dat = data.postprocess.(pos);

names = fieldnames(dat.(strcat('SCPT',num2str(dat.CPTavail(1)))).ZoneData);     % Find all names in structure for Zone determination


zoneDis = cell(length(names),size(dat.stratigraphy,1));     % Define cell for zone distribution
for j = 1:length(names)       % Loop over all methods used for determining zones
    dat.NoData = zeros(size(dat.stratigraphy,1),1);              % Vector for saving the number of points considered in each layer
    Layer = NaN(size(dat.stratigraphy,1),4);
    for k = 1:size(dat.stratigraphy,1)        % Loop over all layers
        
        
        % Gather all information available for the considered layer
        ZoneData = []; 
        for l = 1:length(dat.CPTavail)
            push = strcat('SCPT',num2str(dat.CPTavail(l))); 
            idxLayer = and(dat.(push).z>dat.stratigraphy(k,2),dat.(push).z<=dat.stratigraphy(k,3));
            ZoneData = [ZoneData; dat.(push).ZoneData.(names{j})(idxLayer)];
            dat.NoData(k) = dat.NoData(k)+sum(idxLayer);
        end
        
        
        uniqueZone = unique(ZoneData);     % Find unique zones
        uniqueZone = uniqueZone(~isnan(uniqueZone)); % Remove NaN from vector with unique zones
        if isempty(ZoneData) && isempty(uniqueZone)
            zoneDis{j,k} = [nan, zeros(size(uniqueZone))];
        elseif isempty(ZoneData)
            zoneDis{j,k} = [uniqueZone, zeros(size(uniqueZone))];
        else
            zoneDis{j,k} = [uniqueZone,histc(ZoneData,uniqueZone)]; % Distribution of unique zones in layer(s)
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
    [SBTsoil1, MAT1] = ZoneSBT(Layer(:,2),names{j});
    [SBTsoil2, MAT2] = ZoneSBT(Layer(:,4),names{j});
    dat.zone.LocationSum{j} = [num2cell(Layer(:,1:2)), SBTsoil1, num2cell(Layer(:,3:4)), SBTsoil2, MAT1];
    
    % Test if any index is NaN
    indexNaN = cell2mat(cellfun(@isnan,dat.zone.LocationSum{j}(:,[1 2 4 5]),'UniformOutput',false));
    if any(any(indexNaN))   % If NaN encountered, rewrite this in cell matrix
        indexMatrixNaN = [indexNaN(:,1:2), zeros(size(indexNaN,1),1),indexNaN(:,3:4), zeros(size(indexNaN,1),1)];
        
        for k = 1:size(indexMatrixNaN,2)
            for l = 1:size(indexMatrixNaN,1)
                if indexMatrixNaN(l,k)
                    dat.zone.LocationSum{j}{l,k} = NaN;   % 'N/A'
                    dat.zone.LocationSum{j}{l,k+1} = NaN;
                    if k == 1 || k == 4
                        dat.zone.LocationSum{j}{l,k+2} = NaN;
                    end
                end
            end
        end
    end
    
    % Change description where 0% of layer is present (if no sub-units are encountered)
    zeroLayers = find(cell2mat(dat.zone.LocationSum{j}(:,4))==0);
    if ~isempty(zeroLayers)
        for k = 1:length(zeroLayers)
            dat.zone.LocationSum{j}{zeroLayers(k),5} = NaN;
            dat.zone.LocationSum{j}{zeroLayers(k),6} = NaN;
        end
    end
end

dat.zone.Distribution = zoneDis;
dat.zone.Methods = names;

% dat.SBT = cell(length(data.postprocess.(data.nameSave{i}).z),1);
% for ii=1:size(data.postprocess.(data.nameSave{i}).zone.LocationSum{1,1},1)
%     dat.SBT(dat.indexLayer(ii,1):dat.indexLayer(ii,2),1) = dat.zone.LocationSum{1,1}(ii,3);
% end


data.postprocess.(settings.loc{i}) = dat;