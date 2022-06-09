function dataOut = dataPreparationCPT(settings,data)


valueName = {'z','qc','fs','u2','Rf','qt','ft','qe','bd','cpo','cpod','qn','frrc','Bq','Qt','Fr'};

pos = fieldnames(data.postprocess);

for i = 1:length(pos)
    for j = 1:length(valueName)
        if isfield(data.postprocess.(pos{i}),valueName{j})
            out.(pos{i}).(valueName{j}) = data.postprocess.(pos{i}).(valueName{j});
        else
            out.(pos{i}).(valueName{j}) = nan(length(data.postprocess.(pos{i}).z),1);
        end
    end
    
    % Predefine arrays
    arrayStart = cell(length(data.postprocess.(pos{i}).z),4);
    arrayEnd = cell(length(data.postprocess.(pos{i}).z),4);
    
    % Insert array values
    arrayStart(:,1) = {char(settings.ProjectID)}; 
    arrayStart(:,2) = data.name(i); 
    arrayStart(:,3) = {settings.rev.CPTdata}; 
    if iscell(data.postprocess.(pos{i}).PushNo)
        arrayStart(:,4) = data.postprocess.(pos{i}).PushNo;
    else
        arrayStart(:,4) = num2cell(data.postprocess.(pos{i}).PushNo);
    end
    arrayEnd(:,1) = {'Unit'};
    arrayEnd(:,2) = {'prelim'};
    arrayEnd(:,3) = {'CLIENT'};
    arrayEnd(:,4) = {getenv('username')};
    %arrayEnd(:,5) = {date};
    dataOut.(pos{i}) = [arrayStart,num2cell([out.(pos{i}).z,out.(pos{i}).qc,out.(pos{i}).fs,out.(pos{i}).u2,out.(pos{i}).Rf,out.(pos{i}).qt,out.(pos{i}).ft,out.(pos{i}).qe,out.(pos{i}).bd,out.(pos{i}).cpo,out.(pos{i}).cpod,out.(pos{i}).qn,out.(pos{i}).frrc,out.(pos{i}).Bq,out.(pos{i}).Qt,out.(pos{i}).Fr]),arrayEnd]; 
    
end