all_init = {'EN','GK','HL','RD','SL','JZ','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 595 940 929 429];

for ii = 1:length(all_init) % EACH SUBJECT
    
    seqA = [];
    seqV = [];
    
    for jj = 1:2 % EACH SESSION
        
        % Find and load file:-
        fileNameString = [all_init{ii} '_AVTemporalTask_controlExp_randomSeq_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_controlExp/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            % Organise sequences:
            seqA = [seqA; all_ear'];
            seqV = [seqV; all_frameType'];
            
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
    
    % Save data:
    dataPath = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/ArchivedData/rawSequences/';
    specDataID = ['Exp2_sID_' num2str(sIDs(ii))];
    filesave = [dataPath specDataID '.mat'];
    save(filesave,'seqA','seqV')
    
end