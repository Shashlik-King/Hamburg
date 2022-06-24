function data = AGSread(settings,Folder)
%%%-------------------------------------------------------------------------%%%
% data = ReaderAGS(settings,Folder,values)
% Function for loading in all data from AGS files
%
% If new variable is desired to be created from the ASG files, please add
% this in the function "HeadingsAGS" in the naming vector
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     06-07-2020

%% Identify filenames in folder
FolderRead = Folder.Data; 
listingCheck = dir(FolderRead);


listingCheck = {listingCheck.name};          % Get names of files in folder

pattern = ".AGS";                            % Search pattern (change if received AGS files is other file format than .AGS)
nameIndex = not(endsWith(listingCheck,pattern,'IgnoreCase',true));   % Index for files not .AGS format
listingCheck(nameIndex) = [];                % Remove all index not an .AGS format

% Check if all positions shall be runned
if settings.runAll
    listing = listingCheck;     % If running all files in folder
else
    listing = cell(1,length(settings.runLoc));
    for i = 1:length(settings.runLoc)
        if contains(settings.runLoc{1,i},'.')
            indexRun = find(strcmp(listingCheck,settings.runLoc{1,i}));
            if ~isempty(indexRun)
                listing{1,i} = listingCheck{indexRun};
            else
                disp(['Location ',settings.runLoc{1,i},' cant be found in folder'])
            end
        else
            indexRun = find(contains(listingCheck,strcat(settings.runLoc{1,i},'.')));
            if ~isempty(indexRun)
                listing{1,i} = listingCheck{indexRun};
            else
                disp(['Location ',settings.runLoc{1,i},' cant be found in folder'])
            end
        end
    end
end

%% Load AGS files and prepare data
counter = 0;                            % Counter for number of locations over all files
data.SummaryName = [];
for i = 1:length(listing)                   % Looping over files in folder with AGS format
    disp(strcat('Position number ',num2str(i),' of ',num2str(length(listing))))
    name = listing{i}(1:end-4);             % Define name of file
    name(regexp(name,'[-]')) = '_';         % Change '-' to '_' for MATLAB being able to use name
    
    data.Raw.(name)=importdata(fullfile(FolderRead,listing{i}));
    % groupIndex.(name) = find(contains(data.Raw.(name), 'GROUP'));
    groupIndex.(name) = find(and(contains(data.Raw.(name), 'GROUP'),count(data.Raw.(name),',')==1));
    
    %% Loop over all groups included in AGS file and save in temporary structure (dataTemp)
    for j = 1:length(groupIndex.(name))
        group = strsplit(data.Raw.(name){groupIndex.(name)(j)},',');
        group = group{2};
        group(regexp(group,'["]')) = [];
        dataTemp.Overview{j} = group;
        
        % Loop over all lines in each group
        kstart = groupIndex.(name)(j)+1;
        if j == length(groupIndex.(name))
            kend = length(data.Raw.(name));
        else
            kend = groupIndex.(name)(j+1)-1;
        end
        dataTemp.(group) = cell(kend-kstart+1,length(strsplit(data.Raw.(name){kstart+1},',')));
        counterGroup = 0;
        for k = kstart:kend
            counterGroup = counterGroup+1;
            cellArrayIndex = strsplit(data.Raw.(name){k},'",');
            dataTemp.(group)(counterGroup,:) = regexprep(cellArrayIndex, '"', ''); % Save line where remaining " are removed
        end
    end
    
    %% Generate structure with each location as index
    LOCAinFILE = sum(strcmp(dataTemp.LOCA(:,1),'DATA'));    % Check number of locations in file
    LOCAindex = find(strcmp(dataTemp.LOCA(:,1),'DATA'));    % Check row-index for location name
    if LOCAinFILE == 1                                      % Only one position defined in file
        counter = counter+1;                                % Counter
        name = dataTemp.LOCA{LOCAindex,2};                  % Find name in "LOCA" group
        data.name{counter} = name;                          % Save original location-name
        name(regexp(name,'[-]')) = '_';                     % Change '-' to '_' for MATLAB being able to use name
        if counter > 1 && any(strcmp(data.nameSave,name))   % If same location name already defined before
            indexDuplicate = 1;
            while indexDuplicate > 0
                nameUpdate = strcat(name,'__',num2str(indexDuplicate));
                if any(strcmp(data.nameSave,nameUpdate))    % Check if updated name exist - keep looping until unique name found
                    indexDuplicate = indexDuplicate+1;
                else
                    indexDuplicate = -1;                    % If unique name found, stop "while" loop
                end
            end
            %msgbox(['Same location name multiple defined for ',name], 'Warning','warn')
            name = nameUpdate;
        end
        data.nameSave{counter} = name;                      % Save MATLAB location-name
        data.Basis.(data.nameSave{counter}) = dataTemp;
        data.SummaryName = [data.SummaryName;data.nameSave(counter), data.name(counter), listing{i}(1:end-4)];
    else                                                    % Multiple position defined in file
        for j = 1:LOCAinFILE                                % Loop over each position in the file
            counter = counter+1;
            name = dataTemp.LOCA{LOCAindex(j),2};           % Find name in "LOCA" group
            data.name{counter} = name;                      % Save original location-name
            name(regexp(name,'[-]')) = '_';
            if counter>1 && any(strcmp(data.nameSave,name)) % If same location name already defined before
                indexDuplicate = 1;
                while indexDuplicate > 0
                    nameUpdate = strcat(name,'__',num2str(indexDuplicate));
                    if any(strcmp(data.nameSave,nameUpdate))% Check if updated name exist - keep looping until unique name found
                        indexDuplicate = indexDuplicate+1;
                    else
                        indexDuplicate = -1;                % If unique name found, stop "while" loop
                    end
                end
                %msgbox(['Same location name multiple defined for ',name], 'Warning','warn')
                name = nameUpdate;
            end
            data.nameSave{counter} = name;                  % Save MATLAB location-name
            data.Basis.(data.nameSave{counter}) = dataTemp; % Save temporary matrix as
            for k = 1:length(dataTemp.Overview)             % Loop over all groups in the AGS file
                indexLoca = find(strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(1,:),'LOCA_ID'));    % Search for location header in group
                if ~isempty(indexLoca)                      % Enter if location header is present in current group
                    indexData = find(strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(:,1),'DATA'));
                    deleteRows = indexData(~strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(indexData,indexLoca),data.name{counter}));
                    data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(deleteRows,:) = [];
                end
            end
            data.SummaryName = [data.SummaryName;data.nameSave(counter), data.name(counter), listing{i}(1:end-4)];
        end
    end
    clear dataTemp
