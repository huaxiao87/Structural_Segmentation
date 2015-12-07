% y: n * 2 matrix of boundaries in double

function [y] = labRead(filename);
fid = fopen(filename,'r');
lines = textscan(fid,'%s','Delimiter','\n','HeaderLines',1);
lines = lines{1};
fclose(fid);

n = size(lines,1);

for i = 1:n
    s(i,:) = strsplit(lines{i});
    for j = 1:2
        s{i,j} = str2double(s{i,j});
    end
end

y = cell2mat(s(:,1:2));




