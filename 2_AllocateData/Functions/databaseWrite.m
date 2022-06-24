function databaseWrite(settings,data,table,ID)
%--------------------------------------------------------------------------
% https://se.mathworks.com/help/database/ug/database.odbc.connection.sqlwrite.html#d123e64628

Project = char(settings.Proj);
if ~isempty(data)
    %--------------------------------------------------------------------------
    %% Database unique id's - Verify revisions
    %--------------------------------------------------------------------------
    id = ['"',ID,'"']; % name of id
    rev_global = settings.rev; % global revision no. for specified id to be used
    rev_data = settings.revDat;
    rev_WTG = settings.revWTG;
    
    %% Check for any existing assigned test for the position
    [LOCA_ID, Rev] = mysql(['select LOCA_ID, Rev from ControlPanel where ProjID="',Project,'" and MainRev="',rev_global,'" and WTG_ID="',ID,'"']);
    
    % if specified revision exists for this id -> delete all
    if ~isempty(LOCA_ID)
        if settings.delete == 1     % Will delete all information for specific position with specified revision
            mysqlstrDel = ['DELETE FROM ',table,' where WTG_ID=',id,' and MainRev=',rev_global,' and ProjID="',Project,'";'];
            mysql(mysqlstrDel);
        elseif settings.delete == 2     % Delete only if DB row match new line to be uploaded
            for i = 1:length(LOCA_ID)
                idxLoc = strcmp(data(:,1),LOCA_ID{i});
                if any(idxLoc) && Rev{i}==rev_data
                    mysqlstrDel = ['DELETE FROM ',table,' where WTG_ID=',id,' and MainRev=',rev_global,' and ProjID="',Project,'" and LOCA_ID="',LOCA_ID{i},'" and Rev = "',rev_data,'";'];
                    mysql(mysqlstrDel);
                end
            end
        else
            mysql('close')
            error("Can't upload data as revision, project and location ID already exist with defined information and 'settings.delete' = 0")
        end
    end
    
    %% Generate strings and save into database
    user = getenv('username');
    mysqlstr_ini = ['INSERT INTO ',table,'(ProjID,MainRev,WTG_ID,WTG_Rev,LOCA_ID,Rev,Distance'];
    
    mysqlstr_ini = [mysqlstr_ini,',inserted_by) VALUES '];
    mysqlstr_write = [mysqlstr_ini];
    dataLoop = data;
    for i = 1:size(dataLoop,1)
        if i == 1
            mysqlstr = ['("'];
        else
            mysqlstr = [', ("'];
        end
        
        % insert values in string
        mysqlstr = [mysqlstr,[Project,'","',rev_global,'","',ID,'","',rev_WTG,'","',dataLoop{i,1},'","',rev_data,'",',num2str(dataLoop{i,2})]];
        
        % Close string
        mysqlstr = [mysqlstr,',"',user,'")'];
        mysqlstr_write = [mysqlstr_write, mysqlstr];
    end
    mysqlstr_write = [mysqlstr_write,';'];      % End syntax
    mysql(mysqlstr_write);                      % Run syntax and upload to db
end