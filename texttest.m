%# read the file
filename = 'test.lab';
fid = fopen(filename,'r');
lines = textscan(fid,'%s','Delimiter','\n','HeaderLines',1);
x=textscan(lines{1},'%f');
fclose(fid);
