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
           % For each audio file, do the following:
           

           
        end
    end

           
end
