function [data, strat] = DBread(settings)
%% Read from database
% Database settings
databaseName =settings.db.Name;     % Database name
databaseServ =settings.db.Serv;     % Databse server
databaseUser =settings.db.User;     % Database user
databasePass =settings.db.Pass;     % Database pass

Project = settings.Proj;
rev = settings.rev;

% Access MySQL-database
mysql('open',databaseServ,databaseUser,databasePass); % ('open','server','username','password')
mysql(['use ',databaseName]); % name of database

% Find represented location for Project and Rev
pos = mysql(['select WTG_ID from Overview_WTG where ProjID="',Project,'" and WTG_Rev="',rev,'"']);
pos = unique(pos);

% Define what to run
if settings.locAll
    posRun = pos;
else
    posRun = settings.loc;
end


% Get data from database
nameSave = cell(length(posRun),1);
for i = 1:length(posRun)
    name = posRun{i};
    name(regexp(name,'[-]')) = '_';         % Change '-' to '_' for MATLAB being able to use name
    nameSave{i} = name;
    
    [data_rev,LOCA_ID] = mysql(['select Rev, LOCA_ID from ControlPanel where ProjID="',Project,'" and MainRev="',rev,'" and WTG_ID="',posRun{i},'"']);

    %%% Load in SCPT tables
    if any(strcmp(posRun{i},pos)) && ~isempty(LOCA_ID)
        data.postprocess.(nameSave{i}).LOCA_ID = LOCA_ID;
        for j = 1:length(LOCA_ID)
            table = 'SCPT';
            [dataR.pushNo, dataR.z, dataR.qc, dataR.fs, dataR.u2] = mysql...
                (['select SCPG_TESN, SCPT_DPTH, SCPT_RES, SCPT_FRES, SCPT_PWP2 from ',table,' where ProjID="',Project,'" and Rev="',data_rev{j},'" and LOCA_ID="',LOCA_ID{j},'" ORDER BY SCPT_DPTH']);
            if ~isempty(dataR.z)
                fieldN = fieldnames(dataR);
                for k = 1:length(fieldN)
                    if iscell(dataR.(fieldN{k}))
                        if all(isempty(dataR.(fieldN{k})))
                            dataR = rmfield(dataR, fieldN{k});
                        end
                    else
                        if all(isnan(dataR.(fieldN{k})))
                            dataR = rmfield(dataR, fieldN{k});
                        end
                    end
                end
                data.postprocess.(nameSave{i}).(strcat('SCPT',num2str(j))) = dataR;
                data.postprocess.(nameSave{i}).CPTavail(j,1) = j;
            else
                data.postprocess.(nameSave{i}).CPTavail(j,1) = nan;
            end
            clear dataR
        end
        
        
        %%% Load in SCPG tables
        for j = 1:length(LOCA_ID)
            table = 'SCPG';
            [dataR.push, dataR.CAR] = mysql...
                (['select SCPG_TESN, SCPG_CAR from ',table,' where ProjID="',Project,'" and Rev="',data_rev{j},'" and LOCA_ID="',LOCA_ID{j},'"']);
            fieldN = fieldnames(dataR);
            if ~isempty(dataR.push)
                for k = 1:length(fieldN)
                    if iscell(dataR.(fieldN{k}))
                        if all(isempty(dataR.(fieldN{k})))
                            dataR = rmfield(dataR, fieldN{k});
                        end
                    else
                        if all(isnan(dataR.(fieldN{k})))
                            dataR = rmfield(dataR, fieldN{k});
                        end
                    end
                end
                data.postprocess.(nameSave{i}).(strcat('SCPG',num2str(j))) = dataR;
            end
            clear dataR
        end
        
    else
        disp(['Position',posRun{i},' is not found in database. Position ignored'])
    end
    
    %% Check for any existing stratigraphy for the position
    [dataR.layerNo, dataR.top, dataR.bottom, dataR.Unit] = mysql(['select layer, top, bottom, unit from stratigraphy where ProjID="',Project,'" and Rev="',rev,'" and WTG_ID = "',posRun{i},'"']);
    strat.(posRun{i}) = dataR;
    clear dataR
end




% Close MySQL-database
mysql('close')
