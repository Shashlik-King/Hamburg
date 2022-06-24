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
counter = 0;
errorListing = [];
for i = 1:length(pos)
    try
        databaseWrite(settings,data.out.(pos{i}),'ControlPanel',(pos{i}));
    catch ME
        counter = counter+1;
        if counter == 1
            errorListing = {pos{i},{ME}};
        else
            errorListingNew = {pos{i},{ME}};
            errorListing = [errorListing;errorListingNew];
        end
    end
end

% Close MySQL-database
mysql('close')

disp('Finished uploading data - Check "errorLog" for any problems')
