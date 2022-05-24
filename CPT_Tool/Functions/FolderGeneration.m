function FolderGeneration(FolderName)
% Function for checking if folder exist - if not then
% generate a folder with the desired name


if exist(FolderName) == 7   % Check if folder exist (Folder id = 7 in exist function) 
    % Folder exist and no further actions required
else
    mkdir(FolderName)
end
