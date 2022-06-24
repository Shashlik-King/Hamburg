function [data] = DBread(settings)
%%%%%%%% Read from database
%% Database settings
databaseName =settings.db.Name;     % Database name
databaseServ =settings.db.Serv;     % Databse server
databaseUser =settings.db.User;     % Database user
databasePass =settings.db.Pass;     % Database pass

Project = settings.Proj;            % Project ID in database "ProjID"
rev = settings.revWTG;              % Revision in database "Rev" for WTG
revDat = settings.revDat;           % Revision in database "Rev" for LOCA test

%% Access MySQL-database
mysql('open',databaseServ,databaseUser,databasePass); % ('open','server','username','password')
mysql(['use ',databaseName]); % name of database

%% Find location information for Project and Rev
[WTG,Coord_N,Coord_E] = mysql(['select WTG_ID, Coord_N, Coord_E from Overview_WTG where ProjID="',Project,'" and WTG_Rev="',rev,'"']);
data.WTG = [WTG,num2cell(Coord_N),num2cell(Coord_E)]; 

%% Get data from database
%[data_rev,LOCA_ID] = mysql(['select Rev, LOCA_ID from ControlPanel where ProjID="',Project,'" and MainRev="',rev,'" and WTG_ID="',WTG{i},'" and DATA_GROUP="SCPT"']);
[LOCA_ID,coorN,coorE,LOCX,LOCY] = mysql(['select LOCA_ID, LOCA_NATE, LOCA_NATN, LOCA_LOCX, LOCA_LOCY from LOCA where ProjID="',Project,'" and Rev="',revDat,'"']);
data.LOCA = [LOCA_ID,num2cell(coorN),num2cell(coorE),num2cell(LOCX),num2cell(LOCY)];

%% Close MySQL-database
mysql('close')
