%%%%% SCRIPT FOR UPLOADING AGS DATA TO DATABASE
close all; clear; clc;
addpath('Functions');

settings.runAll = 1;
settings.Locations = "";

% Database inpit
settings.db.Name ='owdb';         % Database name
settings.db.Serv ='DKLYCOPILOD1';  % Databse server
settings.db.User ='owdb_user';    % Database user
settings.db.Pass ='ituotdowdb';   % Database pass


% Upload and revision
settings.upload = 1;            % Switch
settings.delete = 1;            % Switch - allow script to delete in database if existing revision, project and location ID exist
settings.ProjectID = "TEST";
settings.rev = '01';

% Folders
Folder.Data = 'Files';

%% Read AGS data
data = AGSread(settings,Folder);         % Function for reading CPT data from AGS format

%% CREATE LOG FOR DATA ERRORS
errorList = errorLOG(data.disOverview); 

%% Upload to database
if settings.upload
    errorUpload = DBupload(settings,data); 
end

%% Export log of run
% fmt = "yyyy "
save(strcat('log (',string(datetime('now')),')'))
