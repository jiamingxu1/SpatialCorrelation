all_init = {'EN','GK','HL','RD','SL','JZ','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 595 940 929 429];

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:4 % EACH SESSION
        
        % Assign session names:
        switch jj
            case 1
                sessName = 'NoConflict';
            case 2
                sessName = 'SpatialConflict';
            case 3
                sessName = 'TemporalConflict';
            case 4
                sessName = 'SpatiotemporalConflict';
        end
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_rateJND_V5_final_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_rateJND_V5/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
        
        % Organise sequences:
        seqA_comparison = all_ear;
        seqV_comparison = all_frameType;
        for kk = 1:600; seqV_comparison{kk} = seqV_comparison{kk} - 1; end
        seqA_standard = all_ear_standard;
        seqV_standard = all_frameType_standard;
        for kk = 1:120; seqV_standard{kk} = seqV_standard{kk} - 1; end
        
        % Save data:
        dataPath = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/ArchivedData/rawSequences/';
        specDataID = ['Exp1_sID_' num2str(sIDs(ii)) '_' sessName];
        filesave = [dataPath specDataID '.mat'];
        save(filesave,'seqA_comparison','seqV_comparison','seqA_standard','seqV_standard')
        
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end