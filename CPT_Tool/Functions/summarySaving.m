function summarySaving(settings,Folder,data,i)
% Function for saving selected and calculated layer data in summary file
%
% PERFORMED WORK                            DATE
% ______________________________________________
% Coded by CONN                             06-07-2020
% Update for saving 2 Robertson, CONN       14-08-2020

userInitials = getenv('USERNAME');                                                      % Get initials of the person running the script

if exist(fullfile(Folder.Output,settings.Files.Output),'file')                                 % Check if summary file exist
    output.Matrix = readcell(fullfile(Folder.Output,settings.Files.Output));                   % Loading data from existing excel sheet - Specify sheet if more data stored in the excel file
    
    % Check if any indexes is missing and if so replace with 'N/A'
    checkMis = cellfun(@ismissing, output.Matrix, 'UniformOutput', false);
    if any(any(cellfun(@(x)isequal(x,1),checkMis)))
        %checkNaN = cellfun(@isnan, output.Addition, 'UniformOutput', false);
        checkOneMis = cellfun(@(x)isequal(x,1),checkMis);
        [row,col] = find(checkOneMis);
        for j = 1:length(row)
            output.Matrix{row(j),col(j)} = 'MISSING';
        end
    end
    
    output.ObsoleteMatrix = output.Matrix;                                              % Save original read data for comparison (manual check)
    fileExist = 1;
else
    output.Matrix = [{'Location'},{'Layer'},{'Top level'},{'Bottom level'},{'Unit'},{'Method'},{'Rob. zone distribution 1'},{'Rob. Zone 1'},{'SBT 1'},{'Rob. zone distribution 2'},{'Rob. Zone 2'},{'SBT 2'},{'Preparer'},{'Date'},{'QA´er'},{'Date'}; {'[-]'},{'[No.]'},{'[mBSL]'},{'[mBSL]'},{'[-]'},{'[-]'},{'[%]'},{'[-]'},{'[-]'},{'[%]'},{'[-]'},{'[-]'},{'[Initials]'},{'[dd-mmm-yy]'},{'[Initials]'},{'[dd-mmm-yy]'}];
    fileExist = 0;
end
indexDelete = find(strcmp(output.Matrix(:,1),data.nameSave{i}));                        % Find index for previous data with same location
if ~isempty(indexDelete)
    output.Matrix(indexDelete,:) = [];                                                  % If any previous data is found, they are deleted
end


% Determine data for preparer and QA'er
if settings.QAmode      % If in QA mode, the QA'er columns should be updated
    QAvector = [{userInitials}, {char(date)}];
    if isempty(indexDelete)
        InitialVector = [{'N/A'},{'N/A'}];
    else
        InitialVector = [output.ObsoleteMatrix(indexDelete(1),13:14)];                 % If any previous data is found, they are deleted
        if isdatetime(InitialVector{2})
            InitialVector{2} = datestr(InitialVector{2});
        end
    end
else    % if the
    InitialVector = [{userInitials}, {char(date)}];
    QAvector = [{'N/A'},{'N/A'}];
end

% Combine addition for location analysed and include in full matrix
output.Addition = cell(length(data.postprocess.(data.nameSave{i}).layerLevel)+1,16);    % Define cell array dimensions for new data
layer = [num2cell([0; data.postprocess.(data.nameSave{i}).layerLevel]); {round(data.postprocess.(data.nameSave{i}).z(end),1)}];
for j = 1:length(data.postprocess.(data.nameSave{i}).layerLevel)+1
    output.Addition(j,:) = [data.nameSave{i},{j},layer(j), layer(j+1), {'ToBeUpdated'},data.postprocess.(data.nameSave{i}).zone.Methods{1},data.postprocess.(data.nameSave{i}).zone.LocationSum{1}(j,1:end-1), InitialVector, QAvector];
end

% Check if layers are the same, if so then keep assigned unit (If same length and same layer boundary levels)
if size(output.Addition,1) == length(indexDelete) && isequal(output.ObsoleteMatrix(indexDelete(1:end-1),2:4),output.Addition(1:end-1,2:4))
    output.Addition(:,5) = output.ObsoleteMatrix(indexDelete,5);
end

% Convert any NaN to 'N/A'
checkNaN = cellfun(@isnan, output.Addition, 'UniformOutput', false);
if any(any(cellfun(@(x)isequal(x,1),checkNaN)))
    %checkNaN = cellfun(@isnan, output.Addition, 'UniformOutput', false);
    checkOne = cellfun(@(x)isequal(x,1),checkNaN);
    [row,col] = find(checkOne);
    for j = 1:length(row)
        output.Addition{row(j),col(j)} = 'N/A';
    end
end

% Save the updated data in file
output.Matrix = [output.Matrix; output.Addition];                                       % Collect all updated data in cell array "output.Matrix"
output.FinalMatrix = [output.Matrix(1:2,:);sortcell(output.Matrix(3:end,:), [1, 2])];   % Sorting the output.Matrix to ensure correct sorting of rows for position and layering
if fileExist
    writecell(cell(size(output.ObsoleteMatrix)),fullfile(Folder.Output,settings.Files.Output)) % Clear current data in excel sheet to ensure all previous data is overwritten
end
writecell(output.FinalMatrix,fullfile(Folder.Output,settings.Files.Output));                   % Write new data into excel sheet (also includes previous data for locations not analysed)