end

%% Clear workspace for unnessesary variables
clearvars -except data settings Folder DataType

%% Check what to save in DB and convert units if needed
[GROUPS,COLUMNS] = DB_tables;

pos = fieldnames(data.Basis);
for i = 1:length(pos)                   % Loop over each position
    counter = 0;
    GRP = data.Basis.(pos{i}).Overview;
    for j = 1:length(GRP)
        if any(strcmp(GRP{j},GROUPS))               % IF GROUPS IS DEFINED IN DATABASE
            col = data.Basis.(pos{i}).(GRP{j})(1,2:end)';
            counter2 = 0;
            idxUpload = nan(length(col)+1,1);
            idxUpload(1) = 1; 
            
            data.Upload.(pos{i}).(GRP{j}) = data.Basis.(pos{i}).(GRP{j});
            
            for k = 1:length(col)
                if any(strcmp(col{k},COLUMNS.(GRP{j})(:,1)))               % IF COLUMN IS DEFINED IN DATABASE
                    unitFormat = data.Basis.(pos{i}).(GRP{j}){3,k+1};
                    if length(unitFormat)>2 && any(strcmp(unitFormat(end-1:end),{'DP','SF'}))  % IF DATA UNIT IS NUMBERS
                        try         % TRY CHECK UNIT - IF NOT POSSIBLE, MAKE WARNING
                            UNIT_AGS = data.Basis.(pos{i}).(GRP{j}){2,k+1};
                            UNIT_DB = COLUMNS.(GRP{j}){strcmp(COLUMNS.(GRP{j})(:,1),data.Basis.(pos{i}).(GRP{j}){1,k+1}),3};
                            if iscell(UNIT_DB)
                                UNIT_DB = UNIT_DB{1:end};
                            end
                            varAGS = data.Basis.(pos{i}).(GRP{j}){1,k+1}; 
                            factorUnit = AGSunitConversion(UNIT_AGS,UNIT_DB,varAGS); 
                            
                            % Convert column with factor
                            dataFac = data.Upload.(pos{i}).(GRP{j})(4:end,k+1);
                            dataFac = cellfun(@str2num,dataFac,'un',0);        % cell2mat for extracting (DONE LATER)
                            dataFac = cellfun(@(x) x*factorUnit,dataFac,'un',0);
                            data.Upload.(pos{i}).(GRP{j})(4:end,k+1) = dataFac;

                            idxUpload(k+1) = 1;
                        catch ME
                            idxUpload(k+1) = 0;
                            if counter2 == 0
                                dis.(pos{i}).(GRP{j}) = [];
                            end
                            dis.(pos{i}).(GRP{j}) = [dis.(pos{i}).(GRP{j});col(k)];
                            counter2 = counter2+1;
                            
                        end
                        
                    else    % IF NOT NUMERIC
                        idxUpload(k+1) = 1;
                        
                    end
                else
                    idxUpload(k+1) = 0;
                    if counter2 == 0
                        dis.(pos{i}).(GRP{j}) = [];
                    end
                    dis.(pos{i}).(GRP{j}) = [dis.(pos{i}).(GRP{j});col(k)];
                    counter2 = counter2+1;
                end
                
            end
            data.Upload.(pos{i}).(GRP{j}) = data.Upload.(pos{i}).(GRP{j})(:,(idxUpload==1));
            if ~all(idxUpload==1)
                data.DisData.(pos{i}).(GRP{j}) = data.Basis.(pos{i}).(GRP{j})(:,~(idxUpload==1));
            end
        else
            if counter == 0
                dis.(pos{i}).GROUPS = [];
            end
            dis.(pos{i}).GROUPS = [dis.(pos{i}).GROUPS;GRP(j)];
            counter = counter+1;
            data.DisData.(pos{i}).(GRP{j}) = data.Basis.(pos{i}).(GRP{j});
        end
    end
