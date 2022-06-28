function data = WTGallocating(settings,data)


for i = 1:length(settings.loc)                      % Loop around all locations found in the AGS files
    disp(settings.loc{i})                                              % Display name in command window
    
    % Define WTG coordinates
    idx = strcmp(data.WTG(:,1),settings.loc{i});
    WTGcoordN = data.WTG{idx,2};
    WTGcoordE = data.WTG{idx,3};
    
    % Loop through the list of performed tests
    counter = 0; 
    out = {}; 
    for j = 1:size(data.LOCA)
        if ~any(isnan([data.LOCA{j,2:3}]))
            testN = data.LOCA{j,2};
            testE = data.LOCA{j,3};
        elseif ~any(isnan([data.LOCA{j,4:5}]))
            testN = data.LOCA{j,4};
            testE = data.LOCA{j,5};
        else
            disp(strcat('No coordinates found for test: ',data.LOCA{j,1}))
        end
        dis = sqrt((WTGcoordN-testN)^2+(WTGcoordE-testE)^2);
        
        if dis < settings.maxDistance
           counter = counter+1; 
           out(counter,:) = [data.LOCA(j,1),{dis}];
        end
        
    end
    
    data.out.(settings.loc{i}) = out; 
    clear out
end