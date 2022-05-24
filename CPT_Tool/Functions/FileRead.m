function data = FileRead(settings,Folder,Files,data)

%% Read borehole (BH) data
if settings.LayerSel.BH
    try
        BHdata = readcell(fullfile(Folder.Data.BH,Files.BH));
        BHdataMat = [BHdata(1:end,1:3),BHdata(1:end,5)];
        BHdataMat(cellfun(@isempty, BHdataMat)) = {nan};
        data.BH = [BHdataMat, cell(size(BHdataMat,1),1)];
        
        % Find responding CPT
        locBH = unique(data.BH(:,1));
        for i = 1:length(locBH)
            indexLoc = strfind(locBH{i},'-')+1;
            indexCPT = find(contains(data.name,locBH{i}(indexLoc:end)));
            if ~isempty(indexCPT)
                indexCPTid = strfind(data.name{indexCPT},'-')+1;
                if strcmp(data.name{indexCPT}(indexCPTid:end),locBH{i}(indexLoc:end))
                    indexBH = strcmp(data.BH(:,1),locBH{i});
                    for j = 1:length(indexBH)
                        if indexBH(j)
                            data.BH{j,5} = data.name{indexCPT};
                        end
                    end
                end
            end
        end
    catch
        disp('Error in loading BH, "settings.LayerSel.BH" changed to 0')
        settings.LayerSel.BH = 0;
    end
end


%% Read geophysical layer interpretation
if settings.LayerSel.Horizon
    try
        geophysData = readcell(fullfile(Folder.Data.Geophys,Files.Geophys),'Sheet','MD at well');   % MD at well
        rawData = geophysData(2:end,2:end);
        rawData(cellfun(@ismissing, rawData)) = {nan};
        data.Horizonts = [geophysData(1,:); geophysData(2:end,1),rawData];
    catch
        disp('Error in loading Horizonts, "settings.LayerSel.Horizon" changed to 0')
        settings.LayerSel.Horizon = 0;
    end
end