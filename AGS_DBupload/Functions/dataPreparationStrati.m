function dataOut = dataPreparationStrati(settings,Folder)

listing1 = dir([Folder.Data.Strati,'\*.xls']);
listing2 = dir([Folder.Data.Strati,'\*.xlsx']);

listing = [listing1, listing2];
dataStrat = []; 

for i = 1:length(listing)
    dataNew = readcell(fullfile(Folder.Data.Strati,listing(1).name)); 
    dataStrat = [dataStrat;dataNew];
end

pos = unique(dataStrat(3:end,1));

for i = 1:length(pos)
    index = find(strcmp([dataStrat(:,1)],pos{i})); 
    
    name = dataStrat(index,1); 
    layer = dataStrat(index,2); 
    top = dataStrat(index,3); 
    bottom = dataStrat(index,4); 
    unit = dataStrat(index,5); 
    
    % Predefine arrays
    arrayStart = cell(length(name),1);
    arrayEnd = cell(length(name),3);
    
    % Insert array values
    rev = cell(size(name));
    rev(:) = {settings.rev.CPTdata}; 
    
    arrayStart(:,1) = {char(settings.ProjectID)}; 
    
    arrayEnd(:,1) = {'prelim'};
    arrayEnd(:,2) = {'DESIGNER'};
    arrayEnd(:,3) = {getenv('username')};
    
    saveName = name{1}; 
    saveName = regexprep(saveName,'-','');
    saveName = regexprep(saveName,' ',''); 
    
    dataOut.data.(saveName) = [arrayStart,name,rev,layer,top,bottom,unit,arrayEnd]; 
end

%data.nameOriginal = pos; 
dataOut.names = pos;