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
listingCheck = dir(Folder.Data.CPT);             % Get info on files in folder
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
for i = 1:length(listing)                   % Looping over files in folder with AGS format
    name = listing{i}(1:end-4);             % Define name of file
    name(regexp(name,'[-]')) = '_';         % Change '-' to '_' for MATLAB being able to use name
    
    data.Raw.(name)=importdata(fullfile(Folder.Data.CPT,listing{i}));
    groupIndex.(name) = find(startsWith(data.Raw.(name), '"GROUP"'));
    
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
%         % Export dataTemp to excel for overview if needed
        if 0
            writecell(dataTemp.(group),'Output\'+string(name)+'.xlsx','sheet',group)
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
            msgbox(['Same location name multiple defined for ',name], 'Warning','warn')
            name = nameUpdate;
        end
        data.nameSave{counter} = name;                      % Save MATLAB location-name
        data.Basis.(data.nameSave{counter}) = dataTemp;
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
                msgbox(['Same location name multiple defined for ',name], 'Warning','warn')
                name = nameUpdate;
            end
            data.nameSave{counter} = name;                  % Save MATLAB location-name
            data.Basis.(data.nameSave{counter}) = dataTemp; % Save temporary matrix as
            for k = 1:length(dataTemp.Overview)             % Loop over all groups in the AGS file
                indexLoca = find(strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(1,:),'LOCA_ID'));    % Search for location header in group
                if ~isempty(indexLoca)                      % Enter if location header is present in current group
                    indexData = find(strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(:,1),'DATA'));
                    indexDelete = ~strcmp({data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k}){indexData,indexLoca}}',data.name{counter});
                    data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(indexData(indexDelete),:) = [];    % Delete row if it doesnt have the same location name as the current loop (loop "j")
%                     for kk = 1:length(indexData)            % Loop over all "DATA" rows in group
%                         indexReverse = indexData(length(indexData)+1-kk);   % Index for loop (if deleting row, they need to be deleted from bottom and up)
%                         if ~strcmp(data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k}){indexReverse,indexLoca}',data.name{counter})
%                             data.Basis.(data.nameSave{counter}).(dataTemp.Overview{k})(indexReverse,:) = [];    % Delete row if it doesnt have the same location name as the current loop (loop "j")
%                         end
%                     end
                end
            end
        end
    end
    clear dataTemp
end

data.nameOri.name = data.nameSave;
data.nameOri.nameSave = data.nameSave;

