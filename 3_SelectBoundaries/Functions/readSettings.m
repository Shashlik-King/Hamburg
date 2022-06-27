function [settings,plots,values] = readSettings

filename = 'Input.txt';
delimiterIn = ' ';
headerlinesIn = 1;
% settings = importdata(filename,delimiterIn,headerlinesIn);
% settings = textscan(filename)


fid = fopen(filename,'rt');
counter = 1;
while true
    thisline = fgetl(fid);
    if ~ischar(thisline)
        break
    elseif ~isempty(thisline)
        storedData{counter,1} = thisline;
        counter = counter+1;
    end  %end of file
    %now check whether the string in thisline is a "word", and store it if it is.
    %then
end
fclose(fid);

for i = 1:length(storedData)
    dat = storedData{i};
    idxEq   = strfind(dat,'=');
    idxEnd = strfind(dat,';');
    
    name = dat(1:idxEq-1);
    val = dat(idxEq+1:idxEnd-1);
    test = 1;
    val = val(find(~isspace(val)));
    if ~isempty(name) && ~strcmp(name(1),'%')
        if contains(name,'settings.db.')
            nameSave = erase(name,'settings.db.');
            nameSave = nameSave(find(~isspace(nameSave)));
            settings.db.(nameSave) = eval(val);
        elseif contains(name,'settings.')
            nameSave = erase(name,'settings.');
            nameSave = nameSave(find(~isspace(nameSave)));
            settings.(nameSave) = eval(val);
        elseif contains(name,'plots.')
            nameSave = erase(name,'plots.');
            nameSave = nameSave(find(~isspace(nameSave)));
            plots.(nameSave) = eval(val);
        elseif contains(name,'values.unitWeight.')
            nameSave = erase(name,'values.unitWeight.');
            nameSave = nameSave(find(~isspace(nameSave)));
            values.unitWeight.(nameSave) = eval(val);
        elseif contains(name,'values.')
            nameSave = erase(name,'values.');
            nameSave = nameSave(find(~isspace(nameSave)));
            values.(nameSave) = eval(val);
        end
    end
end


