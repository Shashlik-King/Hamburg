%% Script for reading AGS format
close all; clear all; clc;
addpath('Functions');

%% Info and settings
if 1
    [settings] = readSettings;
else
    settings.Proj = 'Test';             % Project ID
    settings.rev = '01';                % Main revision from "ControlPanel" DB 
    settings.locAll = 1;                % 1) Run for all WTG found in database; 0) Run for defined pos
    %settings.loc = {'WTG01','WTG02','WTG03','WTG04','WTG05','WTG06','WTG07','WTG08','WTG09','WTG10','WTG11'};
    settings.loc = {'WTGB01'};
%     settings.upload = 1;                
%     settings.delete = 1;
    settings.maxDistance = 50;          % Maximum allowable distance between WTG position and test - 5*D recommended as limit 

    % Database input
    settings.db.Name ='owdb';           % Database name
    settings.db.Serv ='DKLYCOPILOD1';   % Databse server
    settings.db.User ='owdb_user';      % Database user
    settings.db.Pass ='ituotdowdb';     % Database pass
end

%% Load data from database
[data] = DBread(settings);

%% Plot
sitePlot(settings,data)


%% Save workspace for log
clear i j
if ~exist('Log', 'dir')
    mkdir('Log')
end
dateSTR = getDate;
save(['Log\',dateSTR])
