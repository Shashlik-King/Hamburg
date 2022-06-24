function data = ZoneDetermination(settings, data, i, Method)
%%%-------------------------------------------------------------------------%%%
% function zone = ZoneDetermination(xvalue, yvalue, card)
% This function checks which zone a specific point is in, from one of the
% Robertsons Classification methods.
%
%       % data:     Data structure from script including all data available
%       % i:        Which location analysed (index in loop)
%       % Method:   Specify which classification method desired.
%
% Method: 1  Robertson, 1990, updated 2010
%            Zone determination based in Ic value
% Method: 2  Robertson, 1990 - Normalized CPT SBTn charts
%            Normalized friction ratio, Fr [%] & Normalized cone resistance, Qt [-]
% Method: 3  Robertson, 1990 - Normalized CPT SBTn charts
%            Pore pressure ratio, Bq [-] & Normalized cone resistance, Qt [-]
% Method: 4  Robertson, 1986 - CPT SBTn charts
%            Pore pressure ratio, Bq [-] & Normalized cone resistance, Qt [-]
% Method: 5  NOT WORKING YET - Robertson, 2009 - Equation based chart determination
%            Fr, Qtn & Ic
% Method: 11 Robertson, 1990, updated 2010 - COWI refinement
%            Zone determination based in Ic value
%
%
% PERFORMED WORK                    DATE
% ______________________________________________
% Coded by CONN                     04-07-2020

