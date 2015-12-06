%where is the ground truth?
groundTruthDir      = 'Structural_Segmentation';

%where is the audio data?
audioDir            = '/Volumes/Document/GTCMT/Computational Music Analysis MUSI6201/Structural_Segmentation/'; 

groundTruthFileList = dir(groundTruthDir);
audioFileList       = dir(audioDir);
numOfFiles          = (length(audioFileList)-4);

% generate a normal distribution for training
indicesOfNorm = [-1:.1:1];
norm = normpdf(indicesOfNorm,0,1);
for i = 5:length(audioFileList)
    
    %is current fileID a folder?
    if audioFileList(i).isdir == 1
        subfolder            = audioDir+'/'+ audioFileList(i).name;
        filesListOfSubfolder = dir(subfolder);
        
        % traverse all the files in the subfolder(note the start index of
        % j, it is different from i
        
        for j = 1:length(filesListOfSubfolder)
           % For each audio file, do the following:
           
           % 1. obtain low level feature
           

           % generate a emission probability matrix for training
            emsProb  = zeros(80,21); % initialization
            for k=1:80
                emsProb(k,:)=norm;
            end
           % generate a transition probability matrix for training
           transProb = ones(80,80)./80;
           
           % train the HMM with the initial emission probability matrix and
           % transmition probability matrix
           [estTR,estE] = hmmtrain(seqs,transProb,emsProb);

           
        end



% train the 80-state HMM by using initial 

% add
           
        end
    end
  %  [X,fs]    = audioread([audioDir,'/',audioList(i+1).name]);

%preprocessing for input audio file



end
