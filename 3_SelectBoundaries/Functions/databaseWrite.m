function databaseWrite(settings,data,dataDis,table,ID)
%--------------------------------------------------------------------------
% https://se.mathworks.com/help/database/ug/database.odbc.connection.sqlwrite.html#d123e64628

Project = char(settings.Proj);
if ~isempty(data)
    %--------------------------------------------------------------------------
    %% Database unique id's - Verify revisions
    %--------------------------------------------------------------------------
    id = ['"',ID,'"']; % name of id
    rev_global = settings.rev; % global revision no. for specified id to be used
    
    % check, if specified revision is available for specified id
    [rev]       = mysql(['select Rev from ',table,' where WTG_ID=',id,' and ProjID="',Project,'";']);
    
    % if specified revision exists for this id -> delete all
    if ismember(rev_global,rev) > 0
        if settings.delete
            mysqlstrDel = ['DELETE FROM ',table,' where WTG_ID=',id,' and Rev=',rev_global,' and ProjID="',Project,'";'];
            mysql(mysqlstrDel);
        else
            mysql('close')
            error("Can't upload data as revision, project and location ID already exist and 'settings.delete' = 0")
        end
    end
    
    %% Generate strings and save into database
    user = getenv('username');
    mysqlstr_ini = ['INSERT INTO ',table,'(ProjID,WTG_ID,Rev,layer,top,bottom,Ic_2,Ic_3,Ic_4,Ic_5,Ic_6,Ic_7,Ic_Dis,RobFrQt_1,RobFrQt_2,RobFrQt_3,RobFrQt_4,RobFrQt_5,RobFrQt_6,RobFrQt_7,RobFrQt_8,RobFrQt_9,RobFrQt_Dis,RobBqQt_1,RobBqQt_2,RobBqQt_3,RobBqQt_4,RobBqQt_5,RobBqQt_6,RobBqQt_7,RobBqQt_8,RobBqQt_9,RobBqQt_Dis'];
    
    mysqlstr_ini = [mysqlstr_ini,',inserted_by) VALUES '];
    mysqlstr_write = [mysqlstr_ini];
    dataLoop = data;
    for i = 1:size(dataLoop,1)      % LOOP OVER LAYER
        if i == 1
            mysqlstr = ['("'];
        else
            mysqlstr = [', ("'];
        end
        
        % insert values in string
        mysqlstr = [mysqlstr,[Project,'","',ID,'","',rev_global,'",',num2str(dataLoop(i,1)),',',num2str(dataLoop(i,2)),',',num2str(dataLoop(i,3))]];
        
        % insert values in string
        for j = 1:size(dataDis,2) % LOOP OVER DB COLUMNS
            if isnumeric(dataDis{i,j})
                mysqlstr = [mysqlstr,',',num2str(dataDis{i,j})];
            else
                mysqlstr = [mysqlstr,[',',dataDis{i,j},'']];
            end
        end
        
        % Close string
        mysqlstr = [mysqlstr,',"',user,'")'];
        mysqlstr_write = [mysqlstr_write, mysqlstr];
    end
    mysqlstr_write = [mysqlstr_write,';'];      % End syntax
    mysql(mysqlstr_write);                      % Run syntax and upload to db
end