IDi = settings.loc{i};
loopIndex = data.postprocess.(IDi).CPTavail;
loopIndex = loopIndex(~isnan(loopIndex));
for III = 1:length(loopIndex)
    for j = loopIndex(III)
        IDj = strcat('SCPT',num2str(j));
        dat = data.postprocess.(IDi).(IDj);
        
        %% Update vector below if more methods are included in code
        methodsName = [ {1},{'Ic_Based'};           % Unique names for each method used
            {2},{'Rob1990FrQt'};
            {3},{'Rob1990BqQt'};
            {4},{'Rob1986Rfqt'};
            {5},{'Rob2009eq'};
            {6},{''}
            {7},{''}
            {8},{''}
            {9},{''}
            {10},{''}
            {11},{'Ic_Based_COWI'}
            {12},{'Rob1990FrQt_COWI'}];
        
        %% Define different methods
        % Read image, make color refs and x/y vectors for image (Different for each card)
        cardFolder = 'Functions\FigureBasis\ColorBasis';
        if Method == 2 || Method == 12
            Card = flipud(imread(fullfile(cardFolder,'Robertson_1990_normFr.png')));            % Loading the image
            xLimits = [0.1 10];             % x-limits for chart
            yLimits = [1 1000];             % y-limits for chart
            cref = [237 28 36;              % 1
                63 72 204;                  % 2
                255 174 201;                % 3
                112 146 190;                % 4
                185 122 87 ;                % 5
                255 127 39;                 % 6
                34 177 76;                  % 7
                255 242 0;                  % 8
                127 127 127];               % 9
            [nrows,ncols] = size(Card(:,:,1));
            y = logspace(0,3,nrows);
            x = logspace(-1,1,ncols);
            xvalue = dat.Fr;
            yvalue = dat.Qt;
        elseif Method == 3
            Card = flipud(imread(fullfile(cardFolder,'Robertson_1990_normBq.png')));              % Loading the image
            xLimits = [-0.6 1.4];           % x-limits for chart
            yLimits = [1 1000];             % y-limits for chart
            cref = [237 28 36;              % 1
                63 72 204;                  % 2
                255 174 201;                % 3
                112 146 190;                % 4
                185 122 87 ;                % 5
                255 127 39;                 % 6
                34 177 76];                 % 7
            [nrows,ncols] = size(Card(:,:,1));
            y = logspace(0,3,nrows);
            x = linspace(-0.6,1.4,ncols);
            xvalue = dat.Bq;
            yvalue = dat.Qt;
        elseif Method == 4
            Card = flipud(imread(fullfile(cardFolder,'Robertson_1986_Rf.png')));              % Loading the image
            xLimits = [0 8];           % x-limits for chart
            yLimits = [0.1 100];             % y-limits for chart
            cref = [237 27 36;              % 1
                63 71 204;                  % 2
                254 174 201;                % 3
                112 146 191;                % 4
                185 122 87;                 % 5
                255 127 38;                 % 6
                35 177 77;                  % 7
                254 242 0;                  % 8
                127 127 127;                % 9
                163 73 163;                 % 10
                239 227 175;                % 11
                0 0 0];                     % 12
            [nrows,ncols] = size(Card(:,:,1));
            y = logspace(0,2,nrows);
            x = linspace(0,8,ncols);
            xvalue = dat.Rf;
            yvalue = dat.qc;
        end
        
        %% Loop over length of xvalue and yvalue, and determine zone
        if Method == 1
            %% Zone based on Ic value
            % based on Ic
            ZoneIcInterval = [2 inf 3.6;
                3 2.95 3.6;
                4 2.6 2.95;
                5 2.05 2.6;
                6 1.31 2.05;
                7 0 1.31];
            % Zone 1: N/A
            % Zone 8: N/A
            % Zone 9: N/A
            
            zone_save = NaN(length(dat.Ic),1);
            for j = 1:length(ZoneIcInterval)
                if j == 1
                    indexSBT = dat.Ic>=ZoneIcInterval(j,3);
                    zone_save(indexSBT) = ZoneIcInterval(j,1);
                else
                    indexSBT = dat.Ic<ZoneIcInterval(j,3);
                    zone_save(indexSBT) = ZoneIcInterval(j,1);
                end
            end
        elseif Method == 2 || Method == 3 || Method == 4 || Method == 12
            %% Zone determination from plot (finding color)
            zone_save = NaN(length(xvalue),1);
            for II = 1:length(xvalue)
                if and(xvalue(II)>xLimits(1),xvalue(II)<xLimits(2)) && and(yvalue(II)>yLimits(1),yvalue(II)<yLimits(2))     % Check if values are within the plot range
                    [~, yindex] = min(abs(y-yvalue(II)));
                    [~, xindex] = min(abs(x-xvalue(II)));
                    
                    % Color of the pixel
                    zone = nan;
                    pcol = [ Card(yindex,xindex,1) Card(yindex,xindex,2) Card(yindex,xindex,3)]; % Color reference
                    for ii = 1:size(cref,1)
                        if pcol == cref(ii,:)
                            zone = ii;
                            break
                        end
                    end
                    
                    if isnan(zone)
                        xindex = xindex - 1;
                        if xindex > 0
                            pcol = [ Card(yindex,xindex,1) Card(yindex,xindex,2) Card(yindex,xindex,3)]; % Color reference
                            for ii = 1:size(cref,1)
                                if pcol == cref(ii,:)
                                    zone = ii;
                                    break
                                end
                            end
                        end
                    end
                else    % If not within the chart limits
                    zone = nan;
                end
                zone_save(II) = zone;
            end
        elseif Method == 5
            %% Zone determination from equations - Robertson 2009
            Ic = dat.Ic;
            Qtn = dat.Qtn;
            zone_save = NaN(length(Qtn),1);
            for ii = 1:length(Qtn)
                if isnan(Ic(ii))
                    zone_save(ii) = NaN;
                else
                    if Qtn(ii) < 12*exp(-1.4*F_r(ii))
                        zone_save(ii) = 1;
                    elseif F_r(ii) > 1.5
                        if Qtn(ii) > 1/(0.005*(F_r(ii)-1)-0.0003*(F_r(ii)-1)^2-0.002)
                            if F_r(ii) > 4.5        % 8 eller 9 - create a if here
                                zone_save(ii) = 9;
                            else
                                zone_save(ii) = 8;
                            end
                        else
                            if Ic(ii) < 1.31  % Zone 7
                                zone_save(ii) = 7;
                            elseif Ic(ii) < 2.05  % Zone 6
                                zone_save(ii) = 6;
                            elseif Ic(ii) < 2.60  % Zone 5
                                zone_save(ii) = 5;
                            elseif Ic(ii) < 2.95  % Zone 4
                                zone_save(ii) = 4;
                            elseif Ic(ii) < 3.60  % Zone 3
                                zone_save(ii) = 3;
                            else                    % Zone 2
                                zone_save(ii) = 2;
                            end
                        end
                    elseif Ic(ii) < 1.31  % Zone 7
                        zone_save(ii) = 7;
                    elseif Ic(ii) < 2.05  % Zone 6
                        zone_save(ii) = 6;
                    elseif Ic(ii) < 2.60  % Zone 5
                        zone_save(ii) = 5;
                    elseif Ic(ii) < 2.95  % Zone 4
                        zone_save(ii) = 4;
                    elseif Ic(ii) < 3.60  % Zone 3
                        zone_save(ii) = 3;
                    else                    % Zone 2
                        zone_save(ii) = 2;
                    end
                end
            end
        elseif Method == 11     % COWI refined Ic method
            %% Zone based on Ic value - COWI refined method
            % based on Ic
            ZoneIcInterval = [2 inf 3.6;
                3.1 3.275 3.6;
                3.2 2.95 3.275;
                4.1 2.775 2.95;
                4.2 2.6 2.775;
                5.1 2.325 2.6;
                5.2 2.05 2.325;
                6.1 1.68 2.05;
                6.2 1.31 1.68;
                7   0    1.31];
            % Zone 1: N/A
            % Zone 8: N/A
            % Zone 9: N/A
            
            zone_save = NaN(length(dat.Ic),1);
            for j = 1:length(ZoneIcInterval)
                if j == 1
                    indexSBT = dat.Ic>=ZoneIcInterval(j,3);
                    zone_save(indexSBT) = ZoneIcInterval(j,1);
                else
                    indexSBT = dat.Ic<ZoneIcInterval(j,3);
                    zone_save(indexSBT) = ZoneIcInterval(j,1);
                end
            end
        else
            disp('Method for determination of zone not found')
        end
        
        
        % Refine methods COWI
        if Method == 12     % COWI refined Rob1990FrQt method with Ic value
            Limits = [NaN, NaN, 3.275, 2.775, 2.325, 1.68];
            for j = 1:length(zone_save)
                if zone_save(j) > 2.5 && zone_save(j) < 6.5
                    if dat.Ic(j) > Limits(zone_save(j))
                        zone_save(j) = zone_save(j)+0.1;
                    else
                        zone_save(j) = zone_save(j)+0.2;
                    end
                end
            end
        end
        
        dat.ZoneData.(methodsName{Method,2}) = zone_save;     % Save the zone index in the postprocessed data structure
        data.postprocess.(IDi).(IDj) = dat;
    end
end
