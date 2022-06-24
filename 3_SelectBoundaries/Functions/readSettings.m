function settings = readSettings




filename = 'Input.txt';
delimiterIn = ' ';
headerlinesIn = 1;
% settings = importdata(filename,delimiterIn,headerlinesIn);
settings = textscan(filename)