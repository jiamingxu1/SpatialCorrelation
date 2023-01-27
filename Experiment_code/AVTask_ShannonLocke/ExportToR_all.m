all_init = {'EN','GK','HL','RD','SL','JZ','MS','PS','MR','EG','DB'};
sIDs = [124 139 876 369 773 308 552 595 940 929 429];

% Empty vectors:
sID = [];
session = [];
modality = [];
aRateC = [];
aRateS = [];
vRateC = [];
vRateS = [];
dur = [];
response = []; 

for ii = 1:length(all_init) % EACH SUBJECT
    for jj = 1:4 % EACH SESSION
        
        % Find and load file:
        fileNameString = [all_init{ii} '_AVTemporalTask_rateJND_V5_final_S' num2str(jj)];
        dataPath = ['data_AVTemporalTask_rateJND_V5/' all_init{ii} '/'];
        allMatchedFiles = dir([dataPath fileNameString '*']);
        try
            allMatchedFiles = allMatchedFiles.name;
            load([dataPath allMatchedFiles]);
        
        % Get the rates and durations for comparison and standard stimuli:
        % -------------------------------------------------- %
        % fx: rate = sum(X) / [(1/60)*length(X)] = fps*sum(x)/length(X)
        
        fps = exp.hardware.fps;
        all_dur = exp.designMat(:,3);
        mod_idx = exp.designMat(:,2); % Which modality for comparisons
        rateA = NaN(600,1); % Comparison stimuli, auditory stimulus
        rateV = NaN(600,1); % Comparison stimuli, visual stimulus
        rateAs = NaN(120,1); % Comparison stimuli, auditory stimulus
        rateVs = NaN(120,1); % Comparison stimuli, visual stimulus
        
        for kk = 1:600 % Get comparison rates
            selA = cell2mat(all_ear(kk));
            selV = cell2mat(all_frameType(kk))-1;
            rateA(kk) = (fps*sum(selA))/length(selA);
            rateV(kk) = (fps*sum(selV))/length(selV);
        end
        for kk = 1:120 % Get standard rates
            try
                selA = cell2mat(all_ear_standard(kk));
                selV = cell2mat(all_frameType_standard(kk))-1;
                rateAs(kk) = (fps*sum(selA))/length(selA);
                rateVs(kk) = (fps*sum(selV))/length(selV);
            end
        end
        % Reshape standard rates:
        rateAs = repmat(rateAs',5,1);
        rateAs = rateAs(:);
        rateVs = repmat(rateVs',5,1);
        rateVs = rateVs(:);
        
        % Store results:
        % -------------- %
        
        sID = [sID; repmat(sIDs(ii),600,1)];
        session = [session; repmat(jj,600,1)];
        
        % Visual only trials:
        modality = [modality; repmat(1,200,1)];
        vRateC = [vRateC; rateV(mod_idx==1)];
        aRateC = [aRateC; NaN(200,1)];
        vRateS = [vRateS; rateVs(mod_idx==1)];
        aRateS = [aRateS; rateAs(mod_idx==1)];
        dur = [dur; all_dur(mod_idx==1)];
        response = [response; visUML.r];
        
        % Auditory only trials: 
        modality = [modality; repmat(2,200,1)];
        vRateC = [vRateC; NaN(200,1)];
        aRateC = [aRateC; rateA(mod_idx==2)];
        vRateS = [vRateS; rateVs(mod_idx==2)];
        aRateS = [aRateS; rateAs(mod_idx==2)];
        dur = [dur; all_dur(mod_idx==2)];
        response = [response; audUML.r];
        
        % Multisensory trials:
        modality = [modality; repmat(3,200,1)];
        vRateC = [vRateC; rateV(mod_idx==3)];
        aRateC = [aRateC; rateA(mod_idx==3)];
        vRateS = [vRateS; rateVs(mod_idx==3)];
        aRateS = [aRateS; rateAs(mod_idx==3)];
        dur = [dur; all_dur(mod_idx==3)];
        response = [response; multUML.r];
        
        catch
            fprintf('\n\n Selected file could not be loaded!\n\n');
            disp(allMatchedFiles)
        end
        
    end
end

T = table(sID,session,modality,vRateC,aRateC,vRateS,aRateS,dur,response);
filesave = '/Users/shannonlocke/GoogleDrive/Library/Experiments/AudiovisualRateDiscrimination/DataAnalysis/RateJNDinR/data_raw_rateJND/rateJNDdata.txt';
writetable(T,filesave,'Delimiter',' ')