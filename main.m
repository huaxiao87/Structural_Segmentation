% main
stateNum            = 80; % number of states 
neighbouringBeatNum = 15;  % number of neighbouring beats



 featMat    = getLowLevelFeatures('Hey Jude-The Beatles.mp3');
 seq        = getStateSequence(featMat,stateNum);
 idx        = histogramClustering( seq, neighbouringBeatNum, stateNum );
 plot(idx)
