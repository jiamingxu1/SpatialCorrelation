% Send the data to R!

all_init = {'EN','GK','HL','RD','SL','JZ','MS','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 552 595 940 929 429];

% Empty vectors:
sID = [];
session = [];
rate = [];
tempConflictYN = [];
minOffset = [];
maxOffset = [];
propSync = [];
sumShiftsReq = [];
meanShiftsReq = [];
response = [];

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:2 % EACH SESSION
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_controlExp_randomSeq_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_controlExp/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
            
            for kk = 1:size(all_ear,2)
                [~,mo(kk),ps(kk)] = get_maxOffset(all_frameType(:,kk),all_ear(:,kk),60);
                [ssr(kk),msr(kk)] = get_seqSimilarity(all_frameType(:,kk),all_ear(:,kk),60);
            end
            
            % Store results:
            % -------------- %
            
            sID = [sID; repmat(sIDs(ii),size(resMat,1),1)];
            session = [session; repmat(jj,size(resMat,1),1)];
            rate = [rate; resMat(:,1)];
            tempConflictYN = [tempConflictYN; resMat(:,2)];
            maxOffset = [maxOffset; resMat(:,3)];
            minOffset = [minOffset; mo'];
            propSync = [propSync; ps'];
            sumShiftsReq = [sumShiftsReq; ssr'];
            meanShiftsReq = [meanShiftsReq; msr'];
            response = [response; resMat(:,5)];

        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

T = table(sID, session, rate, tempConflictYN, minOffset, maxOffset, propSync, sumShiftsReq, meanShiftsReq, response);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/controlExpData_all.txt';
writetable(T,filesave,'Delimiter',' ')

%% To correct the file from SL where response was written over max offset:
% rate = resMat(:,1);
% tempConflictYN = resMat(:,2);
% propSync = resMat(:,4);
% response = resMat(:,3);
% maxOffset = nan(size(resMat(:,3)));
% for ii = 1:size(resMat,1)
%     mo = get_maxOffset(all_frameType(:,ii),all_ear(:,ii),60);
%     maxOffset(ii) = mo;
% end
% resMat(:,5) = resMat(:,3);
% resMat(:,3) = maxOffset;
% fSaveFile = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/RunExperiment/data_AVTemporalTask_controlExp/SL/SL_AVTemporalTask_controlExp_randomSeq_S3_fixed_2016-06-01_15-07.mat';
% save(fSaveFile,'exp','all_frameType','all_ear','resMat','resMat_Legend')
% T = table(rate, tempConflictYN, maxOffset, propSync, response);
% filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/controlExpData3.txt';
% writetable(T,filesave,'Delimiter',' ')