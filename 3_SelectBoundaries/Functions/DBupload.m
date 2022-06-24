function errorListing = DBupload(settings,data)

pos = settings.loc;

% Database settings
databaseName =settings.db.Name;     % Database name
databaseServ =settings.db.Serv;     % Databse server
databaseUser =settings.db.User;     % Database user
databasePass =settings.db.Pass;     % Database pass

% Access MySQL-database
mysql('open',databaseServ,databaseUser,databasePass); % ('open','server','username','password')
mysql(['use ',databaseName]); % name of database

% Loop around tables to be uploaded
errorListing = {};
for i = 1:length(pos)
    dataDis = UploadDistribution(data.postprocess.(pos{i}));
    try
        if ~all(isnan(data.postprocess.(pos{i}).stratigraphy))
            databaseWrite(settings,data.postprocess.(pos{i}).stratigraphy,dataDis,'stratigraphy',(pos{i}));
        else
            errorListingNew = {pos{i},{'No data found for position'}};
            errorListing = [errorListing;errorListingNew];
        end
    catch ME
        errorListingNew = {pos{i},{ME}};
        errorListing = [errorListing;errorListingNew];
    end
end


% Close MySQL-database
mysql('close')

disp('Finished uploading data')
