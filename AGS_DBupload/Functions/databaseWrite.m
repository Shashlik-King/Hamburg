function databaseWrite(settings,data,table)
%--------------------------------------------------------------------------
% https://se.mathworks.com/help/database/ug/database.odbc.connection.sqlwrite.html#d123e64628

Project = char(settings.ProjectID);
if size(data,1) > 3
    %--------------------------------------------------------------------------
    %% Database unique id's - Verify revisions
    %--------------------------------------------------------------------------
    idx = strcmp(data(1,:),'LOCA_ID');
    id = data{4,idx};
    id = ['"',id,'"']; % name of id
    rev_global = settings.rev; % global revision no. for specified id to be used
    
    % check, if specified global revision is available for specified id
    [rev]       = mysql(['select Rev from ',table,' where LOCA_ID=',id,' and ProjID="',Project,'";']);
    
    % if specified revision exists for this id -> delete all
    if ismember(rev_global,rev) > 0
        if settings.delete
            mysqlstrDel = ['DELETE FROM ',table,' where LOCA_ID=',id,' and Rev=',rev_global,' and ProjID="',Project,'";'];
            mysql(mysqlstrDel);
        else
            mysql('close')
            error("Can't upload data as revision, project and location ID already exist and 'settings.delete' = 0")
        end
    end
    
    %% Generate strings and save into database
    mysqlstr_ini = ['INSERT INTO ',table,'(ProjID,Rev'];
    for i = 2:size(data,2)
        mysqlstr_ini = [mysqlstr_ini,',',data{1,i}];
    end
    mysqlstr_ini = [mysqlstr_ini,') VALUES '];
    mysqlstr_write = [mysqlstr_ini];
    dataLoop = data(4:end,2:end);
    for i = 1:size(dataLoop,1)
        if i == 1
            mysqlstr = ['("',Project,'","',rev_global,'",'];
        else
            mysqlstr = [', ("',Project,'","',rev_global,'",'];
        end
        
        % insert values in string
        for j = 1:size(dataLoop,2) % p_top_values
            if j ~= 1
                mysqlstr = [mysqlstr,','];
            end
            if isnumeric(dataLoop{i,j})
                if isempty(dataLoop{i,j}) || isnan(dataLoop{i,j})
                    mysqlstr = [mysqlstr,'NULL'];
                else
                    mysqlstr = [mysqlstr,num2str(dataLoop{i,j})];
                end
            else
                if isempty(dataLoop{i,j})
                    mysqlstr = [mysqlstr,'NULL'];
                else
                    mysqlstr = [mysqlstr,['"',dataLoop{i,j},'"']];
                end
            end
        end
        mysqlstr = [mysqlstr,')'];
        mysqlstr_write = [mysqlstr_write, mysqlstr];
    end
    mysqlstr_write = [mysqlstr_write,';'];      % End syntax
    mysql(mysqlstr_write);                      % Run syntax and upload to db
end