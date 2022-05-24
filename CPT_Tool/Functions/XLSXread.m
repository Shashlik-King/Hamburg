function data = XLSXread(settings,Folder)
%%%-------------------------------------------------------------------------%%%
% data = XLSXread(settings,Folder,values)
% Function for loading CPT data from XLSX file
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by KAGP                     14-09-2020

%% Identify filenames in folder
listingCheck = dir([Folder.Data.CPT]);                      % Get info on files in folder
listingCheck = {listingCheck.name};                         % Get names of files in folder

pattern = ".xlsx";                                          % Search pattern 
nameIndex = not(endsWith(listingCheck,pattern,'IgnoreCase',true));   % Index for files not .xlsx format
listingCheck(nameIndex) = [];                               % Remove all index not an .xlsx format

% [status, sheetsCheck] = xlsfinfo([Folder.Data.CPT,'/XLSX/',char(listingCheck')]);
% [~, data.name] = xlsfinfo(fullfile(Folder.Data.CPT,char(listingCheck')));
% [~, data.name] = xlsfinfo(fullfile(Folder.Data.CPT,listingCheck));
data.name = listingCheck;
% % Check if all positions shall be runned
if settings.runAll
    listing = data.name;     % If running all files in folder
else
    listing = settings.runLoc;
end

name=data.name;
for i =1:length(name)
    testName = name{i};
    testName(regexp(testName,'[-]')) = '_';         % Change '-' to '_' for MATLAB being able to use name
    data.nameSave{i} = testName(1:end-5);
end
%% Manually import data from xlsx-file by defining range and available parameters 
disp("Importing Excel-data with manually defined ranges in function 'XLSXread'. Ensure these are defined correctly")
for i = 1:length(listing)
    
%     num_data = xlsread(fullfile(Folder.Data.CPT,listingCheck{i}), listing{i}); % Reading depth, qt, fs, u2
    num_data = xlsread(['Data/CPT/',listingCheck{i}]); % Reading depth, qt, fs, u2
    %num_data(:,3) = [];
    var_data = {'z','qc','fs','u2'}; % Order of data. Option of choosing qc or qt here.
    unit_data = {'m','MPa','MPa','MPa'}; % Unit parameters must have
   
    for j=1:size(num_data,2)-1
         data.postprocess.(char(data.nameSave{i})).(char(var_data(j))) = num_data(:,j);
    end
data.postprocess.(char(data.nameSave{i})).pushIndex = [1,length(num_data(:,1))];
data.postprocess.(char(data.nameSave{i})).CAR = 0.75; %num_data(1,1);
data.postprocess.(char(data.nameSave{i})).PushNo = 1;

end


