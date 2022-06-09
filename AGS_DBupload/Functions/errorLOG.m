function errorList = errorLOG(data)

pos = fieldnames(data);

% Find unique errors 
errorList.Unique = []; 
for i = 1:length(pos) 
    ER = fieldnames(data.(pos{i}));
    errorListInd = []; 
    for j = 1:length(ER)
       new = data.(pos{i}).(ER{j}); 
       errorListInd = [errorListInd;new]; 
    end
    errorList.Pos.(pos{i}) = errorListInd; 
    errorList.Unique = [errorList.Unique;errorListInd]; 
    test =1 ; 
end

errorList.Unique = unique(errorList.Unique);

for i = 1:length(errorList.Unique)
    ER = errorList.Unique{i};
    counter = 0; 
    for j = 1:length(pos)
        if any(strcmp(errorList.Pos.(pos{j}),ER))
            counter = counter+1; 
            if counter == 1
                errorList.Mes.(ER) = []; 
            end
            errorList.Mes.(ER) = [errorList.Mes.(ER);pos(j)];
        end
    end
end
