function errorListing = DBupload(settings,data)

pos = fieldnames(data.Upload);


% Database settings
databaseName =settings.db.Name;     % Database name
databaseServ =settings.db.Serv;     % Databse server
databaseUser =settings.db.User;     % Database user
databasePass =settings.db.Pass;     % Database pass

% % Access MySQL-database
mysql('open',databaseServ,databaseUser,databasePass); % ('open','server','username','password')
mysql(['use ',databaseName]); % name of database


% % Loop around tables to be uploaded
counter = 0; 
errorListing = []; 
for i = 1:length(pos)
    groups = fieldnames(data.Upload.(pos{i}));
    for j = 1:length(groups)
        try
            databaseWrite(settings,data.Upload.(pos{i}).(groups{j}),groups{j}); 
        catch ME
            counter = counter+1; 
            if counter == 1
                errorListing = {pos{i},groups{j},{ME}};
            else
                errorListing = {pos{i},groups{j},{ME}};
                errorListing = [errorListing;errorListingNew];
            end
            
        end
    end
end

% Close MySQL-database
mysql('close')

disp('Finished uploading data')