end
data.disOverview = dis; 



% try
%% Loop over all positions for generating variables
% removeID = [];
% if strcmp(DataType,'CPT') % If the AGS reading is for CPT
%     for i = 1:length(data.nameSave)         % Loop over all positions where data is saved in the "data.basis" structure
%         disp(['Generating variables - position ',num2str(i),'/',num2str(length(data.nameSave))])
%         if any(settings.Locations == "") || any(strcmp(settings.Locations,data.name{i}))
%             %% Generate variables for structure, calculations and definitions
%             for j = 1:length(data.Basis.(data.nameSave{i}).Overview)
%                 dimensions = size(data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}));
%                 for k = 2:dimensions(2)
%                     [out] = AGSheading(data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}){1,k});    % Check if heading is defined in list for being saved
%                     if iscell(out)                                      % Check if header index was found in save list
%                         valuesVariable = data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j})(4:dimensions(1),k);
%                         empties = cellfun('isempty',valuesVariable);    % Find empty cells
%                         valuesVariable(empties) = {'NaN'};              % Insert NaN in empty cells
%                         if ~all(cellfun(@(valuesVariable) strcmp(valuesVariable,'NaN'), valuesVariable))  % Check if all indexes are NaN - if so dont create variable
%                             try     % Try to check if "valuesVariable" is numeric
%                                 data.postprocess.(data.nameSave{i}).(out{1}) = cellfun(@str2num, valuesVariable);
%                                 numericData = 1;
%                             catch   % If "valuesVariable" not numeric save as cell
%                                 data.postprocess.(data.nameSave{i}).(out{1}) = valuesVariable;
%                                 numericData = 2;
%                             end
%                             if numericData == 1
%                                 unitAGS = data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}){2,k};
%                                 varAGS = data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}){1,k};
%                                 if ~strcmp(unitAGS,out{2}) %&& ~strcmp(unitAGS,'-')  % If unit does not correspond between documentet in AGS file and defined in "AGSheading" function and is not unitless
%                                     unitFactor = AGSunitConversion(unitAGS,out{2},varAGS);
%                                     data.postprocess.(data.nameSave{i}).(out{1}) = data.postprocess.(data.nameSave{i}).(out{1}).*unitFactor;
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%
%             % Overwrite / update specific values
%             if isfield(data.postprocess,data.nameSave{i})
%                 if isfield(data.postprocess.(data.nameSave{i}),'h_water')
%                     data.postprocess.(data.nameSave{i}).h_water = abs(data.postprocess.(data.nameSave{i}).h_water);     % Ensure water height is positive value
%                 end
%
%                 % Check all variables either is 1x1 or 1xM where M is length of z
%                 % vector. If not 1xM, the vector will resize for this
%                 namesField = fieldnames(data.postprocess.(data.nameSave{i}));
%                 if isfield(data.postprocess.(data.nameSave{i}),'z')
%                     indexTotal = length(data.postprocess.(data.nameSave{i}).z);
%
%                     %pushID = unique(data.postprocess.(data.nameSave{i}).PushNo);                                            % Find unique pushes for location
%                     countPush = 1;
%                     data.postprocess.(data.nameSave{i}).pushIndex(1,1) = 1;
%                     %pushID{1,1} =
%                     for III = 1:length(data.postprocess.(data.nameSave{i}).PushNo)-1
%                         if ~isequal(data.postprocess.(data.nameSave{i}).PushNo(III),data.postprocess.(data.nameSave{i}).PushNo(III+1))
%                             if countPush == 1
%                                 data.postprocess.(data.nameSave{i}).pushIndex(countPush,2) = III;
%                             else
%                                 data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III];
%                             end
%                             countPush = countPush+1;
%                         end
%                         if III == length(data.postprocess.(data.nameSave{i}).PushNo)-1
%                             if countPush == 1
%                                 data.postprocess.(data.nameSave{i}).pushIndex(countPush,1:2) = [1,III+1];
%                             else
%                                 data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III+1];
%                             end
%                         end
%                     end
%                     pushID = data.postprocess.(data.nameSave{i}).pushIndex(:,1);
%
%                     %     data.postprocess.(data.nameSave{i}).pushIndex = nan(length(pushID) ,2);                                 % Predefine matrix for push index with NaN
%                     %     for j = 1:length(pushID)                                                                                % Loop for determining index for different pushes
%                     %         kStart = find(strcmp(data.postprocess.(data.nameSave{i}).PushNo,pushID{j}),1,'first');              % Find first index
%                     %         kEnd = find(strcmp(data.postprocess.(data.nameSave{i}).PushNo,pushID{j}),1,'last');                 % Find last index
%                     %         data.postprocess.(data.nameSave{i}).pushIndex(j,:) = [kStart, kEnd];                                % Save index for push
%                     %     end
%                     for j = 1:length(namesField)
%                         if ~or(length(data.postprocess.(data.nameSave{i}).(namesField{j}))==1,length(data.postprocess.(data.nameSave{i}).(namesField{j}))==indexTotal)  % If length of vector not equal to 1 or M
%                             if length(data.postprocess.(data.nameSave{i}).(namesField{j}))== length(pushID)
%                                 temporary = data.postprocess.(data.nameSave{i}).(namesField{j});
%                                 data.postprocess.(data.nameSave{i}).(namesField{j}) = nan(indexTotal,1);
%                                 for k = 1:length(pushID)                                                                    % Loop over all pushes for location
%                                     kStart = data.postprocess.(data.nameSave{i}).pushIndex(k,1);
%                                     kEnd = data.postprocess.(data.nameSave{i}).pushIndex(k,2);
%                                     data.postprocess.(data.nameSave{i}).(namesField{j})(kStart:kEnd) = temporary(k);        % Assummed the correct order is always present in data - search can be coded later
%                                 end
%                             else
%                                 % Should in theory never enter this - however, check coded to be performed
%                                 error('Special length of variable found - check what this is and code what to do')
%                             end
%                         end
%                     end
%                 else % If n 'z' field is found in the position the position is disregarded (deleted from the format)
%                     data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
%                     data.postprocess = rmfield(data.postprocess,data.nameSave{i});
%                     disp(['The field ',data.nameSave{i},' has been removed from structure due to no z measurements'])
%                     removeID = [removeID, i];
%                 end
%             else
%                 try
%                     data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
%                 catch
%                     data.postprocessOBS.(data.nameSave{i}).Dummy = [];
%                 end
%                 disp(['The field ',data.nameSave{i},' has been removed from structure due to no measurements'])
%                 removeID = [removeID, i];
%             end
%         else
%             %data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
%             disp(['The field ',data.nameSave{i},' has been removed from structure as this is not included in specified positions'])
%             removeID = [removeID, i];
%         end
%     end
% end
% data.nameOriginal = data.name;
% data.nameSave(removeID) = []; % Delete names from removed positions
% data.name(removeID) = []; % Delete names from removed positions







