function Exportfunction(data,Folder,settings)

%% Create with data
positions = fieldnames(data.postprocess);
for i = 1:length(positions)
    variables = fieldnames(data.postprocess.(positions{i}));
    vecL = length(data.postprocess.(positions{i}).z);
    Table = [];
    for j = 1:length(variables)
        if isstruct(data.postprocess.(positions{i}).(variables{j}))
            try
                Column = data.postprocess.(positions{i}).(variables{j}).values;
                if isnumeric(Column)
                    Column = num2cell(Column);
                end
                varSTR = cell(1,size(data.postprocess.(positions{i}).(variables{j}).values,2));
                varSTR(1,1:size(data.postprocess.(positions{i}).(variables{j}).values,2)) = {variables{j}};
                meth = data.postprocess.(positions{i}).(variables{j}).methods;
                Table = [Table,[varSTR; meth; Column]];
            catch
                strucField = fieldnames(data.postprocess.(positions{i}).(variables{j}));
                for k = 1:length(strucField)
                    if length(data.postprocess.(positions{i}).(variables{j}).(strucField{k})) == vecL
                        varSTR = variables(j);
                        meth = strucField(k);
                        Column = data.postprocess.(positions{i}).(variables{j}).(strucField{k});
                        if isnumeric(Column)
                            Column = num2cell(Column);
                        end
                        Table = [Table,[varSTR; meth; Column]];
                    end
                end
            end
        else
            if length(data.postprocess.(positions{i}).(variables{j})) == vecL
                if isnumeric(data.postprocess.(positions{i}).(variables{j}))
                    Column = num2cell(data.postprocess.(positions{i}).(variables{j}));
                else
                    Column = data.postprocess.(positions{i}).(variables{j});
                end
                Table = [Table,[variables{j};{''} ;Column]];
            end
        end
    end
    % Export data to excel
    writecell(Table,fullfile(Folder.Output,'OutputData.xlsx'),'Sheet',positions{i}); % Clean up the excel file before running the script
end