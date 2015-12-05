%% Standard evaluation metrics 
% [precision, recall, fmeasure] = evaluateOnsets(onsetTimeInSec, annotation, deltaTime)
% intput:
%   onsetTimeInSec: n by 1 float vector, detected onset time in second
%   annotation: m by 1 float vector, annotated onset time in second
%   deltaTime: float, maximum time difference for a true positive (millisecond) 
% output:
%   precision: float, fraction of TP from all detected onsets
%   recall: float, fraction of TP from all reference onsets
%   fmeasure: float, the combination of precision and recall

function [precision, recall, fmeasure] = fmeasure(onsetTimeInSec, annotation, deltaTime)
if isempty(onsetTimeInSec) || isempty(annotation)
    precision   = 0;
    recall      = 0;
    fmeasure    = 0;  
else    
    % initialization
    truePositive    = 0;
    detectedOnsets  = length(onsetTimeInSec);
    dTime           = deltaTime/1000;
    totalRefOnsets  = length(annotation);

    %count the truePositive
    %for each element in onsetTimeInSec, check if there exists any element in
    %annotation that is within the tolerance range(deltaTime). If so, then
    %the number of truePositive increase by 1
    for i = 1:length(onsetTimeInSec)
        for j= 1:length(annotation)
            if annotation(j) <= onsetTimeInSec(i)+dTime && annotation(j)>= onsetTimeInSec(i)-dTime
            truePositive    = truePositive + 1;
            annotation(j)   = [];
            break
            end
        end
    end

    precision       = truePositive / detectedOnsets;
    recall          = truePositive / totalRefOnsets;
    fmeasure        = 2 * precision * recall / (precision + recall);
end