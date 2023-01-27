all_init = {'EN','GK','HL','RD','SL','JZ','PS','MR','EG','DB'}; % ,'MS'};
sIDs = [124 139 876 369 773 308 595 940 929 429]; % ,552];

% Empty vectors for storing all data to be saved:
dur = [];
MO = []; 

% Define any fixed values:
fps = 60;

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:4 % EACH SESSION
        
        % File name:
        fileNameString = [all_init{ii} '_AVTemporalTask_rateJND_V5_final_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_rateJND_V5/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            % load file:
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            % Get dur and MO:
            for kk = 1:600 % EACH TRIAL
                A = all_ear{kk};
                V = all_frameType{kk}-1;
                dur = [dur; length(V)/fps];
                [maxOffset,~,~] = get_maxOffset(V,A,fps);
                MO = [MO; maxOffset];
            end
        
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

% Save to file:
T = table(dur,MO);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/rateJND_MO.txt';
writetable(T,filesave,'Delimiter',' ')