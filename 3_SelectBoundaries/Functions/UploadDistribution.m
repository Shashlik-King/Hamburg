function out = UploadDistribution(dataDis)

zo.Ic_Based = [2,3,4,5,6,7];
zo.Rob1990FrQt = [1,2,3,4,5,6,7,8,9];
zo.Rob1990BqQt = [1,2,3,4,5,6,7,8,9];

dim2 = 24+3;

out = cell(size(dataDis.zone.Distribution,2),dim2);

for i = 1:size(dataDis.zone.Distribution,2)      % LOOP OVER LAYERS                
    counter = 0; 
    
    for j = 1:size(dataDis.zone.Distribution,1)         % LOOP OVER METHODS
        zones = zo.(dataDis.zone.Methods{j}); 
        dataLay = dataDis.zone.Distribution{j,i};
        for k = 1:length(zones) 
            counter = counter+1; 
            idxZone = find(dataLay(:,1)==zones(k));
            if isempty(idxZone)
                out{i,counter} = 'NULL';
            else
                out{i,counter} = dataLay(idxZone,2)/dataDis.NoData(i)*100;
            end
        end
        counter = counter+1; 
        out{i,counter} = (dataDis.NoData(i)-sum(dataLay(:,2)))/dataDis.NoData(i)*100;
        
    end
end
test = 1; 