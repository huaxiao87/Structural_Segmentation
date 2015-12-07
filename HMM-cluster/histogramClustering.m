function [ clusterLabels ] = histogramClustering( stateSequence, neighbouringBeatNum, stateNum )
% clustering the state sequence by histogram clustering
% the histogram length specifys how many neighbouring states to be counted 
% in a histogram window

% using the window to break the state sequence into small blocks
histogramNum    =  length(stateSequence)-neighbouringBeatNum-1;% the number of histograms
histogramMatrix = zeros(histogramNum,stateNum);
for i = 1 : histogramNum
    % obtain individual blocks
    currentBlock            = stateSequence(i:(i + neighbouringBeatNum+1),1);
    histogramMatrix(i,:)    = histcounts(currentBlock,1:(stateNum+1));% count the states
end

clusterLabels = kmeans(histogramMatrix,6);% use k=6 to represent the common segmentation type is 6

% making histograms for each window


end

