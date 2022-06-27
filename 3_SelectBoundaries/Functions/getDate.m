function strOut = getDate()
t = datetime('now');

dateFull = datestr(t);
% datestr(t,'mm/dd/yy')
dateStr = datestr(t,'yyyy-mm-dd');
strOut = [dateStr,'_',strrep(dateFull(end-7:end),':','')];