%% Loop over all positions for generating variables
removeID = []; 
for i = 1:length(data.nameSave)         % Loop over all positions where data is saved in the "data.basis" structure
    
    disp(['Variable generation: ',data.nameSave{i},' (',num2str(i),'/',num2str(length(data.nameSave)),')'])
    if any(settings.Locations == "") || any(strcmp(settings.Locations,data.name{i}))
        %% Generate variables for structure, calculations and definitions
        for j = 1:length(data.Basis.(data.nameSave{i}).Overview)
            dimensions = size(data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}));
            for k = 2:dimensions(2)
                if isempty(data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}))
                    out = NaN;
                else
                    [out] = AGSheading(data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}){1,k});    % Check if heading is defined in list for being saved
                end
                if iscell(out)                                      % Check if header index was found in save list
                    valuesVariable = data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j})(4:dimensions(1),k);
                    empties = cellfun('isempty',valuesVariable);    % Find empty cells
                    valuesVariable(empties) = {'NaN'};              % Insert NaN in empty cells
                    if ~all(cellfun(@(valuesVariable) strcmp(valuesVariable,'NaN'), valuesVariable))  % Check if all indexes are NaN - if so dont create variable
                        try     % Try to check if "valuesVariable" is numeric
                            data.postprocess.(data.nameSave{i}).(out{1}) = cellfun(@str2num, valuesVariable);
                            numericData = 1;
                        catch   % If "valuesVariable" not numeric save as cell
                            data.postprocess.(data.nameSave{i}).(out{1}) = valuesVariable;
                            numericData = 2;
                        end
                        if numericData == 1
                            unitAGS = data.Basis.(data.nameSave{i}).(data.Basis.(data.nameSave{i}).Overview{j}){2,k};
                            if ~strcmp(unitAGS,out{2})  % If unit does not correspond between documentet in AGS file and defined in "AGSheading" function
                                unitFactor = AGSunitConversion(unitAGS,out{2});
                                data.postprocess.(data.nameSave{i}).(out{1}) = data.postprocess.(data.nameSave{i}).(out{1}).*unitFactor;
                            end
                        end
                    end
                end
            end
        end
        
        data.postprocess.dummy = 1;
        data.postprocess = rmfield(data.postprocess ,'dummy');
        % Overwrite / update specific values
        if isfield(data.postprocess,data.nameSave{i})
            if isfield(data.postprocess.(data.nameSave{i}),'h_water')
                data.postprocess.(data.nameSave{i}).h_water = abs(data.postprocess.(data.nameSave{i}).h_water);     % Ensure water height is positive value
            end
            
            % Check all variables either is 1x1 or 1xM where M is length of z
            % vector. If not 1xM, the vector will resize for this
            namesField = fieldnames(data.postprocess.(data.nameSave{i}));
            if isfield(data.postprocess.(data.nameSave{i}),'z')
                indexTotal = length(data.postprocess.(data.nameSave{i}).z);
                %pushID = unique(data.postprocess.(data.nameSave{i}).PushNo);                                            % Find unique pushes for location
                countPush = 1;
                data.postprocess.(data.nameSave{i}).pushIndex(1,1) = 1;
                %pushID{1,1} =
                for III = 1:length(data.postprocess.(data.nameSave{i}).PushNo)-1
                    if ~isequal(data.postprocess.(data.nameSave{i}).PushNo(III),data.postprocess.(data.nameSave{i}).PushNo(III+1))
                        if countPush == 1
                            data.postprocess.(data.nameSave{i}).pushIndex(countPush,2) = III;
                        else
                            data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III];
                        end
                        countPush = countPush+1;
                    end
                    if III == length(data.postprocess.(data.nameSave{i}).PushNo)-1
                        if countPush == 1
                            data.postprocess.(data.nameSave{i}).pushIndex(countPush,1:2) = [1,III+1];
                        else
                            data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III+1];
                        end
                    end
                end
                pushID = data.postprocess.(data.nameSave{i}).pushIndex(:,1);
                
                % If data needs to be adjusted due to limited CPT depth
                if isnumeric(settings.maxDepth) && max(data.postprocess.(data.nameSave{i}).z) > settings.maxDepth
                    indexOrig = length(data.postprocess.(data.nameSave{i}).z);
                    indexTotal = sum(settings.maxDepth>=data.postprocess.(data.nameSave{i}).z);
                    FieldN = fieldnames(data.postprocess.(data.nameSave{i}));
                    for j = 1:length(FieldN)
                        if length(data.postprocess.(data.nameSave{i}).(FieldN{j})) == indexOrig
                            data.postprocess.(data.nameSave{i}).(FieldN{j}) = data.postprocess.(data.nameSave{i}).(FieldN{j})(1:indexTotal);
                        end
                    end
                    pushIDold= pushID;
                    % Overwrite previous push index
                    
                    indexTotal = length(data.postprocess.(data.nameSave{i}).z);
                    
                    %pushID = unique(data.postprocess.(data.nameSave{i}).PushNo);                                            % Find unique pushes for location
                    countPush = 1;
                    data.postprocess.(data.nameSave{i}) = rmfield(data.postprocess.(data.nameSave{i}),'pushIndex'); % Remove original pushIndex
                    data.postprocess.(data.nameSave{i}).pushIndex(1,1) = 1;
                    %pushID{1,1} =
                    for III = 1:length(data.postprocess.(data.nameSave{i}).PushNo)-1
                        if ~isequal(data.postprocess.(data.nameSave{i}).PushNo(III),data.postprocess.(data.nameSave{i}).PushNo(III+1))
                            if countPush == 1
                                data.postprocess.(data.nameSave{i}).pushIndex(countPush,2) = III;
                            else
                                data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III];
                            end
                            countPush = countPush+1;
                        end
                        if III == length(data.postprocess.(data.nameSave{i}).PushNo)-1
                            if countPush == 1
                                data.postprocess.(data.nameSave{i}).pushIndex(countPush,1:2) = [1,III+1];
                            else
                                data.postprocess.(data.nameSave{i}).pushIndex(countPush,:) = [data.postprocess.(data.nameSave{i}).pushIndex(countPush-1,2)+1,III+1];
                            end
                        end
                    end
                    pushID = data.postprocess.(data.nameSave{i}).pushIndex(:,1);
                    
                    
                    for j = 1:length(FieldN)
                        if length(data.postprocess.(data.nameSave{i}).(FieldN{j})) == length(pushIDold)
                            data.postprocess.(data.nameSave{i}).(FieldN{j}) = data.postprocess.(data.nameSave{i}).(FieldN{j})(1:length(pushID),:);
                        end
                    end
                    
                end
                
                
                
                for j = 1:length(namesField)
                    if ~or(length(data.postprocess.(data.nameSave{i}).(namesField{j}))==1,length(data.postprocess.(data.nameSave{i}).(namesField{j}))==indexTotal)  % If length of vector not equal to 1 or M
                        if length(data.postprocess.(data.nameSave{i}).(namesField{j}))== length(pushID)
                            temporary = data.postprocess.(data.nameSave{i}).(namesField{j});
                            data.postprocess.(data.nameSave{i}).(namesField{j}) = nan(indexTotal,1);
                            for k = 1:length(pushID)                                                                    % Loop over all pushes for location
                                kStart = data.postprocess.(data.nameSave{i}).pushIndex(k,1);
                                kEnd = data.postprocess.(data.nameSave{i}).pushIndex(k,2);
                                data.postprocess.(data.nameSave{i}).(namesField{j})(kStart:kEnd) = temporary(k);        % Assummed the correct order is always present in data - search can be coded later
                            end
                        else
                            % Should in theory never enter this - however, check coded to be performed
                            test = 1; 
                            %error('Special length of variable found - check what this is and code what to do')
                            data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
                            data.postprocess = rmfield(data.postprocess,data.nameSave{i});
                            disp(['The field ',data.nameSave{i},' has been removed from structure due to mismatch in push index'])
                            removeID = [removeID, i];
                            break
                        end
                    end
                end
            else % If n 'z' field is found in the position the position is disregarded (deleted from the format)
                data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
                data.postprocess = rmfield(data.postprocess,data.nameSave{i});
                disp(['The field ',data.nameSave{i},' has been removed from structure due to no z measurements'])
                removeID = [removeID, i];
            end
        else
            data.postprocessOBS.(data.nameSave{i}) = []; % data.postprocess.(data.nameSave{i});
            disp(['The field ',data.nameSave{i},' has been removed from structure due to no measurements'])
            removeID = [removeID, i];
        end
        
    else
        %data.postprocessOBS.(data.nameSave{i}) = data.postprocess.(data.nameSave{i});
        disp(['The field ',data.nameSave{i},' has been removed from structure as this is not included in specified positions'])
        removeID = [removeID, i];
    end
    
    %     % Overwrite / update specific values
    %     data.postprocess.(data.nameSave{i}).h_water = abs(data.postprocess.(data.nameSave{i}).h_water);     % Ensure water height is positive value
    %
    %
    %     % Check all variables either is 1x1 or 1xM where M is length of z
    %     % vector. If not 1xM, the vector will resize for this
    %     namesField = fieldnames(data.postprocess.(data.nameSave{i}));
    %     indexTotal = length(data.postprocess.(data.nameSave{i}).z);
    %
    %     pushID = unique(data.postprocess.(data.nameSave{i}).PushNo);                                            % Find unique pushes for location
    %     data.postprocess.(data.nameSave{i}).pushIndex = nan(length(pushID) ,2);                                 % Predefine matrix for push index with NaN
    %     for j = 1:length(pushID)                                                                                % Loop for determining index for different pushes
    %         kStart = find(strcmp(data.postprocess.(data.nameSave{i}).PushNo,pushID{j}),1,'first');              % Find first index
    %         kEnd = find(strcmp(data.postprocess.(data.nameSave{i}).PushNo,pushID{j}),1,'last');                 % Find last index
    %         data.postprocess.(data.nameSave{i}).pushIndex(j,:) = [kStart, kEnd];                                % Save index for push
    %     end
    %     for j = 1:length(namesField)
    %         if ~or(length(data.postprocess.(data.nameSave{i}).(namesField{j}))==1,length(data.postprocess.(data.nameSave{i}).(namesField{j}))==indexTotal)  % If length of vector not equal to 1 or M
    %             if length(data.postprocess.(data.nameSave{i}).(namesField{j}))== length(pushID)
    %                 temporary = data.postprocess.(data.nameSave{i}).(namesField{j});
    %                 data.postprocess.(data.nameSave{i}).(namesField{j}) = nan(indexTotal,1);
    %                 for k = 1:length(pushID)                                                                    % Loop over all pushes for location
    %                     kStart = data.postprocess.(data.nameSave{i}).pushIndex(k,1);
    %                     kEnd = data.postprocess.(data.nameSave{i}).pushIndex(k,2);
    %                     data.postprocess.(data.nameSave{i}).(namesField{j})(kStart:kEnd) = temporary(k);        % Assummed the correct order is always present in data - search can be coded later
    %                 end
    %             else
    %                 % Should in theory never enter this - however, check coded to be performed
    %                 error('Special length of variable found - check what this is and code what to do')
    %             end
    %         end
    %     end
end

data.name(removeID)       = []; 
data.nameSave(removeID)   = []; 



