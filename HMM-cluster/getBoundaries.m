function [ boundaries ] = getBoundaries( labels )
% get boundaries from the label sequence
lastValue   = -1;
boundaries  = [];
for i=1:length(labels)
    if labels(i)    ~= lastValue
        boundaries  = [boundaries;i];
        lastValue   = labels(i);
    end
end
end

