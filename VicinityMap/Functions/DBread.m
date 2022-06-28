function [data] = DBread(settings)
%%%%%%%% Read from database
%% Database settings
databaseName =settings.db.Name;     % Database name
databaseServ =settings.db.Serv;     % Databse server
databaseUser =settings.db.User;     % Database user
databasePass =settings.db.Pass;     % Database pass

Project = settings.Proj;            % Project ID in database "ProjID"
rev = settings.rev;              % Revision in database "Rev" for WTG

%% Access MySQL-database
mysql('open',databaseServ,databaseUser,databasePass); % ('open','server','username','password')
mysql(['use ',databaseName]); % name of database

%% Find project overview in ControlPanel
[WTG_ID, WTG_Rev, LOCA_ID, LOCA_Rev] = mysql(['select WTG_ID, WTG_Rev, LOCA_ID, Rev from ControlPanel where ProjID="',Project,'" and MainRev="',rev,'"']);
data.CP = [WTG_ID,WTG_Rev,LOCA_ID,LOCA_Rev]; 

%% Get WTG position ID
WTGrev_uni = unique(WTG_Rev);
[WTG, Coord_N, Coord_E] = mysql(['select WTG_ID, Coord_N, Coord_E from Overview_WTG where ProjID="',Project,'" and WTG_Rev="',WTGrev_uni{1},'"']);
data.WTG = [WTG,num2cell(Coord_N),num2cell(Coord_E)]; 

%% Get data from database
rev_TEST = unique(LOCA_Rev); 
for i = 1:length(rev_TEST)
    revStr = strcat('Rev',rev_TEST{i});
    %[data_rev,LOCA_ID] = mysql(['select Rev, LOCA_ID from ControlPanel where ProjID="',Project,'" and MainRev="',rev,'" and WTG_ID="',WTG{i},'" and DATA_GROUP="SCPT"']);
    [data.TEST.LOCA_ID.(revStr),data.TEST.coorN.(revStr),data.TEST.coorE.(revStr),data.TEST.LOCX.(revStr),data.TEST.LOCY.(revStr)] = mysql(['select LOCA_ID, LOCA_NATE, LOCA_NATN, LOCA_LOCX, LOCA_LOCY from LOCA where ProjID="',Project,'" and Rev="',rev_TEST{i},'"']);
    %data.LOCA = [LOCA_ID,num2cell(coorN),num2cell(coorE),num2cell(LOCX),num2cell(LOCY)];
end
%% Close MySQL-database
mysql('close')
