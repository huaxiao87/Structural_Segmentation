% main
%where is the ground truth?
groundTruthDir      = '/Volumes/Document/Dataset/QMUL_beatles/The Beatles Annotations/seglab/The Beatles';

%where is the audio data?
audioDir            = '/Volumes/Document/Dataset/QMUL_beatles'; 

groundTruthFileList = dir(groundTruthDir);
audioFileList       = dir(audioDir);
numOfFiles          = (length(audioFileList)-4);

stateNum            = 80; % number of states 
neighbouringBeatNum = 15;  % number of neighbouring beats

precision           = 0;
recall              = 0;
fmeasure            = 0;
numFiles            = 0;

for i = 5:12%length(audioFileList)
    
    %is current fileID a folder?
    if audioFileList(i).isdir == 1
        subfolder            = strcat(audioDir , '/', audioFileList(i).name);
        filesListOfSubfolder = dir(subfolder);
        
        % traverse all the files in the subfolder(note the start index of
        % j, it is different from i
        
        for j = 3:length(filesListOfSubfolder)
            if j~=8
           % For each audio file, do the following:
            audioFile     = strcat(audioDir,'/',audioFileList(i).name,'/',filesListOfSubfolder(j).name);
            [featMat,bpm]   = getLowLevelFeatures(audioFile);
            seq             = getStateSequence(featMat,stateNum);
            idx             = histogramClustering( seq, neighbouringBeatNum, stateNum );
            boundaries      = getBoundaries(idx);%get boundaries among segments
            secPerBeat      = 60/bpm;
            boundariesInSec = boundaries .* secPerBeat; 
            
            deltaTime       = secPerBeat * 12 *1000;  % tolerance in milliseconds
            groundTruthFile = strcat(groundTruthDir,'/',groundTruthFileList(i).name,'/',strrep(filesListOfSubfolder(j).name,'.wav','.lab'));
            annotation      = labRead(groundTruthFile);
            annotation      = [0;annotation(:,2)];
            
            % evaluation
            [P,R,F]         = evaluateSeg(boundariesInSec,annotation,deltaTime);
    
            %sum up the value of the three varibles
            precision   = precision + P;
            recall      = recall + R;
            fmeasure    = fmeasure + F;
            numFiles    = numFiles + 1;
            end
        end
    end
averagePrecision    = precision / numFiles;
averageRecall       = recall / numFiles;
averageFMeasure     = fmeasure / numFiles;
           
end

 
