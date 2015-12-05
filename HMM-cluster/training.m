%where is the ground truth?
groundTruthDir      = 'Structural_Segmentation';

%where is the audio data?
audioDir            = '/Volumes/Document/GTCMT/Computational Music Analysis MUSI6201/Structural_Segmentation/'; 

groundTruthFileList = dir(groundTruthDir);
audioFileList       = dir(audioDir);
numOfFiles          = (length(audioFileList)-4);
for i = 5:length(audioFileList)
    
    %is current fileID a folder?
    if audioFileList(i).isdir == 1
        subfolder            = audioDir+'/'+ audioFileList(i).name;
        filesListOfSubfolder = dir(subfolder);
        
        % traverse all the files in the subfolder(note the start index of
        % j, it is different from i
        for j = 1:length(filesListOfSubfolder)
            % read the audio and preprocess it
            X = preprocess(audioread(filesListOfSubfolder(j)));
            
            % obtain the audio spectrum envelope
            ASE = AudioSpectrumEnvelopD(x);
            
            % obtain the audio spectrum projection
            ASP = AudioSpectrumProjection(ASE);
            
            % using PCA to reduce the dimention of feature vectors.
            
            % train the 
           
        end
    end
  %  [X,fs]    = audioread([audioDir,'/',audioList(i+1).name]);

%preprocessing for input audio file



end
